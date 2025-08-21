---
title: 快点、再快点。the pursuit of speed
categories: []
tags: []
---

**THIS IS A WORK IN PROGRESS**

## 少做工

更优算法

### 利用领域知识减少做工

- last N digits of fibonacci sequence is cyclic, thus one can calculate last N digits of the Xth number in the sequence with manageable time and memory
- mark simple inputs beforehand so that expensive checks and defensive logic can be skipped later or a faster ad-hoc algorithm can be used. see [v8-json-stringify](https://v8.dev/blog/json-stringify)
- lazy loading and lazy evalution.

### 成批操作减少每次操作的overhead

- concat strings before output to stdout
- merge meshes to render them in a single draw call
- HTTP 2 multiplexing

## 提前做工

### 缓存

- memory hierarchy
- CDN

#### challenges

- cache invalidation
- cache consistence

### 预取

- `prefetch` attributes in HTML

### 索引

- B 树

### 流水线

- CPU

## 更多机器

并行计算、专用硬件、一个指令多个数据
