---
title: 大略了解分布式系统。MIT6.824 Distributed Systems
categories: [Reading]
tags: [distributed-system]
---

**THIS IS A WORK-IN-PROGRESS**

This free online course explains inner-workings various distributed systems.

# Frangipani

Frangipani implements a shard storage among computers. There is Frangipani software
running on every user's computer that emulates a file system where a lot of caching and
distributed system magic take place. This system also operates a centralized
server called Petal that can simply be viewed as a reliable disk drive in this article's context.

Key challenges of such system are:

## cache coherence

tricky scenarios:

- After one computer creates a new file on the system, other computers are expected to
  see this change as soon as possible.
- When multiple computers are modifying a same file or directory, those modification should not
  interference each other unexpectedly.

To address above issues, IO operations on shard files follows strict rules.

- cache is invalid without holding a lock
- acquire a lock before read
- write before release a lock

Communication protocols between a Frangipani client and Petal:

1. request to a lock server
2. grant

## atomicity

The system should grantee some file operations be atomic e.g. create and delete files.

## crash recovery

tricky scenarios:

- Even if a computer crashes in the middle of syncing local state to the central server,
  other computer should not be affected by it.

> A review of this software can be found
> at [wenzhe.one/MIT6.824%2021Spring/frangipani.html](https://wenzhe.one/MIT6.824%2021Spring/frangipani.html)
