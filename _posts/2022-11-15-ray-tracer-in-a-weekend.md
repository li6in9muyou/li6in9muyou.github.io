---
title: 光线追踪器在一个周末。Ray tracer in a weekend
categories: [ProjectExperience]
tags: [go, computer-graphics, ray-tracing]
---

I followed
[this famous introductory book ](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
on ray tracing in the Go programming language. Key takeaways are:

- naive parallel execution is not the silver bullet for slow programs
- debugging this program is hard

# Debugging math stuff is hard (if you don't know the math)

Debugger offer little help here because raw values of a `Vec3` make no sense.
All one can do is make sure basic operations on vectors are all correct. Then check key assumptions
of the whole code base, like:

### bounds of key value spaces

Some coordinate spaces use normalized coordinates. Some code assumes parameters passed in are normalized
into some bounds. In contrast to the usage of normalized coordinates, some vectors must retain size information
hence they must not be normalized e.g. vectors describing the size of "film" of focal length.

Furthermore, computer graphics community use floating point in [0, 1] to represent RGBA color,
while some image processing lib use `uint` in [0, 255] and some lib requires 32bit integer for storing
intermediate results of RGBA colors to prevent overflow when multiplying.

### coordinate system origins and handedness

In math world, coordinates starts at left-bottom corner while computer world coordinates usually
starts at left-top corner. In view (a.k.a. camera) space, coordinate starts at the center of viewport.
Handedness only exists in three dimension coordinate systems, screen space or image space with
top-left origins do not have a Z axis.
In math world, x coordinates increases to the right, y coordinates increases upwards. These two axes
can be trivially drawn on a two dimension plane be it a paper or a digital screen.
After x and y axes are drawn as usual, handedness can be shown by how Z axis is shown.
In left-handed coordinate system, the Z axis points into the screen. While in right-handed coordinate system
the Z axis points out.

# Parallel execution is not the silver bullet

On a N core machine, computation-bound program like a ray tracer could not achieve a speed-up more than
N times. Speed-up at this magnitude falls short compared to algorithmic improvements.
Utilizing goroutines, one may naively create a goroutine for every scanline in the image hoping to
harness all the computation power.

At first, I did just that, but it turns out takes even more time to render.

```go
wg := sync.WaitGroup{}
for y := 0; y < PictureBounds.Max.Y; y++ {
  go func(y int) {
    wg.Add(1)
    // render one row of pixels
    wg.Done()
  }(y)
}
wg.Wait()
```

I know such slow-down is caused by contention. And I suspect that the random number generator
is the subject of contention. So I create a new random source for every goroutine, which ends up
to be a satisfactory speed-up of roughly 4.5 times.
