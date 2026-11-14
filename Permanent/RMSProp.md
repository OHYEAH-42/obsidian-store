---
date: 2026-10-26
tags:
  - 神经网络
cssclasses:
aliases:
  - RMSprop
  - Root Mean Square Propagation
---
# 什么是RMSProp

**RMSProp** 是维护梯度平方的[[指数移动平均]]，再用其平方根缩放当前梯度的自适应[[优化器]]。它按参数分量分别调整更新尺度：近期梯度平方较大的分量，更新时使用较大的归一化分母。

以不含动量、非中心化且不含额外正则项的基本版本为例，令 $\boldsymbol{v}_0=\boldsymbol{0}$，采用 [[PyTorch]] 将稳定项放在平方根外的约定：

$$
\begin{aligned}
\boldsymbol{g}_t&=\nabla_\theta L_{B_t}(\theta_{t-1}),\\
\boldsymbol{v}_t&=\rho\boldsymbol{v}_{t-1}
+(1-\rho)(\boldsymbol{g}_t\odot\boldsymbol{g}_t),\\
\theta_t&=\theta_{t-1}
-\eta_t\frac{\boldsymbol{g}_t}{\sqrt{\boldsymbol{v}_t}+\epsilon}.
\end{aligned}
$$

其中 $t\ge1$ 为更新步，$L_{B_t}$ 为当前批次的平均[[损失函数|损失]]，$\boldsymbol{g}_t$ 为其梯度，$\theta_{t-1},\theta_t$ 为更新前后的参数；$\rho\in[0,1)$ 为历史保留系数，$\eta_t\ge0$ 为[[学习率]]，$\epsilon>0$ 为数值稳定项。$\odot$、平方根和除法均按分量计算，$\boldsymbol{v}_t$ 估计梯度的二阶[[原点矩]]，不是中心化后的[[方差]]。

基本版本通常不作 [[Adam]] 那样的零初始化偏差修正，也不平滑分子中的梯度。不同实现可能将 $\epsilon$ 放在平方根内，或加入动量、中心化等选项，比较公式时需要区分版本。RMSProp 缩放的是参数更新，[[RMSNorm]]缩放的是网络中的激活表示，二者不是同一操作。

与[[AdaGrad]]相比，RMSProp 将“所有历史梯度的平方和”改成指数移动平均，使旧梯度的权重逐渐减小。这样可以避免单纯因历史平方和一直累积而持续压低更新尺度；其分母仍随梯度变化，更新尺度也不保证固定或单调变化。

参考：[PyTorch：RMSprop 的更新公式与数值约定](https://docs.pytorch.org/docs/2.14/generated/torch.optim.RMSprop.html)。

与 AdaGrad 的关系参考：[《动手学深度学习》：RMSProp](https://d2l.ai/chapter_optimization/rmsprop.html)。
