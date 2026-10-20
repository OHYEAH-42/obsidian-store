---
date: 2026-10-19
tags:
  - 机器学习
cssclasses:
aliases:
  - "Lasso"
  - "Lasso Regression"
  - "L1正则化回归"
---
# 什么是Lasso回归

**Lasso 回归**是在[[线性回归]]的平方误差目标上加入 L1 [[正则化]]的方法。一种常用约定为：

$$
\min_{\boldsymbol w,b}
\frac1n\sum_{i=1}^n(y_i-\boldsymbol w^{\mathsf T}\boldsymbol x_i-b)^2
+\lambda\sum_{j=1}^d|w_j|
$$

$n,d$ 是样本数和特征数，$\boldsymbol w,b$ 是参数，$\lambda\ge0$ 控制惩罚强度；此处不惩罚 $b$。L1 惩罚可以把部分系数压为零，从而产生稀疏模型并起到[[特征选择]]的作用，但被选中的特征不必然具有因果意义。

参考：[定义与公式来源](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.Lasso.html)。

