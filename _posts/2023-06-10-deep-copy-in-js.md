---
title: 你说一下深拷贝。how to do deep copy in JavaScript
categories: [Learning]
tags: [JavaScript, deep-copy]
---

# The algorithm

Deep copying is naturally recursive. In `lodash`, the recurse entry is
at [a `baseClone` function](https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2620) and
it supports various flavors:

- shallow or deep
- flatten inherited properties
- copy symbols or not

At every invocation:

1. If `!isObject(value)`, it can be trivially cloned by returning argument
   e.g. `(value)=>value` https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2632C7-L2634
2. Give up cloning by returning literal `{}` or a caller-supplied parent
   object if the value is `Function`, `Error`,
   or `WeakMap` https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2656-L2658
3. Create an object of the same type, types are determined by "toString tags"

   - `Boolean`, `Date`, `Map`, `Set`, `Number`, `Array`, `RegExp`:
     simply `new value.constructor` https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6185 but take extra care in
     following cases
   - `RegExp` has a `lastindex` to be copied manually
   - if this `Array` is returned from `RegExp#exec`, remember to copy some particular
     properties https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6153-L6156
   - `Symbol`: use `Symbol#valueOf` if present otherwise fallback
     to `{}` https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L4563
   - `DataView`, `ArrayBuffer`, `Buffer`: use native methods, `Buffer#slice` for deep clone and `Buffer#coopy` for
     shallow
     clone https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L4506-L4515
   - `Arguments`, and generic `Object` i.e. everything else: be careful with
     prototypes https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L6167

4. if subject is `Array`, `Set` or `Map`, their values are cloned or linked
   accordingly https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L2670-L2678
5. enumerate over object keys and descend into their values, when recursion returns, assign cloned value to
   corresponding key.

# Implementation details

## assign value to a key

consider the following scenarios

- If this key is inherited , which can be checked with `hasOwnProperty`, overwrite only if two values are different.
  Make sure to use `SameValueZero` comparison.
- If the value is `undefined`, set it only if `!(key in object)`

## enumerate keys

But before enumerating any key,
read https://developer.mozilla.org/en-US/docs/Web/JavaScript/Enumerability_and_ownership_of_properties first then handle
the following scenarios:

- whether to enumerate inherited property
- numeric indices in array-like objects including `Array`, `Arguments`, `Buffer` and its friends.

See https://github.com/lodash/lodash/blob/4.17/lodash.js#L3093-L3096

The algorithm for enumerating own properties

1. use `Object#keys` for most cases and use `newArray[index] = oldArray[index]` for array-like objects.
2. add enumerable symbols with `Object.getOwnPropertySymbols`

The algorithm for enumerating owned and inherited properties

1. Use `for ... of` loop for enumerating both own and inherited properties.
2. add enumerable symbols of every prototype on prototype chain

## blazingly fast associative container

An associative container is needed to eliminate infinite recursion caused by cyclic references in cloning
objects. `lodash` uses native `Map` whenever possible. However, for compatibility reasons, `lodash` developers wrote
their own implementation in multiple ways. To achieve better performance, various implementations are developed.

One implementation uses `[]` as base container. Insert operation simply pushes a key-value tuple to the array. Query
operations comparing every key one after another. This implementation is suitable for small containers and containers
have mostly non trivially comparable keys. String, number, symbol, boolean are considered trivially comparable.

Another implementation uses `{}` as base container. This implementation is suitable for trivially comparable objects.

One complex implementation uses multiple simpler implementations for storing different types of keys. Another complex
implementation uses the array based one before changing to object based one when it has more than 200 keys.

# read more

[如何写出一个惊艳面试官的深拷贝](https://juejin.cn/post/6844903929705136141)

There is one clever implementation in comment section. You gotta be kidding me, strategy pattern, seriously?
More like replacing switch case with lookup table.

```js
function deepClone(obj) {
  //数组或普通对象存在循环引用情况，使用map存储对象避免无限递归函数
  //函数局部变量，函数执行完毕之后就可以被GC,无需替换为WeakMap
  const map = new Map();

  //递归这个函数
  function clone(target) {
    if (map.has(target)) return map.get(target);
    // 获取 target 的具体类型，返回：Number String Object Array RegExp ...
    const type = Object.prototype.toString
      .call(target)
      .replace(/\[object (\w+)\]/, "$1");
    //使用策略模式，处理每种类型的克隆
    const strategy = {
      // Array和Object可以公用一个函数
      ObjectOrArray() {
        // const result = Array.isArray(target) ?[]:{} const result = new target.constructor() // !在迭代开始前进行set map.set(target, result)
        for (const [k, v] of Object.entries(target)) {
          result[k] = clone(v);
        }
        return result;
      },
      Map() {
        const newMap = new Map();
        target,
          forEach((v, k) => {
            newMap.set(clone(k), clone(v));
          });
        return newMap;
      },
      Set() {
        const newSet = new Set();
        target.forEach((item) => {
          newSet.add(clone(item));
        });
        return;
      },
      Date() {
        return new Date(target.valueOf());
      },
      RegExp() {
        const newReg = new RegExp(target.source, target.flags);
        newReg.lastindex = target.lastindex;
        return newReg;
      },
      Error() {
        return new Error(target.message);
      },
      // ...可添加支持更多对象类型
    };

    if (["Array", "Object"].includes(type)) {
      return strategy.ObjectOrArray();
    } else {
      return strategy[type] ? strategy[type]() : target;
    }
  }

  return clone(obj);
}
```
