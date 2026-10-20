---
date: 2026-10-19
tags:
  - 神经网络
cssclasses:
aliases:
  - "Top-K"
  - "Top-k Sampling"
  - "top_k"
---
# 什么是Top-K采样

**Top-K 采样**是[[文本生成采样]]中按候选数量截断分布的方法：每一步只保留概率最高的 $k$ 个词元，将其余词元的概率设为零，再对保留部分重新归一化并随机抽取下一个词元。它不是在前 $k$ 个候选中等概率抽取。

设词表大小为 $V$，当前分布为 $p_i$，$S_k$ 为概率最高的 $k$ 个词元构成的集合，$1\le k\le V$，则：

$$
q_i=
\begin{cases}
\dfrac{p_i}{\sum_{j\in S_k}p_j},&i\in S_k,\\
0,&i\notin S_k.
\end{cases}
$$

其中 $q_i$ 是截断后的采样概率，$i,j$ 是词元编号，保留集合的总概率须大于零。概率并列时需要约定边界处理规则；有些实现保留全部边界并列项，实际数量可能超过 $k$。

在恰好保留一个最高概率候选的约定下，$k=1$ 等价于[[贪心解码]]；$k=V$ 不进行数量截断。与[[Top-P采样]]不同，$k$ 固定的是候选数量，而不是累计概率。

参考：[定义与方法来源](https://huggingface.co/docs/transformers/main/en/internal/generation_utils#transformers.TopKLogitsWarper)。

