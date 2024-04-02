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

The MapReduce paradigm distributes both data and computation across a cluster of hunders of computers to process gigabytes or terrabytes data.

## Batch layer

It calculate derived data over some raw data in advance to provide a *batch view* e.g. `select sum(sales) from daily_sales group by WEEK(date)` runs an aggregation function on weekly data.
Afterwards, the same aggregation function that runs on any time interval can be computed with some pre-computed data.
For example, when aggregating on a period of 10 days, it can find a pre-computed weekly data then merge aggregation results from the rest 3 days thus saving computation.
Note there are two downsides in such batch-and-cache operation.
One is that data records it pre-computed with can not be mutated after creation otherwise all pre-computed results will be invalidated.
Second is that sometimes such batch view computation can take a significant amount of time i.e. batch view always lags behind and out-of-date.

