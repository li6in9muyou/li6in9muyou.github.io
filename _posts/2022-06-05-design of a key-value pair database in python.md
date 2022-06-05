---
title: design of a key-value pair database in python
date: 2021-06-10
categories: []
tags: [data_structure,python,database]
---

## schema

### binary representation in file system

A database is represented by a directory in the file system. Every time we access a certain database, we create a new file. One crucial decision of our database is that it append to existing file at all time. In order to update the value associated with certain key, we append a record containing the updated value with an older time stamp. To delete a key, we change it to a pre-defined key called TOMB_STONE.

Each file in the file system consists of a number of consecutive binary records following the schema: ```timestamp | key size | value size | key | value```. The first three sections are "metadata", the last two sections are "payload". Note that metadata in our schema has a fixed size. Timestamp is a 8B floating point denotes the number of seconds since Unix epoch. Key size and value size are long long integers, typically 8B, which supports payload size of over 1 million TB.  Key and value objects must be native python strings. They get serialized into ascii-encoded, variable length python native bytes.

### in-memory representation

a python native dictionary that maps key object to a wrapper that wraps necessary metadata together with the actual value. That requires object must be hash-able. And extra metadata is required, the schema for the wrapper object looks like ```file id | time stamp | binary size of value | offset in file | actual value object```.

### database index

a python native dictionary maps key object to seek position of the file. this dictionary is restored during the initialization phase.

## working overview

### initialization phase

We iterate over every files in the given directory.

For every record we encountered, we update the wrapper object in our in-memory model if this item 1) does not exist in our model or 2) has a newer time-stamp or 3) has TOMB_STONE as its key.

### key insertion, update and deletion

When user puts a key-value pair into database, we dump it immediately to file system via a IO proxy. This IO proxy provides ```time stamp, offset, binary size of value``` metadata that needed by in-memory model.

When user query a key, if the key exists in memory model, we read the actual payload from file system according to previously recorded metadata.

When user deletes a key, we delete it from memory model, and overwrite that key on  the file system with TOMB_STONE.

## limitations

Our append-only files grows rapidly if user repeatedly updates or deletes then inserts the same key.
