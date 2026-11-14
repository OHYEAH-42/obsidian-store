---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "Adaptive Moment Estimation"
  - "Adam优化器"
---
# 什么是Adam

**Adam**（Adaptive Moment Estimation）是一种将梯度的方向平滑与逐参数自适应尺度调整结合的[[优化器]]。它对梯度的一阶、二阶[[原点矩]]进行[[指数移动平均]]，再作零初始化偏差修正，据此更新参jj数。

不 $t\ge1$ 步有：

$$
\begin{aligned}
\boldsymbol{g}_t&=\nabla_w L_{B_t}(w_{t-1}),\\
\boldsymbol{m}_t&=\beta_1\boldsymbol{m}_{t-1}
+(1-\beta_1)\boldsymbol{g}_t,\\
\boldsymbol{v}_t&=\beta_2\boldsymbol{v}_{t-1}
+(1-\beta_2)(\boldsymbol{g}_t\odot\boldsymbol{g}_t),\\
\widehat{\boldsymbol{m}}_t&=
\frac{\boldsymbol{m}_t}{1-\beta_1^t},
\qquad
\widehat{\boldsymbol{v}}_t=
\frac{\boldsymbol{v}_t}{1-\beta_2^t},\\
w_t&=w_{t-1}
-\eta_t\frac{\widehat{\boldsymbol{m}}_t}
{\sqrt{\widehat{\boldsymbol{v}}_t}+\epsilon}.
\end{aligned}
$$

- $w_{t-1},w_t$：更新前、更新后的权重；$w_0$ 为初始权重。
- $t$：从 $1$ 开始的参数更新步编号。
- $L_{B_t}$：当前小批量 $B_t$ 上的平均[[损失函数|损失]]；$\boldsymbol{g}_t$ 为其对权重 $w$ 的梯度，在更新前的 $w_{t-1}$ 处计算。
- $\boldsymbol{m}_t$：梯度的一阶矩平滑估计，反映近期梯度的平均方向，具有[[动量（优化）|动量]]作用。
- $\boldsymbol{v}_t$：梯度平方的平滑估计，是二阶原点矩估计，不是减去均值后的[[方差]]。
- $\beta_1,\beta_2\in[0,1)$：分别控制两组历史统计的衰减；$\beta_1^t,\beta_2^t$ 中的 $t$ 表示乘方次数。
- $\widehat{\boldsymbol{m}}_t,\widehat{\boldsymbol{v}}_t$：经过偏差修正的统计，减轻零初始化造成的早期偏小。
- $\eta_t\ge0$：[[学习率]]；$\epsilon>0$：避免分母为零、改善数值稳定性的小常数。
- $\boldsymbol{m}_0,\boldsymbol{v}_0$：初始时均为零的一阶、二阶矩状态。
- $\odot$：逐元素乘法；平方根和最后的除法也按参数分量分别计算，$\epsilon$ 在平方根之外。

偏置用 $b$（bias）表示，也按相同的 Adam 规则更新：计算损失对 $b$ 的梯度，并为偏置单独维护对应的一阶、二阶矩状态。

“自适应”指不同参数分量使用不同的归一化更新尺度，并不表示不需要设置学习率，也不保证一定优于[[SGD]]或找到全局最优解。

与基本[[RMSProp]]相比，Adam 还平滑梯度的一阶矩，并对一阶、二阶矩作零初始化偏差修正，不能把两者视为完全相同的算法。[[AdamW]]沿用这里的矩估计，但在自适应更新之外单独施加[[Weight Decay|权重衰减]]；将 L2 惩罚的梯度直接加入 Adam 的输入梯度，一般不等价于 AdamW。

参考：[Adam 原论文](https://arxiv.org/abs/1412.6980)、[PyTorch：Adam 更新公式](https://docs.pytorch.org/docs/2.14/generated/torch.optim.Adam.html)。

权重衰减区别参考：[Decoupled Weight Decay Regularization](https://arxiv.org/abs/1711.05101)。

# 理解

Adam结合了 [[动量（优化）|Momentum]] 的动量思想与 [[RMSProp]] 的自适应学习率思想，同时借鉴了 [[Adagrad]] 利用历史梯度信息调整学习率的方法。
- 一阶矩 \(m_t\)：记录历史梯度的指数移动平均，估计更新方向。
- 二阶矩 \(v_t\)：记录历史梯度平方的指数移动平均，用于调整更新幅度。
- 偏差修正：修正两个移动平均在训练初期因初始化为零而产生的偏差。

## [[动量（优化）|Momentum]](一阶矩)

$$
\begin{aligned}
\boldsymbol{m}_t&=\beta_1\boldsymbol{m}_{t-1}
+(1-\beta_1)\boldsymbol{g}_t
\end{aligned}
$$
- $t$：从 $1$ 开始的参数更新步编号。
- $\boldsymbol{m}_t$：梯度的一阶矩平滑估计，反映近期梯度的平均方向，具有[[动量（优化）|动量]]作用。
- $\boldsymbol{m}_t-1$：上一次的一阶矩估计
- $g_t$：当前梯度
- $\beta_1$：历史信息的保留系数
Adam通常让$\beta_1=0.9$，于是，上面的式子就可以理解为：保留 90% 的上一时刻一阶矩、混入 10% 的当前梯度。

一阶矩主要解决的是：
**如何综合历史梯度，使更新方向更加平滑。**

## [[RMSProp]](二阶矩)

$$
v_t=\beta_2v_{t-1}+(1-\beta_2)g_t^2
$$
- $\boldsymbol{v}_t$：梯度平方的平滑估计，是二阶原点矩估计，不是减去均值后的[[方差]]。
可以发现和一阶矩特别像，只是变量进行了平方，这样就能消除正负号影响，记录不同参数的**历史梯度尺寸**，也就是大小

## 偏差修正

Adam 的一阶矩和二阶矩通常初始化为：$m_0=0,\qquad v_0=0$
在第一次更新的时候：$m_1=0.9\times0+0.1g_1$，得到$m_1=0.1g_1$
显然，一开始计算出的一阶矩受零初始化影响，数值偏小，二阶矩同理
因此需要偏差修正:
$$
{ \hat m_t=\frac{m_t}{1-\beta_1^t} }\qquad
{ \hat v_t=\frac{v_t}{1-\beta_2^t} } 
$$
偏差修正主要是补偿指数移动平均在训练初期受到零初始化的影响

## 梯度下降的参数更新

$$
{ w_t=w_{t-1} -\eta_t\frac{\hat m_t}{\sqrt{\hat v_t}+\epsilon} }
$$


![[Pasted image 20261026205828.png]]

# Adam的问题

当我们把[[L2正则化]]引入Adam后会发生问题：
L2正则化中，正则化对梯度的贡献：$g'=g_t+\lambda\boldsymbol{w}.$
由于Adam中，$g'$在一阶矩和二阶矩都参与了计算，这意味着正则化的修改在Adam中产生了额外的梯度，也会参与Adam的历史梯度累计和自适应缩放。
这正是[[AdamW]]要解决的问题。
