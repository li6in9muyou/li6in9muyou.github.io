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

## 你说一下深拷贝怎么写

基本方法就是递归来写，递归分解的时候注意需要遍历哪些字段以及值是否已经复制过一次，递归合并的时候需要注意值是`undefined`的字段以及继承过来的字段，递归出口的时候注意处理各类特殊情况。

1. 遍历对象属性的时候有多种不同风味：

   1. 要不要`Symbol`
   2. 要不要继承过来的东西，要继承的`Symbol`的话要爬原形链的
   3. 数组用`arr[idx]` 其他用`Object.keys(...)`就行了

2. 你需要一个高性能关联容器或者直接用`new Map()`这个是用来确保同一个引用不会被复制两次 不管他是否是当前节点的祖先。
3. 复制具体对象的时候需要分别处理，比如`Buffer`和他的朋友们。

### The deep copy algorithm

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

### read more

<p style="color: red; font-size: 2rem;">严禁在本博客抖机灵，所有内容必须清楚表达意思。</p>

## 你说一下响应式设计

响应式设计就是一批行业内的最佳实践，用来处理不同屏幕大小和屏幕方向对网页的影响，从而给用户最好的体验。
主要着力点是三个方面：页面布局、图片、文字。详见[https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)

页面布局应该根据屏幕尺寸调整视觉元素的布局，例如，在窄屏幕上使用单列布局，在宽屏幕上采用多列布局；在窄屏幕上将列表合并为下拉菜单，
在宽屏幕上则将其展开。

图片响应式的做法主要是给同一个图片提供多种不同分辨率、不同尺寸、不同容量的图片源供用户代理选用，其目标是在不同的屏幕大小和不同的带宽
环境下使用合适用户的图片。有时，仅仅在在小屏幕上使用小容量的图片在大屏幕上使用大容量图片以期节省用户的网络流量可能还不够，
[这篇文章](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)讲述了有时应该在在小屏幕上提供局部特写照片，而在宽屏幕上可是适当提供远景照片，也就是说图片响应式也应该适配画面
的内容。

文字响应式的做法是根据屏幕大小尺寸调整文字的大小，例如在大屏幕上可以适当增大标题文字的尺寸。
可以用 media query 和 viewport units 来实现。

## 你说一下跨域

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

## 你说一下怎么判断数据的类型

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
然后按照返回值判断，如果要判断的值自己覆盖了`toString`，要先把这个方法置`undefined`再调用，然后再恢复原方法。例如，[判断是否`Function`
](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L11647)

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

## 你说一下怎么隐藏一个元素

- `display: none`：宽高为0，不占位置，点击不了。
- `visibility: hidden`：宽高正常，占位置，点击不了。
- `opacity: 0`：宽高正常，占位置，能点击。
- 宽高设置0：外边距占位置，内容会溢出。
- `z-index`设置足够小：宽高正常，占位置，要有其他元素遮挡，否则能看到却不能点击。
- 把元素位置移到视口之外：呵呵。

## 你说一下 HTTP 123

HTTP 2 同一个 TCP 连接可以传输多个 web 对象，这些 web 对象在 stream 中传输，stream 都分配了权重和依赖用来决定服务器处理的先后顺序。
HTTP 2 的头部是二进制的，并且可以在 web 对象之间复用。最后，HTTP 2 的服务器可以发回多个回复，如果客户端指定的话。对前端开发者来说，没有任何影响没有任何影响没有任何影响。

<p style="color: red; font-size: 2rem;">严禁在本博客抖机灵，所有内容必须清楚表达意思。</p>

## 你说一下什么是事件循环

浏览器中的事件循环（Event Loop）是一个无限循环，它负责不断地从一个任务队列中取出待执行的任务（如用户的点击、定时器或网络请求回调），并将其按顺序推送到调用栈上执行，从而确保所有任务都能在不阻塞主线程的情况下得到处理。他的主要目的是实现并发编程。

## 你说一下排序算法

选择排序（selection sort）：每次找出最小的那个元素，把他取出放到一个新数组，直到原数组为空，新数据就排序完成了。

冒牌排序（bubble sort）：从左到右反复交换相邻的每个元素使得这两个数字是从小到大，一直重复到没有数字需要交换位置为止。

快速排序（quick sort）：写成递归形式

- 递归分解就是选出数组里的某一个数，然后把比他小的数放到一个数组，比他大的数放到另一个数组，对这两个数组往下递归
- 递归合并就是把小数递归结果、自己、大数递归结果做数组连接
- 递归出口就是传入空数组此时返回空数组。

## 你说一下js 里面有多少种创建对象的方式啊

两个花括号。

写一个构造函数和用class 语法，这两个的差别在于class 帮你调用了父类的构造函数并把prototype 连接好了，构造函数的话需要手动来写。

还有其他几个创建方法，具体问ai 吧。

## 你说一下前端开发用到的工具吧

TODO
