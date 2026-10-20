---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "提升法"
  - "Boosting Methods"
---
# 什么是Boosting

**Boosting**（提升法）是一类逐步构建加性集成模型的方法：新增学习器依据当前模型的不足或优化目标进行训练，再与已有模型组合。[[AdaBoost]]通过样本权重突出难分样本，[[梯度提升决策树]]通过损失梯度确定后续学习方向。它与多模型独立训练后聚合的 [[Bagging]] 有不同训练机制。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/ensemble.html)。

