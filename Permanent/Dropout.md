---
date: 2026-10-19
tags:
  - 神经网络
cssclasses:
aliases:
  - "暂退法"
  - "随机失活"
---
# 什么是Dropout

**Dropout** 是训练时随机将部分[[激活值]]置零的[[正则化]]方法，用于降低模型对特定内部连接组合的依赖、改善[[泛化能力]]。它不是永久删除[[神经元]]或参数。

常见的反向缩放实现为：

$$
\widetilde{\boldsymbol{h}}=
\frac{\boldsymbol{m}\odot\boldsymbol{h}}{1-p},
\qquad m_i\sim\operatorname{Bernoulli}(1-p),\quad 0\le p<1
$$

其中 $\boldsymbol{h}$ 为输入激活向量，$p$ 为丢弃概率；各 $m_i$ 独立采样，以概率 $1-p$ 取 $1$、以概率 $p$ 取 $0$，$\odot$ 表示逐元素相乘。除以 $1-p$ 使每个输出分量在给定输入时的期望等于原输入。使用这种实现时，[[推理（机器学习）|推理]]阶段关闭随机丢弃并直接传递激活值，不再缩放。

Dropout 的比例是[[超参数]]，并非越大越好。

参考：[定义与方法来源](https://d2l.ai/chapter_multilayer-perceptrons/dropout.html)。

