---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "Density-Based Spatial Clustering of Applications with Noise"
  - "基于密度的聚类"
---
# 什么是DBSCAN

**DBSCAN** 是根据局部密度连接样本的[[聚类]]方法。它用邻域半径 ε 与最小邻域样本数 min_samples 定义核心点，再连接密度可达的区域，并把不属于簇的部分样本标为噪声。它不必预先指定簇数，能够发现非球形簇，但对距离尺度、参数和簇间密度差异敏感。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/clustering.html#dbscan)。

