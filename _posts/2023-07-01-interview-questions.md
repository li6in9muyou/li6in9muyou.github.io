---
title: 前端面试题目。crap
categories: []
tags: [memo]
---

**THIS IS A WORK IN PROGRESS**

## 你说一下什么叫做强缓存和协商缓存

其实本来不存在强缓存和协商缓存的概念。所有的缓存系统都有几个关键属性

### 缓存的元数据是多少

一般情况下缓存的键就是网址。但是也可以用`Vary` 标头字段来注明你需要额外的键，例如`Vary: Accept-Language` 就表示需要把网址和`Accept-Language` 标头作为缓存的键。

另外还需要储存缓存的内容签名，可能是修改时间和一个任意的字符串，用来辅助缓存失效。

### 怎么判断缓存失效

如果请求内容的缓存键不在缓存库中，显然是缓存失效的，比如js bundle 更新之后他网址中的哈希码变了。

按照缓存的生存时间来判断，生存时间由旧版的`Expires` 和新版的`Cache-Control: max-age=3600` 来给出。生存时间内的判定为有效，生存时间内的判定为无效。需要执行缓存更新或者说缓存失效操作，也就是跟服务器查询自己保存这个内容是否有修改。查询的时候用`If-Modified-Since` 或者`If-None-Match` 这两个标头，回答的时候服务器对应的就使用`Last-Modified` 或者`ETag` 这两个标头。这些标头本质都是拿一个签名来对比，前一种是按照修改时间来对比，后一种就是那任意的一个字符串去对比。

## 深拷贝怎么写你说一下

先看一下可否使用`structuredClone` 没这个接口的话看下要复制的东西是否都是简单的东西 可以用JSON stringify parse 应付一下 但有循环引用的时候会报错

如果要手写的话 就是递归来写 递归算法可以分成三个部分 分解、合并和出口，递归分解的时候注意需要遍历哪些属性以及值是否已经复制过一次，递归合并的时候需要注意值是`undefined`的字段以及继承过来的字段，递归出口的时候注意处理各类特殊情况。当然如果输入的对象的树的深度有可能超过运行时的最大递归深度的话 需要写成迭代形式

遍历对象属性的时候 要看要不要`Symbol` 要不要继承过来的东西 以及他是不是数组那样用数字下标的东西

然后为了处理循环引用的话要用一个关联容器来记录那些已经复制过了的对象 最后就是很多特定类型的对象是需要特殊的复制方法的 比如日期和正则匹配的返回值 然后个别东西是不可能被复制的 比如函数

<details>
<summary>这个是之前看lodash 源码写的</summary>
Deep copying is naturally recursive. In `lodash`, the recurse entry is
at [a `baseClone` function](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2620) and
it supports various flavors:
- shallow or deep
- flatten inherited properties
- copy symbols or not
At every invocation:
1. If `!isObject(value)`, it can be trivially cloned by returning argument
   e.g. `(value)=>value` [lodash.js#L2632C7-L2634](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2632C7-L2634)
2. Give up cloning by returning literal `{}` or a caller-supplied parent
   object if the value is `Function`, `Error`,
   or `WeakMap` [lodash.js#L2656-L2658](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2656-L2658)
3. Create an object of the same type, types are determined by "toString tags"
   - `Boolean`, `Date`, `Map`, `Set`, `Number`, `Array`, `RegExp`:
     simply `new value.constructor` [lodash.js#L6185](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6185) but take extra care in
     following cases
   - `RegExp` has a `lastindex` that has to be copied manually
   - if this `Array` is returned from `RegExp#exec`, remember to copy some particular
     properties [lodash.js#L6153-L6156](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6153-L6156)
   - `Symbol`: use `Symbol#valueOf` if present otherwise fallback
     to `{}` [lodash.js#L4563](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L4563)
   - `DataView`, `ArrayBuffer`, `Buffer`: use native methods, `Buffer#slice` for deep clone and `Buffer#copy` for
     shallow
     clone [lodash.js#L4506-L4515](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L4506-L4515)
   - `Arguments`, and generic `Object` i.e. everything else: be careful with
     prototypes [lodash.js#L6167](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6167)
4. if subject is `Array`, `Set` or `Map`, their values are cloned or linked
   accordingly [lodash.js#L2670-L2678](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2670-L2678)
5. enumerate over object keys and descend into their values, when recursion returns, assign cloned value to
   corresponding key.
### Implementation details
#### assign value to a key
consider the following scenarios
- If this key is inherited , which can be checked with `hasOwnProperty`, overwrite only if two values are different.
  Make sure to use [SameValueZero](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Equality_comparisons_and_sameness) comparison.
- If the value is `undefined`, set it only if `!(key in object)`
#### enumerate keys
But before enumerating any key,
read [https://developer.mozilla.org/en-US/docs/Web/JavaScript/Enumerability_and_ownership_of_properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Enumerability_and_ownership_of_properties) first then handle
the following scenarios:
- whether to enumerate inherited property
- numeric indices in array-like objects including `Array`, `Arguments`, `Buffer` and its friends.
See [lodash.js#L3093-L3096](https://github.com/lodash/lodash/blob/4.17/lodash.js#L3093-L3096)
The algorithm for enumerating own properties
1. use `Object#keys` for most cases and use `newArray[index] = oldArray[index]` for array-like objects.
2. add enumerable symbols with `Object.getOwnPropertySymbols`
The algorithm for enumerating owned and inherited properties
1. Use `for ... of` loop for enumerating both own and inherited properties.
2. add enumerable symbols of every prototype on prototype chain
#### blazingly fast associative container
An associative container is needed to eliminate infinite recursion caused by cyclic references in cloning
objects. `lodash` uses native `Map` whenever possible. However, for compatibility reasons, `lodash` developers wrote
their own implementation in multiple ways. To achieve better performance, various implementations are developed.
[One implementation](https://github.com/lodash/lodash/blob/c7c70a7da5172111b99bb45e45532ed034d7b5b9/src/.internal/ListCache.ts) uses `[]` as base container. Insert operation simply pushes a key-value tuple to the array. Query
operations comparing every key one after another. This implementation is suitable for small containers and containers
have mostly non trivially comparable keys. String, number, symbol, boolean are considered trivially comparable.
[Another implementation](https://github.com/lodash/lodash/blob/c7c70a7da5172111b99bb45e45532ed034d7b5b9/src/.internal/MapCache.ts) uses `{}` as base container. This implementation is suitable for trivially comparable objects.
One complex implementation uses multiple simpler implementations for storing different types of keys. Another complex
implementation uses the array based one before changing to object based one when it has more than 200 keys.
<p style="color: red; font-size: 2rem;">严禁在本博客抖机灵，所有内容必须清楚表达意思。</p>
</details>


## 响应式设计你说一下

就是同一个页面 同一个代码 能够智能感知用户的屏幕大小和方向 并做出调整 主要调整他的布局、图片、文字大小 具体实现的时候 需要视觉设计和交互设计工友给出不同场景下的设计稿 然后我再来实现 上面提到感知用户的屏幕大小和方向 是使用媒体查询 具体怎么写忘了 他大概思路就是检测屏幕宽度属于哪个档次 图片和文字相应式就是 图片可以切换不同尺寸、长宽比、容量、分辨率 甚至是对图片进行裁剪 文字就是考虑用相对单位 或者对每个宽度都指定不同大小

## CORS跨域你说一下

用户代理中通常执行同源策略。在此基础上，用户代理又提供 CORS 作为一种宽松措施。

### 主要过程

通常情况下这个过程对 JavaScript 是透明的，除非你要读取服务器响应中特殊的 HTTP 头或者使用服务器发回的
HTTP cookie 等身份信息。

在发送 CORS 请求时，用户代理会发送`Origin`HTTP 头来指示当前 JavaScript 是属于哪个站点。
有的 CORS 请求被认为是简单请求，如 GET 和某些 POST 请求。如果用户代理认为某请求不是简单请求，
用户代理会在发送真正的 HTTP 请求之前用 HTTP OPTIONS 方法发送一个 preflight
请求来查询服务器是否允许 CORS 请求中使用的 HTTP 头和 HTTP 方法。查询方法是填写如下字段

- `Access-Control-Request-Method`：填写 HTTP 方法
- `Access-Control-Request-Headers`：填写 HTTP 头

[服务器应答](https://fetch.spec.whatwg.org/#http-responses)中要包括`Access-Control-Allow-Origin`，为了回答上面的查询还要对应地填写`Access-Control-Allow-Methods`和`Access-Control-Allow-Headers`。

此外，为了其他的目的，还可包括其他的头，见[https://fetch.spec.whatwg.org/#http-responses](https://fetch.spec.whatwg.org/#http-responses)

常用的有：

- `Access-Control-Allow-Credentials`：用来控制本次请求的[credentials mode](https://fetch.spec.whatwg.org/#concept-request-credentials-mode)，模式有：不使用、同源则使用、要使用。[Credentials](https://fetch.spec.whatwg.org/#credentials)指的是 HTTP cookie、TLS 客户端证书、authentication entries (for HTTP authentication)。
- `Access-Control-Expose-Headers`：将列出来的 HTTP 头暴露给 JavaScript。

下面是三个使用 CORS 的例子

- [`featch("https://example.com")`](https://fetch.spec.whatwg.org/#example-simple-cors)
- [JavaScript 要读取 HTTP 响应头](https://fetch.spec.whatwg.org/#example-cors-with-response-header)
- [服务器需要 HTTP cookie 来识别用户](https://fetch.spec.whatwg.org/#example-cors-with-credentials)

### 目的、作用与局限

其目的是为了放宽同源策略的限制，在同源策略中，用户代理只能向同一个源发送 HTTP 请求，
如果使用 CORS 的话，可以在其他源服务器同意的情况下，访问其资源。

跨域请求是有一定的安全风险的，假若这些请求中带上了用户代理中储存的用户的身份信息，如 HTTP cookie，
那么其他源的 web 应用就可假冒这个用户进行操作。例如，假若用户代理没有实现同源策略，用户访问钓鱼网站时，
该钓鱼网站就可以向真实站点发送带有用户身份信息的 HTTP 请求，给用户造成伤害。如果实现了同源策略，
钓鱼网站将通过 CORS 与真实站点交互，这样用户代理会与真实站点进行握手，真实站点可以指示用户代理自己是否信任钓鱼网站所在的源，
如不信任，用户代理就不会发送后继请求。
当然，攻击者也可以用其他的 HTTP 客户端，带上用户身份信息来访问真实站点，这攻击方法属于 CSRF 攻击，防范方法见
[https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#double-submit-cookie](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#double-submit-cookie)

## js数据的类型你说一下怎么判断

### `Array`

`Array.isArray` [source](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L11286)

### `NaN`

用`x != +x`，注意`Number.isNaN`不做类型强制转换，而global的`isNaN`会做，这导致不能成功转成数字的值都会被认为是`NaN`。

### 元语值

元语值如下：

- `null`
- `undefined`
- `true`、`false`

[source](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L11949)
用`===`，注意`Object.prototype.toString.call`返回相应的大写的`[object xxx]`。内置类型的字符串标记见[此处](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L92)

### `Object`

[source](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L11743)
不为`null`且`typeof`得`object`或`function`

### 数字、字符串

用`typeof`，`Number`和`String`用通用方法。

### 通用方法

[source](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L3063)
用`Object.prototype.toString.call`，
然后按照返回值判断，如果要判断的值自己覆盖了`toString`，要先把这个方法置`undefined`再调用，然后再恢复原方法。例如，[判断是否`Function`](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L11647)

```javascript
function isFunction(value) {
  if (!isObject(value)) {
    return false;
  }
  var tag = baseGetTag(value);
  return tag == funcTag || tag == genTag || tag == asyncTag || tag == proxyTag;
}
```

## 你说一下`let`、`const`、`var`

`var`的声明会被提升，可见域是当前包围的函数和子函数。未完待续……

## 你说一下箭头函数

箭头函数不能用作构造函数，也没有自己的`this`和`arguments`绑定，并且不应该用作属性方法。未完待续……

## 你说一下水平居中垂直居中

### 水平居中

文字用`text-align`，其他元素可以用`display: inline-block`。宽度确定的块元素用`margin: auto`

### 垂直居中

文字可把行高设置为父元素高度，如字体不对劲，可用`vertical-align`微调，其他元素可以用`display: inline-block`。

### 都可以

- `absolute`元素用对应方向上的两个属性置0
- `absolute`元素用`left: 50% top: 50%`然后再用`transform[XY](-50%)`往回调整
- `display: flex`然后设置恰当的属性。

## 隐藏一个元素你说一下怎么

最简单的就是display none 不占位置 不能点击 还有那个visibility hidden 占位置 不能点击 然后是透明度设置为零 这个都是正常的 只是看不到而已 然后是把z index 移到后面去 被其他元素挡住 这个也点击不了 

还有其他的就是 可以把元素用绝对定位移到视口之外 或者设置文字的颜色跟背景一致 也是看不到了

## 你说一下 HTTP 123

HTTP 2 同一个 TCP 连接可以传输多个 web 对象，这些 web 对象在 stream 中传输，stream 都分配了权重和依赖用来决定服务器处理的先后顺序。
HTTP 2 的头部是二进制的，并且可以在 web 对象之间复用。最后，HTTP 2 的服务器可以发回多个回复，如果客户端指定的话。对前端开发者来说，没有任何影响没有任何影响没有任何影响。

<p style="color: red; font-size: 2rem;">严禁在本博客抖机灵，所有内容必须清楚表达意思。</p>

## 事件循环你说一下是什么

这个指的是一种处理模型 他要求至少有两个任务集合 即一个任务集合和一个微任务集合
这两个集合里装的东西是一样的 他的主要算法就是
如果没有能运行的任务 就什么都不做 或者如果实现了空闲任务的 就执行空闲任务直到某个期限
期限是就是下一帧渲染、动画帧任务、定时器
任务不能运行是比较少见的 一般出现在iframe 嵌套和BFCache 场景中
如果有的话就从任务集合中 取出一个任务来执行 执行完了之后需要持续从微任务集合中取出微任务并执行 直到没有为止

## 排序算法你说一下

选择排序（selection sort）：每次找出最小的那个元素，把他取出放到一个新数组，直到原数组为空，新数据就排序完成了。

冒牌排序（bubble sort）：从左到右反复交换相邻的每个元素使得这两个数字是从小到大，一直重复到没有数字需要交换位置为止。

快速排序（quick sort）：写成递归形式

- 递归分解就是选出数组里的某一个数，然后把比他小的数放到一个数组，比他大的数放到另一个数组，对这两个数组往下递归
- 递归合并就是把小数递归结果、自己、大数递归结果做数组连接
- 递归出口就是传入空数组此时返回空数组。

## js 里面有多少种创建对象的方式你说一下

两个花括号。

写一个构造函数和用class 语法，这两个的差别在于class 帮你调用了父类的构造函数并把prototype 连接好了，构造函数的话需要手动来写。

还有其他几个创建方法，具体问ai 吧。

## 重绘和重排你说一下

重绘就是画面变化了，需要把新的数据从cpu搬到gpu 经过渲染管线生成新的画面。重排就是需要重新布局了。
但是没有经过测量不要瞎优化，测量方法就是用Lighthouse 以及记录运行时性能。
到写源码的层面，除了通行的性能优化方法，还需要注意就是用transform 替代 left top right bottom 之类的属性。

## 防抖和节流你说一下怎么实现的

防抖就是维护一个定时器settimeout 一般就是保存到函数闭包里面 如果是要求上升沿执行 那调用时 一定要重置定时器 定时器回调是把定时器变量设置为空 如果重置之前定时器变量为空就执行 如果是要求下降沿执行 定时器回调是那个执行函数 其他跟前面一样

节流实际就是上面的上升沿执行的防抖 但是改成不要覆盖原有的定时器 或者每次调用的时候把当前时间跟上次执行时间比较 如果超过允许的最小间隔的话就执行 否则就不执行 时间的话用单调时间比较合适

## 前端开发用到的工具你说一下

TODO

## react 为什么要从类组件改成函数组件了

类组件的弊端比较大 第一是复用组件的时候需要用类嵌套就是所谓的HOC、父子继承、类混入等方法 这些都是复用代码的手段中特别差的 第二是业务逻辑都写在类组件的各个生命周期钩子里面 一个钩子中可能写有多个功能的代码 一个功能的代码可能要写到多个钩子里面才能实现 函数组件就可以解决这些问题 首先是没有比自由函数更容易被复用的东西了 然后钩子实际也是自由函数 程序员可以随意把他妈拆分和整合 一个钩子就实现一个功能是非常容易做到的

还有就是函数组件因为结构更简单 在框架侧或者说运行时侧可以进行更多的调度和优化

## vite 和webpack 有什么不同

性能优化的方法主要有提前做工、少做工、更多机器三种 启动的时候webpack 会进行打包 他自己要走行依赖树 把打包的过程全部执行一遍 这个通常是比较慢的 vite 则是按需打包 这就是少做工了 他是按照浏览器的需要进行打包 然后到了热更新的时候 也是同样的 vite 会比webpack 少做工

webpack 如果配置打包分割和缓存 这就是提前做工的思路 也可以提高速度 两者在打生产包的时候是没有太大差别的 这个时候不可能少做工了

## 打包工具的HMR 是怎么实现的

热更新的时候 开发服务器都会在页面上注入自己的运行时 这个运行时是打包工具提供的 每个人都一样的 开发服务器会通知这些运行时有文件被更新了 发到浏览器 运行时就需要跟具体框架对接 就是调用所谓的热更新回调 然后react 开发团队写的代码就负责对页面进行热更新 这个过程是可能出问题的 就只能程序员手动刷新一下

可能存在的问题 以react 为例就是 副作用清理不完整 以及state保存顺序乱了 有时会抛出异常的 就需要刷新了

## 怎么判断元素是否可见你说一下

这个其实比较复杂 需要先判断是否在视口内 然后再判断是否真的可见

是否在视口内的话 最好是使用intersection observer 他接收一个回调和一个配置项 然后可以观察多个元素 你一旦开始观察的话会马上调用一次回调通知你当前是否可见 直接读取里面的重叠比例字段就可以了 大于0就是在里面 否则的话就用getboundingclientrect 然后要结合视口宽高、元素宽高、元素坐标来计算一下他是否在视口内 如果他不在dom树上的话 返回值字段都是0 用这个方法的话还需要手动处理js和元素不在同一个document 里面的情况 比如某元素是在iframe 里面 js运行在外面

往下的话就比较复杂了

然后再判断是否真的可见 首先是检查目标元素样式是否正常 这个就有很多了 比如透明度 visibility display none scale 等等 然后还有可能出现很多被遮挡的情况 比如zindex 比较小 被别的元素遮挡 以及被父元素剪裁 等等 需要用elementsfrompoint 来检查一下

## js作用域的理解你说下

作用域就是变量名在代码中的可访问的范围 可以分成全局作用域和局部作用域 作用域之间可以互相嵌套 查找变量名的时候 由里往外查找 函数定义的时候会拿到当时局部作用域的引用 因此可以继续使用

## fetch的好处和坏处

好处就是基于promise设计 优于基于回调设计的 并且能流式读取服务器返回 坏处就是不检查状态码 需要程序员手动检查 其他不好不坏的特点有 带cookie的话需要手动配置 以及取消的写法比较麻烦一点 就是要new 一个abortcontroller 再用他的signal 要取消的时候就是在abortcontroller 上调用abort 这个其实是比xhr 的abort 方法更加灵活强大的

## es6 有哪些新特性

let 和const、模版字符串、箭头函数、解构赋值 等等

## 什么css属性会被继承？

line-height, color, font, text-align 等等

## 你说一下defer async loading 属性什么时候使用啊？

defer 就是等到html 解析完了之后按顺序执行 async 就是异步下载 下载完了执行 顺序就不一定了 loading=lazy 就是加在图片上面的 浏览器自动执行懒加载 不在视口不加载

## 首屏速度怎么优化？

资源体积优化 代码压缩 懒加载等

请求效率优化 CDN 服务器合理设置缓存标头

然后可以用骨架屏安抚客户

然后可以在服务器预渲染

最后就是处理其他客户端上运行起来之后的瓶颈 需要具体分析

## 为什么tcp是3次4次

本来就是这样的 最终目的是双方达成共识 3次的时候 A说开始了 B回好 A回收到 这样AB就是都知道对方都可以开始了 4次的时候 A说没了 B回好 B说没了 A回好

## react为什么不建议用index 作为key

key 的目的是避免把没更新的兄弟也重新渲染 用下标的话 如果顺序重排了或者新增删除了 那就会有很多人得额外重新渲染了 另外就是key没变的时候react 会复用dom 或者其他非受控组件 可能会导致更新后被复用的东西跟没被复用的东西不匹配了

总之key 需要稳定和唯一

## react项目中如何引入图片

用import 引入 可被tree shaking 优化掉 也可以用require 动态引入 最后是把图片放到public 文件夹 最终上传到云端 用url 访问

## 埋点sdk你说下怎么写

这个东西主要有配置、采集、处理、传输、缓存五个部分 缓存就是没上传的数据暂时放到localstorage indexeddb 里面 传输就是向服务器上传数据 可用http、sendbeacon 等方式 采集和处理就是监听各种各样的东西 然后读取浏览器提供的统计数据 个别前端框架还允许钩取组件生命周期和事件 然后按照配置部分的要求来筛选 然后还要加上本次会话的跟踪信息 配置部分就是让sdk 用户程序性的配置或者查询网络地址上的配置信息

sendbeacon 的好处就是保证请求会发出 且不会影响下一个页面的加载

## 怎么上传文件？怎么做断点续传

这个就是像tcp 协议栈里面的那样做 首先是把文件分片、编号、计算哈希 然后上传每个分片之前都先跟后端查询对应的哈希是否已经上传过了 没有的话就用formdata 传输到云端 然后需要注意的东西就是可以并发上传 取3-5个连接 出错的时候重试需要实现指数避退 带有抖动的指数避退

## 前端水印怎么实现？

用canvas 或者svg 生成水印图片 并把他覆盖整个视口 用position absolute 和pointers event none 要增加移除难度的话可以监听dom 变化自动重新添加 也可以实现多重水印 就是在dom 不同位置插入多个相同的水印

## fixed 和sticky 有什么不同？

fixed 是相对于视口来定位的 跟父元素没关系的 sticky 是相对于某个能滚动的祖先元素来定位的 并且一开始是在原本的位置 只有他被挪出视口之外的时候才会去到设置的位置 如果他的父元素也整个被移出去的时候 他也会被移出去

## 怎么写一个实时自动补全搜索框？

基本思路就是监听用户输入 用防抖减少结果列表更新频率 数据来源需要从本地或者云端异步获取 数据获取后需要匹配然后更新画面 需要注意的点有 原生的全选、不选、新增选项等按钮要不要参与匹配以及他们的显示方式 然后是异步请求时需要取消前一次在途的请求 以及避免旧数据覆盖新数据 然后用户点选和网络返回可能出现争抢条件 需要设计处理办法 然后匹配结果需要做分页加载或者限制数量 最后是参与匹配的数据可能很多 需要检查大数据量下响应速度是否达标

## webpack 的module chunk bundle 是什么意思

module 就是每个引入进来的文件 chunk 就是module 组合起来的东西 根据配置来划分chunk 然后这些chunk 又会被划分和输出为bundle 一般情况下是一个chunk 生成一个bundle bundle 就是构建之后得到的东西

## webpack 的bundle 如何减少他的体积进而优化加载速度

首先需要用官方的打包分析器分析体积构成 然后 第一是 把图片转成webp 格式或者用base64 内联到bundle 中 css 也可以配置内联 减少网络请求次数 第二是对大型三方库要检查是否tree shaking 生效 并去掉用不到资源 例如本地化字典 第三是做代码分割 就是分开经常更新的和不经常更新的代码 比如三方库可以全部拆分出来并设置缓存 或者复用已经存在全局上下文中的三方库 业务代码可以利用动态import 做到路由级别的代码分割 第四是对构建出来的js 和css 进行最小化和压缩

## webpack 打包速度怎么优化？

分割代码然后缓存 以及改用更快的转译器

## core web vitals 是哪些指标

LCP 这个测量的是页面开始加载到最大内容绘制的时间 这个时候一般是下载和执行bundle 和查询后端数据

INP 就是从用户交互到画面更新的时间 这个时候一般是业务逻辑处理数据、浏览器重排和重绘、查询后端数据

CLS 测量的是页面元素布局的跳动 这个恶化原因包括 字体图片视频iframe 等宽高更新 以及动态插入的内容
