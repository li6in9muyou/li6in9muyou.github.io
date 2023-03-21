---
title: 大略了解分布式系统。MIT6.824 Distributed Systems
categories: [Reading]
tags: [distributed-system]
---

**THIS IS A WORK-IN-PROGRESS**

This free online course explains inner-workings of various distributed systems.

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

operation abstractions between a Frangipani client and Petal:

1. request to a lock server
2. grant a lock to a client
3. revoke a lock from a client
4. release a lock back to lock server

Lock has BUSY and IDLE state.
Lock is cached in client in a IDLE state as long as it has not been revoked.
One type of lock is shard read lock, another type is of course an exclusive write lock.

Anyone who reads a file must acquire a read lock first. Subsequently, he lock server revokes
any write lock. But no Frangipani
client busy writing shall be interrupted, lock server and all reader must wait for its writing
operation. Luckily, there is a big chance that such write lock is in IDLE state.
This process make sure that no one will be reading stale data since write must give writing
before any reader can read.

## atomicity

The system should grantee some file operations be atomic e.g. create and delete files.

## crash recovery

tricky scenarios:

- Even if a computer crashes in the middle of syncing local state to the central server,
  other computer should not be affected by it.

Write-Ahead-Log is used for crash recovery. Timeouts are also used to eliminate waiting indefinitely
for responses from a Frangipani client. WALs are meant to be replayed by other peers.

The lecturer distinguishes file metadata between user content. But how does the Linux OS implement
file system?

Sequenced numbers are used to track WAL entries and filesystem changes so that future readers
of same file entry are able to find the latest one. In such scenario, sequence number is often
called version number, which is very common in document-oriented NoSQL databases.

The lecturer comments that the Frangipani system is not suitable for today's use case of shard
file storage.

> A review of this software can be found
> at [wenzhe.one/MIT6.824%2021Spring/frangipani.html](https://wenzhe.one/MIT6.824%2021Spring/frangipani.html)

# Distributed Transactions (Distr. Xactions.)

Distributed transactions are used when some bussiness logic requires
modifying data across multiple servers.
Two main topics of this lecture are concurrency control and atomic commit.
A transaction packs series of operation into an atomic operation.
To facilitate such operations,
concurrent system often provides abstract primitives for application programmers
that mark the start and the end of a transaction. Another very useful abstraction would be
to abort. When an abort happens, the execution system rolls back intermediate modifications.
An abort may not indicates an error because interrupting a transaction can resolve a dead lock.

The classical ACID:

- Atomic: all or none
- Consistent: ignored by this lecture
- Isolated: serializable
- Durable: changes are persistent on non-volatile storage

What is serializable?
Serializable execution means that a concurrent system is able to execute concurrent
transactions that yields the same result as if those concurrent transactions are executed
in a serial fashion, in other words, one after another.

How to implement a serializable system?

## concurrency control

The two main strategies for concurrency control are pessimistic and optimistic concurrency control.
Pessimistic concurrency control is a strategy that tries to prevent conflicts from happening
by locking data items, while optimistic concurrency control is a strategy that allows
transactions to proceed without locking data items and checks for conflicts
when the transaction is ready to commit.

For example, let’s say that two computers, Computer A and Computer B, are trying to write to the same file
at the same time.
With pessimistic concurrency control, Computer A would lock the file so that
Computer B can’t write to it until Computer A is done. Once Computer A is done,
it would release the lock and Computer B would be able to write to the file.
This way, there’s no chance of Computer A and Computer B writing to the file at the same time
and causing conflicts.
With optimistic concurrency control, Computer A and Computer B would both be able to
write to the file at the same time. However, when they’re done, the system would check
to make sure that there are no conflicts between the changes that they made.
If there are conflicts, the system would roll back the changes and ask Computer A
and Computer B to try again.

### two-phrase locking

In the growing phase, a transaction acquires locks on data items as it reads and writes them. Once a lock is acquired,
it cannot be released until the transaction is ready to commit i.e. all changes have been made.
This ensures that other transactions cannot read or write the same data item
while the transaction is still in progress hence no one is able to see intermediate results.

In the shrinking phase, a transaction releases all of its locks once it is ready to commit. This allows other
transactions to read and write the same data items.

In distributed systems, data involved in a transaction may reside in different servers.
What if one of them fails in the middle of a transaction, how are we going to do about that?

### two-phrase commit

This operation involves two phases: a prepare phase and a commit phase.

In the prepare phase, the transaction coordinator sends a prepare message to all the servers involved in the
transaction. Each server then checks to see if it can commit the transaction. If a server cannot commit the transaction,
it sends a abort message to the transaction coordinator. If all the servers can commit the transaction, they send a
ready message to the transaction coordinator.

In the commit phase, the transaction coordinator sends a commit message to all the servers that sent a ready message.
The servers then commit the transaction and send an acknowledgement message to the transaction coordinator. If a server
cannot commit the transaction, it sends an abort message to the transaction coordinator.

The transaction ID and a list operations on involved resources are exchanged between the transaction coordinator and
participants. In addition to the transaction coordinator, there are two other roles in a two-phase commit: participants
and resource managers.

- Participants: servers that are involved in the transaction.
- Resource managers: software components that manage access to resources, such as databases or files, on behalf of
  the participants. Resource managers are required to manage access to resources, such as databases or files, on behalf
  of the participants. They ensure that the resources are accessed in a consistent and reliable manner.

The interaction between the transaction coordinator and the client that initiates the transaction is as follows:

1. The client sends a request to the transaction coordinator to begin a transaction.
2. The transaction coordinator assigns a unique transaction ID to the transaction and sends a prepare message to all the
   participants involved in the transaction.
3. Each participant checks to see if it can commit the transaction. If a participant cannot commit the transaction, it
   sends an abort message to the transaction coordinator. If all the participants can commit the transaction, they send
   a ready message to the transaction coordinator.
4. The transaction coordinator sends a commit message to all the participants that sent a ready message.
5. The participants then commit the transaction and send an acknowledgement message to the transaction coordinator. If a
   participant
   cannot commit the transaction, it sends an abort message to the transaction coordinator.
6. The transaction coordinator sends a response to the client indicating whether the transaction was committed or
   aborted.

In this two-phase commit protocol, the participants acquire locks during the prepare phase and release them during the
commit phase. The locks are acquired to ensure that the resources involved in the transaction are accessed in a
consistent and reliable manner.

### failure scenarios

If a participant server fails during the two-phase commit, the transaction coordinator will not receive a ready message
from that participant. The transaction coordinator will then send an abort message to all the participants that sent a
prepare message. The abort message tells the participants to abort the transaction.

For example, suppose a transaction involves three participants: A, B, and C. The transaction coordinator sends a prepare
message to all three participants. Participant A sends a ready message to the transaction coordinator, but participants
B and C do not. The transaction coordinator then sends an abort message to participants A, B, and C, telling them to
abort the transaction.

If a participant server fails after sending a ready message, the transaction coordinator will send a commit message to
all the participants that sent a ready message. The participants will then commit the transaction and send an
acknowledgement message to the transaction coordinator. If a participant server fails after receiving a commit message,
the transaction coordinator will not receive an acknowledgement message from that participant. The transaction
coordinator will then send an abort message to all the participants that sent a commit message. The abort message tells
the participants to abort the transaction.

If the transaction coordinator server fails during the two-phase commit, the participants will not receive a commit or
abort message from the transaction coordinator. The participants will then wait for a timeout period to elapse before
aborting the transaction.

For example, suppose a transaction involves three participants: A, B, and C. The transaction coordinator sends a prepare
message to all three participants and then fails before sending a commit or abort message. Participants A, B, and C will
wait for a timeout period to elapse before aborting the transaction.

A lot of things can go wrong in these operations, system designers have to prepare their system for various failures.
In short, there is a lot of acknowledgements and back-and-forth between participants and coordinators, when any reply is
not received, the whole operations aborts. Participants use Write-Ahead-Log to grantee the transaction will be made
before reply to coordinator.

In short, write a log to persistent storage before doing anything publicly.

In short, use timeout when holding a lock except you have promise to commit the operation.

Drawback of two-phrase commit:

- Many RTT are required.
- Bottleneck at disk writes.
- Long lock holding time.

To achieve high availability with this protocol, one must replicate different parties involved.

## atomic commit
