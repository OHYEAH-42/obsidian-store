---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "Adaptive Boosting"
  - "自适应提升"
---
# 什么是AdaBoost

**AdaBoost**（Adaptive Boosting）是一种逐轮调整样本权重、突出前轮误分样本的 [[Boosting]] 方法。经典二分类预测为：

$$
\hat y(\boldsymbol x)=\operatorname{sign}\left(\sum_{m=1}^M\alpha_m h_m(\boldsymbol x)\right)
$$

其中 $h_m$ 是输出 $\{-1,1\}$ 的第 $m$ 个分类器，$\alpha_m$ 是其组合权重，$M$ 为成员数量。通常使用浅决策树作为成员；对噪声或错误标签的持续关注也可能影响表现。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.AdaBoostClassifier.html)。

