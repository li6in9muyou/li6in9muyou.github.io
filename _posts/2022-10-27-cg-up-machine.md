---
title: 计算机图形学上机实验课作业。Computer graphics up machine assignments
categories: [ProjectExperience]
tags: [computer-graphics, algorithms]
---

# 软件系统设计

## 绘图器

### 基本绘图功能

计划从零开始实现。基本思路是用高分辨率的画布模拟低分辨率的画布，使用 `setPixel` 原语绘图。
点亮屏幕像素时，在高分辨率的画布上绘制无边框的，单色填充的正方形。

题目要求的二维图形绘制较为简单，且相似性很大，绘制多边形、矩形、圆形、贝塞尔曲线其实都是同一个功能。

我计划需要如下基础设施，其中的 `setPixel` 和 `line` 使用逻辑坐标。

```ts
class Context {
  drawColor: Color;
}

type Point = [number, number];

declare function line(
  context: Context,
  x1: number,
  y1: number,
  x2: number,
  y2: number
);

declare function setPixel(x, y, color: Color);

interface IDrawing {
  drawArraysLineLoop(context: Context, vertices: Point[]);
}

interface IDrawOverlay {
  drawLine(context: Context, a: Point, b: Point);
  drawPointMark(context: Context, point: Point);
}
```

对于各具体的图形，须实现如下的接口

```ts
interface Path {
  generateVertices(control_points: Point[]): Point[];
}
```

此外还需要如下工具函数，在 setPixel 时使用，负责在实际画布和模拟的低分辨率画布之间转换。

```ts
declare function viewportToLogical(vertex: Point): Point;
declare function logicalToViewpoint(vertex: Point): Point;
```

### 多边形填充

实验课题目要求使用栅栏填充算法。

### 三维图形绘制

我计划在 JavaScript 运行环境下模拟可编程图形处理器流水线，具体的说，要实现如下功能

- 设置顶点列表，`gl.bindBuffer(gl.ARRAY_BUFFER, vertices)`
- 设置各图形原语的顶点索引，`gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer)`
- 设置顶点着色器和片元着色器，`gl.useProgram(program)`

用户发出绘图指令，`gl.drawElements(gl.TRIANGLES, count, ...)`，后

- 对设置的各顶点，调用顶点着色器
- 图形原语组装
- 对每个图形原语，栅格化然后对每个片元逐顶点属性进行插值
- 对每个片元，调用片元着色器

## 功能选择菜单

用超链接和静态页面来实现，要实现下面的这个菜单，注意菜单的三个层次结构：

- 图形应用
  - 图形绘制
    - 绘制矩形
    - 绘制圆形
  - 区域填充
    - 绘制多边形，用文字填充
  - 三维变换
    - 绘制一个三维立方体
    - 沿 X 轴方向平移
    - 沿 Y 轴方向平移
    - 沿 Z 轴方向平移
    - 绕 X 轴旋转
    - 绕 Y 轴旋转
    - 绕 Z 轴旋转
  - 绘制曲线
    - 绘制贝塞尔曲线

## 每个功能的页面

- 当前的功能是哪一项

- 固定的使用说明，由实验课题目给出

  - 例如，点击第一次设置圆心，第二次设置半径
  - 摁`a`键向 X 轴负方向平移，摁`l`键向 X 轴正方向平移

- 参数设置，如果有

  - 颜色，绘制矩形、圆形、多边形填充时需要，是一个 RGB 颜色值。
  - 平移步长、旋转度数，是一个实数。

- 画布
