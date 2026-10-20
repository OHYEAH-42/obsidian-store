---
date: 2026-10-19
tags:
  - 神经网络
cssclasses:
aliases:
  - "Top-P"
  - "Top-p Sampling"
  - "Nucleus Sampling"
  - "核采样"
  - "top_p"
---
# 什么是Top-P采样

**Top-P 采样**（Nucleus Sampling，核采样）是[[文本生成采样]]中按累计概率截断分布的方法：将候选词元按概率降序排列，保留累计概率首次达到或超过阈值的最短前缀，再重新归一化并采样。它既不是固定保留前百分之几的词元，也不是要求单个词元的概率高于阈值。

设排序后概率为 $p_{(1)}\ge\cdots\ge p_{(V)}$，阈值记为 $\rho$，以免与概率符号混淆：

$$
m=\min\left\{r\in\{1,\ldots,V\}:\sum_{j=1}^{r}p_{(j)}\ge\rho\right\},
\qquad 0<\rho\le1
$$

令 $S_\rho$ 为这前 $m$ 个词元组成的集合，截断后的分布为：

$$
q_i=
\begin{cases}
\dfrac{p_i}{\sum_{j\in S_\rho}p_j},&i\in S_\rho,\\
0,&i\notin S_\rho.
\end{cases}
$$

其中 $V$ 为词表大小，$p_i$ 为当前概率，$q_i$ 为最终采样概率。必须保留使累计概率越过阈值的那个词元；概率并列时应约定排序规则。

与[[Top-K采样]]相比，Top-P 的候选数量会随当前分布动态变化；$\rho=1$ 不丢弃任何有正概率的候选。[[温度参数]]改变分布后，也可能改变达到同一阈值所需的候选数量。

参考：[定义与方法来源](https://arxiv.org/html/1904.09751v2)。

