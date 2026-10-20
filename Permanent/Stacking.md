---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "Stacked Generalization"
  - "堆叠泛化"
---
# 什么是Stacking

**Stacking**（堆叠泛化）是先训练多个基础模型，再把这些模型的预测作为输入训练组合模型的[[集成学习]]策略。为减少[[数据泄漏]]，组合模型通常使用[[交叉验证]]得到的折外预测训练，即每个样本的基础预测来自未用该样本训练的模型；直接使用基础模型对自身训练样本的拟合结果可能过于乐观。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.StackingClassifier.html)。

