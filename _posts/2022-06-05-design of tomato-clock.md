---
title: 番茄钟的设计与实现。design of tomato-clock
date: 2022-05-14
categories: [ProjectDesign]
tags: [software-engineering, making-things-complicated]
---

# domain entities

countdown-period

- duration
- default duration
- name

counter

- isRunning
- shouldLoop

counter has one or more countdown-periods

# usecase

## resume and pause

1.  this event is captured
2.  no business rules
3.  `isRunning = !isRunning`
4.  no output

## set duration of a countdown-period

1. this event is captured
2. business rules
   - `1 <= duration <= 60`
3. depends on `isRunning`
   1. if isRunning == true, do nothing
   2. set the specified countdown-period's duration.
4. no output

## countdown

1. execute every 1 second
2. depends on isRunning
   1. if isRunning == true, increase internal counter by one
   2. otherwise, do nothing
3. no output

## reset

1. this event is captured
2. no business rules
3. restore initial state
   1. isRunning = false
   2. for every countdown-period, duration = default duration

# components/classes

## countdown-period repository

It is a sequence of countdown-period.

This class provides a factory method`fromArray(periods: CountDownPeriod[])`.

It provides `whichDuration(time: number): CountDownPeriod` which throws `NoDurations` if sequence is empty. If `time` is bigger than the sum of durations of all periods, it overflows. It throws `InvalidTimeValue` if `time` is negative.

## countdown-period

This is a simple value entity representing basic information of periods. Instances are mutated by `setDuration(duration: number)` and `reset`. Constructor are fairly simple: `ctor(name: string, defaultDuration: number)`. `duration` is exposed as public attribute.

## clock

public state

- `readonly time: integer` the number of seconds elapsed with isRunning being true since this instance is created.

methods

- `reset()`: call `stop()`, then set time to 0.
- `start()`: set isRunning to true, `id = setTimeout(()=>{...}, 1000)`.
- `stop()`: set isRunning to false, `clearTimeout(id)`.

## controller

this entity handles aforementioned events.
