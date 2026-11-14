---
date: 2026-10-23
tags:
  - 神经网络
cssclasses:
aliases:
  - 均方根归一化
  - 均方根层归一化
  - Root Mean Square Layer Normalization
---
# 什么是RMSNorm

**RMSNorm**（Root Mean Square Layer Normalization，均方根归一化）是一种在单个样本内部，沿指定特征维度根据[[均方根]]调整激活值尺度的[[归一化]]方法。与[[层归一化|LayerNorm]]不同，它不先减去特征均值，也不使用中心化后的方差作为归一化依据。

对包含 $d$ 个特征的实向量 $\boldsymbol{x}$，采用带可学习缩放、不含偏置的常见形式：

$$
\operatorname{RMS}(\boldsymbol{x})
=\sqrt{\frac{1}{d}\sum_{j=1}^{d}x_j^2},
\qquad
y_i=\gamma_i
\frac{x_i}{\sqrt{\operatorname{RMS}(\boldsymbol{x})^2+\epsilon}}
$$

等价地：

$$
y_i=\gamma_i
\frac{x_i}{\sqrt{\frac{1}{d}\sum_{j=1}^{d}x_j^2+\epsilon}}
$$

- $d$：参与归一化的特征数量，不是批量大小。
- $x_i,y_i$：第 $i$ 个特征的输入与输出。
- $\gamma_i$：对应特征的可学习缩放参数；不使用可学习缩放时可取 $1$。
- $\epsilon>0$：放在平方根内部的稳定项，避免全零输入等情况下除以零；它不属于均方根本身的定义。

统计量由当前输入的指定特征计算，而不是由整个训练集预先估计。RMSNorm 不进行减均值的中心化，因此不保证输出均值为零，也不能等同于 Z-score [[标准化]]。


参考：[RMSNorm 原论文](https://arxiv.org/abs/1910.07467)、[PyTorch：RMSNorm 定义与公式](https://docs.pytorch.org/docs/2.14/generated/torch.nn.RMSNorm.html)。
