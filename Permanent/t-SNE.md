---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "t-distributed Stochastic Neighbor Embedding"
  - "t分布随机邻域嵌入"
---
# 什么是t-SNE

**t-SNE** 是一种侧重保留局部邻域关系的非线性[[降维]]方法，常把高维数据嵌入二维或三维用于可视化。它通过优化高低维邻域分布之间的差异安排位置；图中簇间距离、簇面积和空白区域不能直接解释成原数据的全局距离或真实簇规模，结果也会受参数与随机初始化影响。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/manifold.html#t-sne)。

