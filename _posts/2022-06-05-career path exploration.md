---
title: 计算机科学各研究领域论文选读
date: 2021-07-27
categories: [Exploration]
tags: [career_path, read_papers, thoughts]
---

[CCF](https://www.ccf.org.cn/) groups computer science research journals and conferences into the following fields.

0. 计算机体系结构/并行与分布计算/存储系统
1. 计算机网络
2. 网络与信息安全
3. 软件工程/系统软件/程序设计语言
4. 数据库/数据挖掘/内容检索
5. 计算机科学理论
6. 计算机图形学与多媒体
7. 人工智能
8. 人机交互与普适计算
9. 交叉/综合/新兴

# papers

## #3 One way to select many

> This paper is accepted by ECOOP which is rated as class B by CCCF.

It is to address this problem:

> software industry has not managed to establish precise
> standard semantics for selecting multiple elements from collections and, consequently, to produce easily reused implementations of selection features

and it propose:

> the abstractions that capture the essence of multi-selection features and enable their precise and concise specification, and their generic implementation

It points out current deficient:

> The precise meanings of these actions, however, are not established, as evidenced by the below review of sample applications.

This work is quite good, because the author gets to write a lot of javascript code that solves a concrete problem in the industry. More importantly, the author proposed an general abstraction for such user interaction scenario. He decomposes seemingly complex use-case into reuseable pieces and expresses them with formal language.

I am always facinated with abstraction in software engineering.

## #4 A Survey of State Management in Big Data Processing Systems

> This paper is accepted by VLDB J. which is rated as class A journal by CCCF.

This paper discuss everything you can do with such "state" in database system, such as managing state, using state. It addresses all aspects in the following plot:

However I find an interesting statement in that paper which is going to be our sample paper from #1

## #1 Complexity Analysis of Checkpoint Scheduling with Variable Costs

it's published on IEEE Trancsactions on Computers which is a class A journal per CCCF.

It give abstract and general definition to such real world problem:

> we propose a performance model that expresses formally the checkpoint scheduling problem

What I am interestered in:

> In particular, we prove that the checkpoint scheduling problem is NP-hard even in the simple case of uniform failure distribution

simple introduction to checkpoint scheduling problem:

> One of the main problems for this technique is to determine the
> right series of intervals for checkpointing. Indeed, too many checkpoints would increase the time overhead while too few
> checkpoints would lead to a large loss of computation time in case
> of failures. The time when to perform the checkpoints depends
> mainly on two parameters, namely, the volume of data to checkpoint (due to communication times) and the failure arrival time distribution.

The paper develop a formal (means using a lot of fancy mathmatic notations) model for computional execution and failure. Basically the models provides an abstract on failures and computations. Base on these models, author fomulates a description for the scheduling problem in the abstraction level of vectors and integers, integrals, uniform distributions. And then author proposed a dynamic programming algorithm based on some simplifing assumptions.

## #8 人机交互与普适计算

This category is seemingly unrelated with computer science as in TOCHI vol. 27.

> An Activity Centered Approach to Nonvisual Computer Interaction

This paper studies UI specific to blind and low-vision computer users. Damn, I don't give a fuck to those blind people, who cares?

> Countdown Timer Speed: A Trade-off between Delay Duration Perception and Recall

Tweak the progree bar to make it seems moving faster in order to increase satisfactory or decrease annoyance (in case of advertisements).

> The Unexpected Downside of Paying or Sending Messages to People to Make Them Walk: Comparing Tangible Rewards and Motivational Messages to Improve Physical Activity

By the article title, there is nothing to do with computers. Authors conducted 10 months of experiments on 208 participants, which is truly remarkable undertaking. Interestingly, this paper concludes that such persuasive techniques actually decrease the intrinsic motivation of the participants. I would say that's counterintutive, are all those "exercise" apps doing it in vain?

> Engagement by Design: An Empirical Study of the “Reactions” Feature on Facebook Business Pages

Facebook reactions, crap, is this even “科研“？

> Collection of Metaphors for Human-Robot Interaction
>
> Abstract:
>
> The word "robot" frequently conjures unrealistic expectations of utilitarian perfection: tireless, efficient, and flawless agents. However, real-world robots are far from perfect—they fail and make mistakes. Thus, roboticists should consider altering their current assumptions and cultivating new perspectives that account for a more complete range of robot roles, behaviors, and interactions. To encourage this, we explore the use of metaphors for generating novel ideas and reframing existing problems, eliciting new perspectives of human-robot interaction. Our work makes two contributions. We (1) surface current assumptions that accompany the term "robots," and (2) present a collection of alternative perspectives of interaction with robots through metaphors. By identifying assumptions, we provide a comprehensible list of aspects to reconsider regarding robots’ physicality, roles, and behaviors. Through metaphors, we propose new ways of examining how we can use, relate to, and co-exist with the robots that will share our future.

我也是醉了，这搞的啥啊。

## #5

> Scalable Termination Detection for Distributed Actor Systems

This paper solves real-world problem in distributed systems. That is Garbage collection of actor instances in a distributed actor system. Plenty of mathmatic notations and logical proof are used in the paper.

it's Very Very abstract. There is this conference called concurency, but I am not familiar with most of the nonus appear in proceeding titles.

> Monte Carlo Tree Search Guided by Symbolic Advice for MDPs
>
> Abstract:
>
> In this paper, we consider the online computation of a strategy that aims at optimizing the expected average reward in a Markov decision process. The strategy is computed with a receding horizon and using Monte Carlo tree search (MCTS). We augment the MCTS algorithm with the notion of symbolic advice, and show that its classical theoretical guarantees are maintained. Symbolic advice are used to bias the selection and simulation strategies of MCTS. We describe how to use QBF and SAT solvers to implement symbolic advice in an efficient way. We illustrate our new algorithm using the popular game Pac-Man and show that the performances of our algorithm exceed those of plain MCTS as well as the performances of human players.

I don't how this is related to concurrency.

There is this journal called Algorithmica. This is actually pretty cool, most paper focus on tangible and concrete algorithm just like those we are taught in universities.

> Sort Real Numbers in $$O(n\sqrt{logn})$$ Time and Linear Space

This paper converts real numbers to integers then use non comparison based algorithm to sort them thus break the illusion that real numbers have to be sorted by comparison sorting. The author give no implementations.
