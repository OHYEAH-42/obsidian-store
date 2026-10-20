---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "K-Means"
  - "KMeans"
  - "K均值聚类"
---
# 什么是K-Means聚类

**K-Means 聚类**是一种预先指定簇数 K、通过样本到簇中心的平方距离划分数据的[[聚类]]方法：

$$
\min_{C_1,\ldots,C_K}\sum_{k=1}^K\sum_{\boldsymbol x_i\in C_k}
\|\boldsymbol x_i-\boldsymbol\mu_k\|_2^2
$$

$C_k$ 是第 k 个簇，$\boldsymbol\mu_k$ 是该簇样本均值。算法交替进行分配与更新中心，结果受特征尺度和初始中心影响；它偏好较紧凑的簇，不保证找到全局最优划分。

参考：[定义与方法来源](https://scikit-learn.org/stable/modules/clustering.html#k-means)。

