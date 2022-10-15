---
title: 临界区问题的软件解法模拟
date: 2022-10-15
categories: [ProjectExperience]
tags: [mutex,javascript,svelte,frontent,JLU-assignment,concurrent-programming,threads]
---

**THIS POST IS WOKR-IN-PROGRESS**

See it live at [live demo](https://li6in9muyou.github.io/software-mutex-sim/)

I built a simple webpage to demonstrate the execution of 4 algorithms that solved the mutex problem. The mutex problem is to ensure that only one of many concurrently running processes is executing the critical region. Being a software solution means that it requires no special hardware or special instructions e.g. test-and-set, compare-and-swap.

The four algorithms I was asked to implement are:

- Lamport's bakery algorithm
- Dekker's
- Peterson's
- Eisenberg & McGuire's

## feature

- Each (simulated) process can be paused and resumed during execution
- Global memory is updated in real-time
- Line number of source code at which the process is executing is updated in real-time

## Implementation Considerations

### concurrent execution

The JavaScript runtime is single-threaded thus to achieve concurrent execution is not easy. In short, this problem is solved by spawning worker workers.

### busy waits

Busy waits like

```js
while (should_wait(...)) {
    // busy wait
}
```

are exploited extensively in all four algorithms. Due to the nature of mutex problem, the condition that processes wait on is not going to change it's that process's turn to enter critical region. In another words, these busy waits waits a long time. A naïve implementation of busy wait consumes all computing resource of single CPU core which is bad. Things get worse when there are multiple processes contending the same critical region.

### shared global memory

Data exchange between master thread and worker threads is extremely limited. And worker threads can not directly access memory used by master thread. One solution to this problem is to use [ShardArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer). When pass such objects to multiple workers, they can access the same under lying `ArrayBuffer` hence any updates to that `SharedArrayBuffer` is visible to all worker threads.

