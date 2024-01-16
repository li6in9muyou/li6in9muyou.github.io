---
title: Pacman如何做出有个性的反派。How does Pacman create ghosts with distinctive personalities
categories: [Reading]
tags: [game-dev, ai, pacman]
---

本文大致摘要了[由 Chad Birch 撰写的这篇文章](https://gameinternals.com/understanding-pac-man-ghost-behavior)

[在这里游玩经典的 Pacman 游戏](https://freepacman.org/)

游戏中有四种颜色的反派它们都具有非常突出的个性，读者可在上面的链接中体验。
八十年代的开发者们是如何给它们赋予个性的呢？

该游戏在一固定的迷宫地图中进行，只考虑角色的移动时，地图可用正方形网格建模。各个角色只能沿着
迷宫的路做上下左右四个方向的移动。

# 反派们是如和决定自己的行动轨迹的呢？

每到当达路口时，各角色都会有一个目标点，选择距离目标点最近的那个方向，但不能在路口回头。
距离用当前位置和目标位置的直线距离，如果有两个方向打成平手，按照规定好的顺序来选择。

![在路口决定方向](/assets/blog-images/2023-02-08-pacman-ghost-patterns/bad-decision.png)

# 反派们如何决定自己的目标点呢？

这是反派们个性形成的关键。

## 红色反派

目标点始终是玩家的当前位置，这使得它总是穷追不舍。

![穷追不舍](/assets/blog-images/2023-02-08-pacman-ghost-patterns/blinky-targeting.png)

## 粉色反派

目标点始终是沿着玩家前进方向上的第四格，这使得它有一点的前瞻性。

![快人一步](/assets/blog-images/2023-02-08-pacman-ghost-patterns/pinky-targeting.png)

## 蓝色反派

该目标点计算较为复杂，先记玩家前进方向上的第二格为 center 点，再记现在红色反派的位置为 bottom-left 点，
以 center 点为中心点，bottom-left 点为左下角点，按照游戏地图的网格，我们可以做出一个长方形，这一长方形的右上角
即为目标点。这中目标点使得它的行动轨迹难以预测。

![变换莫测](/assets/blog-images/2023-02-08-pacman-ghost-patterns/inky-targeting.png)

## 橙色反派

如果当前位置与玩家位置的直线距离小于 8 个单位，该目标点固定为地图左下角处的某一点。否则，其目标点为玩家当前位置，
这使得它似乎没有要追逐玩家的意图。

![若无旁人](/assets/blog-images/2023-02-08-pacman-ghost-patterns/clyde-targeting.png)
![若无旁人](/assets/blog-images/2023-02-08-pacman-ghost-patterns/clyde-targeting2.png)

# 游戏 AI 的其他设计

根据游戏进度和游戏故事设定，各反派 AI 的行为在三种模式间切换，在各模式下，它们的行为可概括为：

### 游荡

各反派的目标点分别是地图四角处的某点，结合上述的寻路决策算法，游荡模式下它们最终将各自转圈。

![游荡路径环](/assets/blog-images/2023-02-08-pacman-ghost-patterns/scatter-targets.png)

## 追逐

如上述。

## 惊慌

进入该模式时立即回头走，然后在各路口随机选择方向。
