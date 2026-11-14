---
date: 2026-10-20
tags:
  - 机器学习
aliases:
  - 权重衰减
cssclasses:
---
# 定义

权重衰减通常在参数更新时对权重进行缩小。
一种形式是：
$$
w_{t+1}=(1-\eta\lambda)w_t-\eta g_t 
$$
其中 $w_t$ 是更新前的权重，$t$ 为更新步，$\eta\ge0$ 是[[学习率]]，$g_t$ 是任务损失对权重的梯度，$\lambda\ge0$ 是衰减系数。若 $0<\eta\lambda<1$，衰减项本身将权重乘以一个介于 $0$ 与 $1$ 之间的系数；完整更新还包含梯度项，因此权重绝对值不一定每步减小。
在普通 [[SGD]] 下，适当对应系数后，[[L2正则化|L2 正则化]]和 Weight Decay 可以等价。
但是在 [[Adam]] 中，两者不完全等价。
因此现代深度学习经常使用 [[AdamW]]，它把 Weight Decay 和梯度更新解耦。

参考：[Decoupled Weight Decay Regularization](https://arxiv.org/abs/1711.05101)。
