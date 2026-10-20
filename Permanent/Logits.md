---
date: 2026-10-19
tags:
  - 神经网络
cssclasses:
aliases:
---
# 什么是Logits

**Logits** 是分类模型或[[语言模型]]在概率归一化之前，为各个候选类别或词元输出的原始实数分数。它们可为正数或负数，彼此之和不必为 $1$，因此不是概率。

对一组互斥候选的分数向量 $\boldsymbol{z}$，通常通过 [[激活函数#Softmax|Softmax]] 得到概率：

$$
p_i=\frac{\exp(z_i)}{\sum_{j=1}^{V}\exp(z_j)}
$$

其中 $z_i$ 是第 $i$ 个候选的 logit，$V$ 为候选数量，$p_i$ 是对应概率。模型常用最后的[[线性层]]产生这些分数；生成时，[[温度参数]]可先缩放 logits，再进行概率计算与[[文本生成采样|采样]]。

这里指分类输出分数，不应将其与单个概率的 logit 变换 $\log\frac{p}{1-p}$ 混为一谈。

参考：[定义与方法来源](https://huggingface.co/docs/transformers/main/en/internal/generation_utils#transformers.LogitsProcessor)。

