---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "Bootstrap Aggregating"
  - "装袋法"
---
# 什么是Bagging

**Bagging**（Bootstrap Aggregating）是一种在多个重采样数据集上分别训练学习器，再聚合预测的[[集成学习]]策略。经典做法使用[[自助采样]]，回归时常取平均，分类时可聚合类别概率或投票。它常用于降低高方差模型的预测波动，[[随机森林]]是加入特征随机性的相关树集成方法。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.BaggingClassifier.html)。

