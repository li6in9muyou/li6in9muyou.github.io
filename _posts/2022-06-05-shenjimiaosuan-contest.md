---
title: 神机妙算算法竞赛
date: 2021-07-31
categories: [ProjectExperience]
tags: [c++, algorithm]
math: true
---

> Author's Note: I got my [first pull request](https://github.com/isl-org/Open3D/pull/3927) merged into Open3D's code
> base, albeit a minor fix.

本次比赛共有三个题目，使用 C++编程语言，要求只能提交一个源文件。只能提交一个源文件的这个要求，后来发现实现起来不是很轻松。

# 第二题 三角网补色

本题给定一个三维空间中的三角网，约有四分之一的三角形没有被涂上颜色，要求把颜色补齐，空缺颜色按照相邻有色三角形的按通道平均值填入。

按照题目要求，显然如果一个空缺的色块的三个邻居全都是有颜色的色块，那么它的颜色是唯一确定的。主要讨论多个空缺色块连成一片时如何处理。我的思路同样非常简单，即把相连空缺色块视为同一块，找出他们的所有相邻色块计算平均值填入。

这种处理成片空缺色块的方法是比较草率的，如下图，补出来的色块比较突兀，明显看得出瑕疵。还有另一个问题是，下图用作测试用例的球的三角网的三通道
RGB 颜色$ ch_i $是用正态分布指派的：$ch_i\sim N(140,30)\ i\in
{1,2,3}$，不能保证已知颜色的点满足题目要求某三角形的颜色是其相邻三个三角形颜色的平均值。我生成随机颜色的方法也使得所补进去的颜色大多是相近的浅灰淡紫色。

比较好的处理方法是同时考虑连片平均色和相邻最近的颜色。更复杂的，我们可以考虑 n 阶邻居的颜色，并使得邻居之间的颜色变化一致，随后抽象成一个回归问题。

把三角网抽象成图，每一个三角形对应一个顶点，有公共边的三角形之间有一条边。为了简便计算，假设每个顶点的度都是
3，从给的样例来看这是成立的。某顶点的 n 阶邻居可以定义为，到某顶点的最短路为 n 的顶点集合。某顶点$v$ 的 1
阶邻居有$ng_1,ng_2,ng_3$ 三个，显然我们可以把顶点$v$的$k,\ where\ k\in{2,3,4...n}$ 阶邻居给划分为 3 类，记为$N_i$，且有：$ng_i
\in N_i,\ where\ i\in {1,2,3}$。那么对每个顶点，都可以得到 3 个序列：$CR_{j}^i, where\ i\in \{1,2,3,...,n\},\ j\in
{1,2,3}$，其中$CR_{j}^i$ 是$N_j$ 中$i$阶邻居的颜色值。然后可以分别考虑三个$CR_j$
方向上的颜色序列，可以使用负责的数值拟合、回归的方法得到每一支上的空缺颜色预测值，最后按照一定的方法综合考虑形成最终答案，最简单的可以是按通道取算数平均。

## 实现总结

这道题的具体实现比较差，可以改进的地方如：在读入点云数据后，接下来的构建的边、三角面等几何实体全部使用点的索引而不是点的坐标，这样可以避免浮点数之间的相等比较，也能够节省内存空间；转化三角网成图的过程中使用哈希表`std::unordered_map`
而不是红黑树`std::map`，毕竟边之间的偏序关系是没有几何语义的；寻找连通空缺块时的具体算法还可以再优化，这里不赘述了。

### 寻找三角网中的连通空缺块

从每一个空缺颜色的三角块出发，用 BFS 寻找空缺颜色的连通块。把找到的连通块的三角面的序号列表加入哈希集合以去重。这不是最高效的算法，但足够好了。

```c++
class VectorHashCalc {
 public:
  size_t operator()(const std::vector<unsigned int>& v) const {
    std::hash<unsigned int> hasher;
    size_t seed = 0;
    for (auto i : v) {
      seed ^= hasher(i);
    }
    return seed;
  }
};

class VectorEquality {
 public:
  bool operator()(const std::vector<unsigned int>& a, const std::vector<unsigned int>& b) const {
    return std::is_permutation(a.cbegin(), a.cend(), b.cbegin());
  }
};

std::vector<std::vector<unsigned int>> all_empty_group(const TriMesh& mesh, const AdjList& adj_tri) {
  const Color& EMPTY_COLOR = Color(255, 255, 0);
  std::unordered_set<std::vector<unsigned int>, VectorHashCalc, VectorEquality> empty_group_set;
  for (int i = 0; i < mesh.size(); ++i) {
    bool is_empty = mesh[i].rgb == EMPTY_COLOR;
    if (is_empty) {
      const auto& candi = empty_group(mesh, adj_tri, i);
      if (not candi.empty()) {
        empty_group_set.insert(candi);
      }
    }
  }
  std::vector<std::vector<unsigned int>> ans;
  std::move(empty_group_set.begin(), empty_group_set.end(), std::back_inserter(ans));
  return ans;
}
```

### 三角网可视化小工具

先把 ply 格式的三维模型转换成比赛所用的格式，并随机指派颜色，随后进行比赛官方三角网格式转换到 plotly.js 格式，最后在浏览器中用
plotly.js
作图，可以直观看到图形和颜色。球的三角网的颜色是随机生成的，已填颜色的色块用正态分布指派，空缺块的颜色使用上述算法填充，黄色表示空缺的三角块。大球的颜色给得不是很好，官方样例给的颜色比较相近的浅灰色，如果使用$$\mu$$
更小一些的正态分布，会好一些。

![newplot (2)](/assets/blog-images/神机妙算算法竞赛.assets/newplot (2).png)

![newplot (1)](/assets/blog-images/神机妙算算法竞赛.assets/newplot (1).png)

# 第三题 重建点云的表面

本题给定一批三维空间的点，要求重建其表面，保证没有在立体内部的点。

这个题看起来是最简单的一个题，因为这一任务是被广泛的研究过的，有许许多多现成的代码可以使用。不过当时我没有太多思考就决定要走重用关键代码，自己实现其他依赖的这条路。回想起来呢，我可以先试一下用自动化工具整合所有依赖成为单一源码，看看是否会超出比赛对源码文件大小的限制。并且我也没有尝试自己按照论文来实现，而是浪费了大约一周，20
余小时来努力把别人写好的代码搬运到自己的环境中使用。

我当初选定的是`BallPivoting`算法，这个算法直观简单，大概也可以应付比赛用例的需求。这个算法的依赖其实也特别多，需要先给点估算法向量、三维
convex
hull、三维德劳内三角化。这些东西背后还需要三维空间搜索树，向量的特征值等基础性功能。当时做得挺痛苦的，只想快点结束，也根本没有心思慢慢读论文，琢磨之后自己实现一个简单的。我还是太缺少规划了，极大的低估了这条路的艰辛，我不熟练在
C++环境下整合第三方代码到自己的项目中来。CMake 只会一些基本操作，不会自定义。

我其实应该自己努力实现一个早期的表面重建算法，如 power crust，这样收获更多。

本题的实现几乎全部是用的别人的实现，我自己做了一些 adapter 来提供 API 罢了，没有什么技术含量。核心的 BallPivoting 算法是用的
open3D 的实现，其中又需要依赖计算 convex hull，三维三角化。这两个计算的代码是费了一点功夫在网络上找的开源代码，都是论文作者释出的源码。至于最终结果的正确性，我心里也没底，测试估算法向量代码时，在
open3D 的测试用例下，总是有一两个是错误的。

![roll](/assets/blog-images/神机妙算算法竞赛.assets/roll.png)

# 第一题，三头遍历

本题给定一个无向图简单图，我要指挥三个以光速飞行的飞机，它们从三个不同节点出发，负责遍历图的每一个节点，最后在同一个节点结束。光速飞行也就是边上旅行时间不计，所有节点都是需要一个单位的时间，每个节点只需要搜索一次，之后再经过时不耗费时间。题目就是要求安排这三架飞机的飞行轨迹。

然后给出几个评价指标：

0. 最长飞行轨迹和最短飞行轨迹当中包含的节点数量差
1. 每架飞机负责搜索的节点的个数分配平均程度
2. ……

我的整体思路是这样的，各个飞机把其他飞机视为对手，每一步决策的时候都希望远离其他两个飞机，这样子三个搜索区域就大致可以均匀的覆盖所有的节点。具体算法也比较简单，直观的说就是，每个飞机每次先考虑自己所在节点的相邻节点，如果相邻节点都被搜索过了那就考虑全局未搜索节点。考虑节点的方法就是对每个可行的节点计算其余两个飞机分别和我的路程差，也就是二元组：

$$
(distance(a'_1, node)-distance(a, node),\ distance(a'_2, node)-distance(a, node))\ where\ node \in candidates
$$

其中$a'_1, a'_2$ 是另外两个飞机所在的节点。$$candidates$$
是邻居节点集并上全局未搜索节点集。此后按照一定的步骤排序选出最好的一个节点。方法是，先看每个二元组里面最小的数，这些数不妨成为局部最小值，然后看这些局部最小值里面最大的一批，如果只有一个那就选择这个，这个节点对另外两个飞机来说都是比较远的。如果有多个二元组的局部最小值是一样的，那就再按照二元组的和来选，选取加和最大的。代码如下：

```c++
auto local_min = [](const EvalOfNode n) {
    return *std::min_element(n.second.cbegin(), n.second.cend());
};
auto resulted_in_by = [](const EvalOfNode n) {
    return n.first;
};

std::sort(values.begin(), values.end(),
          [local_min](const EvalOfNode& a, const EvalOfNode& b) {
              return local_min(a) < local_min(b);
          });
auto utilmaxmin = std::count_if(values.cbegin(), values.cend(),
                                [&values, &local_min](const EvalOfNode& n) {
                                    return local_min(n) == local_min(values.back());
                                });

if (utilmaxmin == 1) {
    return resulted_in_by(values.back());
} else {
    auto diff_sum = [](const EvalOfNode n) {
        return std::accumulate(n.second.cbegin(), n.second.cend(), 0);
    };
    std::sort(values.begin(), values.end(),
              [&diff_sum](const EvalOfNode& a, const EvalOfNode& b) {
                  return diff_sum(a) < diff_sum(b);
              });
    return resulted_in_by(values.back());
}
```

代码中`EvalOfNode.second`就是上面说的二元组。

上面的部分就解决了每个飞机如何选择自己的下一个搜索目标的问题。

剩的的部分还有最短路径规划和整体模拟循环。题目要求没有完成所有搜索任务之前不能经过集合点，我必须给普通的 BFS
最短路算法加上黑名单机制，必要时飞机要绕路避开集合点。

整体模拟循环规定每一步模拟，每个飞机都要搜索一个节点，所有节点都搜索完毕的时候立刻结束模拟，每一步模拟都会根据飞机选择的节点更新地图知识库，都是常规操作。每一步规定每个飞机都必须搜索一个节点，那么可以保证在搜索个数一定是平衡的。

```c++
bool sim::make_simulation_step(world::Knowledge& KM, const world::Map& MAP) {


  for (const auto& agent : {AgentIndex::zero, AgentIndex::one, AgentIndex::two}) {
    const NodeIndexList sites = MAP.all_nodes();
    bool consider_done = std::all_of(sites.cbegin(), sites.cend(),
                                     [&KM](NodeIndex site) {
                                       return not KM.can_search(site);
                                     });
    if (consider_done) {
      return false;
    }
    NodeIndex go_to = sim::where_to_go(agent, KM, MAP);
    NodeIndexList path = MAP.path(KM.where_is(agent), go_to, MAP.size() - 1);
    KM.log_path_of(agent, path);
    KM.log_search(agent, path.back());
  }
  return true;
}
```

模拟结束之后，各飞机在地图上的位置没有定数，预先不能确定，总之让所有飞机回到集合点就可以了。

从具体实现来看，我把系统分成三个部分：

### `world::Knowledge`

此系统负责记录每个飞机的飞行轨迹和它们在任一时刻的位置。为了实现全地图未搜索完成时避开最终集合点的功能还实现了记录黑名单节点的功能。最后还要负责按照官方要求的格式或是便于
debug 的格式打印输出飞机飞行历史。例如，为了方便调试，飞机经过而不搜索的节点序号，后边跟着一个波浪线。

```
show history:
0: 0 1~ 10 8 7 11~
1: 1 9 5 4~ 6 11~
2: 2 3 4 11~
official format:
0 1 10 8 7 11
1 9 5 4 6 11
2 3 4 11
```

### `world::Map`

此系统实现了无向图，并提供基于 BFS 的最短路径算法，以及调整过的带有黑名单特性的版本。

```c++
NodeIndexList world::Map::path(NodeIndex start, NodeIndex end,
                               NodeIndex blockage) const {

  if (blockage == start or blockage == end) {
    return {};
  }

  if (start == end) {
    return {};
  }
  if (world::Map::are_neighbours(start, end)) {
    return {start, end};
  }
  NodeIndexList parent(m_adj.size(), std::numeric_limits<NodeIndex>::max());
  std::vector<bool> status(m_adj.size(), false);
  std::queue<NodeIndex> q;

  q.push(start);
  status[start] = true;

  while (!q.empty()) {
    auto me = q.front();
    q.pop();
    NodeIndexList within_one_step = world::Map::neighbours_of(me);
    std::remove_if(within_one_step.begin(), within_one_step.end(),
                   [&blockage](NodeIndex site) {
                     return site == blockage;
                   });
    for (const auto& nghb : within_one_step) {
      if (!status[nghb]) {
        q.push(nghb);
        status[nghb] = true;
        parent[nghb] = me;
        if (nghb == end) {
          return std::move(construct_path(start, end, parent));
        }
      }
    }
  }
  throw std::invalid_argument("graph is not connected!");
}
```

### `world::simulation`

本系统实现上述选择下一个搜索目标的逻辑和整个任务的主循环。

```c++
NodeIndex sim::where_to_go(AgentIndex agent,
                           const world::Knowledge& KM, const world::Map& MAP) {

  const auto& nghbs = MAP.neighbours_of(KM.where_is(agent));
  NodeIndexList candi;
  std::copy_if(nghbs.cbegin(), nghbs.cend(), std::back_inserter(candi),
               [&KM](const NodeIndex node) {
                 return KM.can_search(node);
               });

  if (candi.empty()) {
    for (NodeIndex i = 0; i < MAP.size(); ++i) {
      if (KM.can_search(i)) {
        candi.emplace_back(i);
      }
    }
  }
  if (candi.empty()) {
    throw std::logic_error("all sites in MAP have been searched");
  }

  EvalOfNode node_value;
  std::vector<EvalOfNode> values;
  auto dist = [&KM, &MAP](AgentIndex ag, NodeIndex node) {
    return static_cast<int>(MAP.distance_of(KM.where_is(ag), node));
  };

  for (const NodeIndex& node : candi) {
    std::vector<int> dist_diff;
    for (auto ag : {AgentIndex::zero, AgentIndex::one, AgentIndex::two}) {
      if (ag != agent) {
        dist_diff.emplace_back(dist(ag, node) - dist(agent, node));
      }
    }
    values.emplace_back(EvalOfNode{
        node, {dist_diff.front(), dist_diff.back()}
    });
  }

  auto local_min = [](const EvalOfNode n) {
    return *std::min_element(n.second.cbegin(), n.second.cend());
  };
  auto resulted_in_by = [](const EvalOfNode n) {
    return n.first;
  };

  std::sort(values.begin(), values.end(),
            [local_min](const EvalOfNode& a, const EvalOfNode& b) {
              return local_min(a) < local_min(b);
            });
  auto utilmaxmin = std::count_if(values.cbegin(), values.cend(),
                                  [&values, &local_min](const EvalOfNode& n) {
                                    return local_min(n) == local_min(values.back());
                                  });

  if (utilmaxmin == 1) {
    return resulted_in_by(values.back());
  } else {
    auto diff_sum = [](const EvalOfNode n) {
      return std::accumulate(n.second.cbegin(), n.second.cend(), 0);
    };
    std::sort(values.begin(), values.end(),
              [&diff_sum](const EvalOfNode& a, const EvalOfNode& b) {
                return diff_sum(a) < diff_sum(b);
              });
    return resulted_in_by(values.back());
  }
}
```

本实现使用 C++ STL 来实现候选节点的筛选、评估排序，用 lambda
表达式精简纸面代码，便于阅读。其中若地图中找不到合适的搜索目标候选，会抛出异常，本函数不负责终止模拟，只负责确定某一架飞机下一个搜索节点。

```c++
bool sim::make_simulation_step(world::Knowledge& KM, const world::Map& MAP) {

  KM.add_blacklist(MAP.size() - 1);
  for (const auto& agent : {AgentIndex::zero, AgentIndex::one, AgentIndex::two}) {
    const NodeIndexList sites = MAP.all_nodes();
    bool consider_done = std::all_of(sites.cbegin(), sites.cend(),
                                     [&KM](NodeIndex site) {
                                       return not KM.can_search(site);
                                     });
    if (consider_done) {
      return false;
    }
    NodeIndex go_to = sim::where_to_go(agent, KM, MAP);
    NodeIndexList path = MAP.path(KM.where_is(agent), go_to, MAP.size() - 1);
    KM.log_path_of(agent, path);
    KM.log_search(agent, path.back());
  }
  return true;
}
```

本函数实现一个简单的模拟循环，每个循环中为每个飞机确定下一个搜索目标，然后更新`world::Knowledge`
中飞机的位置、飞行轨迹等。当所有节点都被搜索过后返回非旗标给调用者。

它的典型调用者如下：

```c++
while (sim::make_simulation_step(KM, MAP)) {
    ;
}
```

循环体内可以写入用户感兴趣的调用，实际编码时常写入除错断言。

## 实现总结

本实现方便测试，模拟循环的可观察性非常好。给定两个确定的 KM，MAP
物件就可以测试模拟循环和搜索目标选择算法的正确性。各系统之间充分解耦，共同依赖于稳定的领域假定，如，节点序号是自然数且从零开始编号，三架飞机从序号最小的三个节点
0、1、2 号出发，搜索完毕后集结于序号最大的节点等。这些假定硬编码在实现中，如：

```C++
Knowledge()
    : m_loc{0, 1, 2},
      m_searched_by({
                        {0, AgentIndex::zero},
                        {1, AgentIndex::one},
                        {2, AgentIndex::two}
                    }) {};
```
