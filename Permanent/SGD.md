---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "随机梯度下降"
  - "Stochastic Gradient Descent"
---
# 什么是SGD

**SGD**（Stochastic Gradient Descent，随机梯度下降）是一类用随机抽取的数据估计目标[[梯度]]、据此更新参数的[[优化器|优化方法]]。严格的单样本 SGD 每次使用一个样本；实践中也常将使用小批量平均梯度的版本称为 SGD。“随机”主要指样本选择，而不是随意决定参数更新方向。

不含动量和额外正则项的基本形式为：

$$
\boldsymbol{g}_t=
\frac{1}{|B_t|}\sum_{i\in B_t}
\nabla_w \ell_i(w_{t-1}),
\qquad
w_t=w_{t-1}-\eta_t\boldsymbol{g}_t
$$

-  $t=1,2,\ldots$ 为更新步
- $B_t$ 为该步选取的样本集合
- $|B_t|$ 为其[[批量大小]]
- $\ell_i$ 为第 $i$ 个样本的[[损失函数|损失]]
- $w_{t-1}$、$w_t$ 为更新前后的权重参数；若同时优化偏置，也可将其包含在 $w$ 中
- $\boldsymbol{g}_t$ 为估计梯度
- $\eta_t\ge0$ 为[[学习率]]
$|B_t|=1$ 时就是单样本更新。
若该步只随机选取样本 $i_t$，上式简化为：

$$
\boldsymbol{g}_t=\nabla_w\ell_{i_t}(w_{t-1}),
\qquad
w_t=w_{t-1}-\eta_t\boldsymbol{g}_t.
$$

对含 $N$ 个样本的训练集，使用全部样本的是[[批量梯度下降|Batch GD]]，使用中间大小批次的是[[小批量随机梯度下降|Mini-batch SGD]]。在固定参数、各样本损失可分别求导且均匀随机抽样的条件下，单样本梯度的期望等于全训练集平均损失的梯度；这不保证一次随机更新就使全训练集损失下降。

基本 SGD 直接使用当前梯度；加入[[动量（优化）|动量]]后会保留历史更新信息，两者不能混为同一条公式。[[PyTorch]]的 SGD 接口可以配置是否使用动量。

参考：[随机梯度下降](https://d2l.ai/chapter_optimization/sgd.html)、[小批量随机梯度下降](https://d2l.ai/chapter_optimization/minibatch-sgd.html)、[PyTorch：SGD 与可选动量](https://docs.pytorch.org/docs/2.14/generated/torch.optim.SGD.html)。

