---
date: 2026-10-26
tags:
  - 神经网络
cssclasses:
aliases:
  - Muon优化器
---
# 什么是Muon

**Muon** 是主要面向神经网络矩阵参数的[[优化器]]：先将梯度与历史[[动量（优化）|动量]]结合，再对更新方向作近似正交化。与 [[Adam]] 按参数分量缩放梯度不同，它利用整个矩阵的结构调整更新方向；被正交化的是更新方向，不是强制把权重矩阵本身变成正交矩阵。

以不含额外动量前瞻、不含权重衰减的基本情形为例，令矩阵参数 $W_0\in\mathbb{R}^{m\times n}$，动量 $M_0=0$。用于理解其核心机制的理想化形式为：

$$
\begin{aligned}
G_t&=\nabla_W L_{B_t}(W_{t-1}),\\
M_t&=\mu M_{t-1}+G_t,\\
M_t&=U_r\Sigma_r V_r^{\mathsf T},\\
O_t&=U_rV_r^{\mathsf T},\\
W_t&=W_{t-1}-\eta_t c_{m,n}O_t.
\end{aligned}
$$

其中 $t\ge1$ 为更新步，$L_{B_t}$ 为当前批次的平均损失，$G_t$ 为矩阵梯度，$\mu\in[0,1)$ 为动量系数，$\eta_t\ge0$ 为[[学习率]]。$U_r\Sigma_r V_r^{\mathsf T}$ 是仅保留 $r$ 个非零奇异值的紧致[[奇异值分解]]，$r$ 是 $M_t$ 的秩；$U_r,V_r$ 的列分别单位正交。$c_{m,n}>0$ 是由实现约定的矩阵形状缩放系数，省略形状缩放时取 $1$；若 $M_t=0$，约定 $O_t=0$。

上述理想变换保留奇异向量，将非零奇异值变为 $1$，因此不只是将矩阵除以一个整体长度。矩形或秩不足时，$O_t$ 不一定是通常所说的方形正交矩阵。

实际 Muon 通常通过有限次 Newton–Schulz 矩阵迭代近似这种变换，而不直接执行完整 SVD；有限次迭代的结果不保证严格等于 $U_rV_r^{\mathsf T}$。常见实现还会加入额外的动量前瞻、[[Weight Decay|解耦权重衰减]]及不同的形状缩放约定，上式用于说明核心定义，不能代替所有实现的完整更新规则。

典型用法主要将 Muon 用于隐藏层的二维权重，嵌入、输出头、偏置和归一化参数等常交给 [[AdamW]]；不能只因某个参数是二维矩阵，就认定它必须使用 Muon。

参考：[Muon 作者实现与参数分组说明](https://github.com/KellerJordan/Muon)、[Muon is Scalable for LLM Training，§2.1–2.2](https://arxiv.org/html/2502.16982v1#S2)、[PyTorch：Muon 的实现约定](https://docs.pytorch.org/docs/2.14/generated/torch.optim.Muon.html)。
