---
date: 2026-10-26
tags:
  - 神经网络
cssclasses:
aliases:
  - Adagrad
  - Adaptive Gradient
  - AdaGrad优化器
---
# 什么是AdaGrad

**AdaGrad**（Adaptive Gradient）是一类利用历史梯度信息，按参数方向自适应调整更新尺度的[[优化器]]。常用的对角版本为每个参数分量累计历次梯度的平方，并用累计量的平方根缩放当前梯度。

不含额外正则项和额外学习率衰减时，令 $\boldsymbol{s}_0=\boldsymbol{0}$，采用 [[PyTorch]] 将稳定项放在平方根外的约定：

$$
\begin{aligned}
\boldsymbol{g}_t&=\nabla_\theta L_{B_t}(\theta_{t-1}),\\
\boldsymbol{s}_t&=\boldsymbol{s}_{t-1}
+\boldsymbol{g}_t\odot\boldsymbol{g}_t
=\sum_{\tau=1}^{t}\boldsymbol{g}_\tau\odot\boldsymbol{g}_\tau,\\
\theta_t&=\theta_{t-1}
-\eta\frac{\boldsymbol{g}_t}{\sqrt{\boldsymbol{s}_t}+\epsilon}.
\end{aligned}
$$

- $t\ge1$：参数更新步；$\tau$ 为历史更新步的求和下标。
- $L_{B_t}$：当前批次 $B_t$ 的平均[[损失函数|损失]]；$\boldsymbol{g}_t$ 为其在更新前参数处的[[梯度]]。
- $\theta_{t-1},\theta_t$：更新前后的参数；$\eta>0$ 为基础[[学习率]]，$\epsilon>0$ 为数值稳定项。
- $\boldsymbol{s}_t$：各参数分量的历史梯度平方和，不是梯度的普通累加，也不是中心化后的[[方差]]。
- $\odot$、平方根及除法均按分量计算；这里 $\epsilon$ 在平方根外，也有实现将稳定项放在平方根内，需要区分约定。

对第 $j$ 个参数分量，其梯度前的缩放系数为 $\eta/(\sqrt{s_{t,j}}+\epsilon)$。在基础学习率固定时，$s_{t,j}$ 不会减小，因此这一系数不会增大。历史平方和较小的分量受到的缩小较少，这使 AdaGrad 适合处理一些稀疏特征问题；但不能仅按特征出现次数判断实际更新大小，当前梯度和历史梯度幅度也起作用。

随着平方和持续积累，有些参数的更新尺度可能过早变小，减慢后续学习；这不意味着任意梯度序列都会让步长趋于零。[[RMSProp]]将“全部历史的平方和”改成梯度平方的[[指数移动平均]]，逐渐降低旧梯度的影响；[[Adam]]进一步结合梯度方向的平滑和矩估计的偏差修正。

参考：[AdaGrad 原论文：Adaptive Subgradient Methods for Online Learning and Stochastic Optimization](https://jmlr.org/papers/v12/duchi11a.html)、[PyTorch：Adagrad 更新公式](https://docs.pytorch.org/docs/2.14/generated/torch.optim.Adagrad.html)、[《动手学深度学习》：Adagrad](https://d2l.ai/chapter_optimization/adagrad.html)。
