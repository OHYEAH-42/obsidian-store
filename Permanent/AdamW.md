---
date: 2026-10-26
tags:
  - 神经网络
cssclasses:
aliases:
  - Adam with Decoupled Weight Decay
  - AdamW优化器
---
# 什么是AdamW

**AdamW** 是将 [[Adam]] 的自适应梯度更新与[[Weight Decay|权重衰减]]分开执行的[[优化器]]。它的“解耦”表示权重衰减项不进入梯度的一阶、二阶矩统计，也不经过 Adam 的逐参数自适应除法。

以下以需要衰减的权重 $w$ 为例，令 $w_0$ 为初始权重，$\boldsymbol{m}_0=\boldsymbol{v}_0=\boldsymbol{0}$，不使用 AMSGrad 等额外变体时：

$$
\begin{aligned}
\boldsymbol{g}_t&=\nabla_w L_{B_t}(w_{t-1}),\\
\boldsymbol{m}_t&=\beta_1\boldsymbol{m}_{t-1}
+(1-\beta_1)\boldsymbol{g}_t,\\
\boldsymbol{v}_t&=\beta_2\boldsymbol{v}_{t-1}
+(1-\beta_2)(\boldsymbol{g}_t\odot\boldsymbol{g}_t),\\
\widehat{\boldsymbol{m}}_t&=\frac{\boldsymbol{m}_t}{1-\beta_1^t},
\qquad
\widehat{\boldsymbol{v}}_t=\frac{\boldsymbol{v}_t}{1-\beta_2^t},\\
w_t&=(1-\eta_t\lambda)w_{t-1}
-\eta_t\frac{\widehat{\boldsymbol{m}}_t}
{\sqrt{\widehat{\boldsymbol{v}}_t}+\epsilon}.
\end{aligned}
$$

- $w_{t-1},w_t$：更新前、更新后的权重；$w_0$ 为初始权重。
- $t$：从 $1$ 开始的参数更新步编号。
- $L_{B_t}$：当前小批量 $B_t$ 上的数据平均损失；$\boldsymbol{g}_t$ 为其对权重 $w$ 的梯度，在更新前的 $w_{t-1}$ 处计算，不包含这里单独施加的权重衰减。
- $\boldsymbol{m}_t$：梯度的一阶矩平滑估计，通过[[指数移动平均]]反映近期梯度的平均方向，具有动量作用。
- $\boldsymbol{v}_t$：梯度平方的平滑估计，是二阶原点矩估计，不是减去均值后的方差。
- $\beta_1,\beta_2\in[0,1)$：分别控制两组历史统计的衰减；$\beta_1^t,\beta_2^t$ 中的 $t$ 表示乘方次数。
- $\widehat{\boldsymbol{m}}_t,\widehat{\boldsymbol{v}}_t$：经过偏差修正的统计，减轻零初始化造成的早期偏小。
- $\eta_t\ge0$：[[学习率]]；$\epsilon>0$：避免分母为零、改善数值稳定性的小常数。
- $\lambda\ge0$：权重衰减系数；$1-\eta_t\lambda$ 为每步施加到旧权重上的衰减因子。
- $\boldsymbol{m}_0,\boldsymbol{v}_0$：初始时均为零的一阶、二阶矩状态。
- $\odot$：逐元素乘法；平方、平方根和除法也按分量分别计算，$\epsilon$ 在平方根之外。

若仅在数据损失上增加 $\frac{\lambda}{2}\lVert w\rVert_2^2$ 的[[L2正则化|L2 惩罚]]，其中 $\lVert w\rVert_2$ 为权重向量的[[L2范数]]，其梯度 $\lambda w$ 会进入 Adam 的矩统计，一般不等价于上述更新。AdamW 的“解耦”不表示衰减量完全不依赖学习率：这里每步的衰减因子仍为 $1-\eta_t\lambda$。当 $\lambda=0$ 且其余约定相同时，退化为标准 Adam。

参考：[Decoupled Weight Decay Regularization](https://arxiv.org/abs/1711.05101)、[PyTorch：AdamW 更新公式](https://docs.pytorch.org/docs/2.14/generated/torch.optim.AdamW.html)。

# 解决了[[Adam#Adam的问题]]

解耦（Decoupling）就是把原本混合在一起的两个操作分开处理，让它们互不干扰。
从上面$w_t$的式子就可以看出端倪了：
$$
{ w_t= \underbrace{(1-\eta\lambda)w_{t-1}}_{\text{独立权重衰减}} - \underbrace{\eta\frac{\hat m_t}{\sqrt{\hat v_t}+\epsilon}}_{\text{Adam 梯度更新}} }
$$
[[L2正则化]]中利用$(1-\eta_t\lambda)\boldsymbol{w}_{t-1}$
而[[Adam]]利用${ w_t=w_{t-1} -\eta_t\frac{\hat m_t}{\sqrt{\hat v_t}+\epsilon} }$