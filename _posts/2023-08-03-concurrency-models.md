---
title: 大略了解并发模型。seven concurrency models in seven weeks
categories: [Reading]
tags: []
---

**THIS IS A WORK IN PROGRESS**

# Communication sequential processes

The twin pillars of CSP implementation in `Clojure` are _channel_ and _go blocks_.

## Go blocks

This mechanism achieves inversion of control. But how and what is "inversion of control"?
In fact, "inversion of control" is badly coined term by the author to describe
that a system transparently manages a lighter version of CPU threads. This can be done in
compile time using macro magic like Clojure `core.async` or in run time
like goroutines. At compile time, the go block macro analyses the usage of parking
function calls and split the execution into states accordingly.
A detailed explanation of an expanded macro can be found at
[http://hueypetersen.com/posts/2013/08/02/the-state-machines-of-core-async/](http://hueypetersen.com/posts/2013/08/02/the-state-machines-of-core-async/)

## Channels

A channel is a thread-safe queue.

# Data parallelism with GPU

# Lambda architecture
