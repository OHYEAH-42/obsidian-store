---
date: 2026-10-23
tags:
  - 机器学习
cssclasses:
aliases:
  - "Classification and Regression Trees"
  - "分类与回归树"
  - "CART算法"
---
# 什么是CART

**CART**（Classification and Regression Trees，分类与回归树）是一套既能构造[[分类决策树]]、也能构造[[回归决策树]]的方法。它递归地将节点分成两个子节点，形成二叉树，并通常结合[[代价复杂度剪枝]]控制树的复杂度。

对当前非空样本集 $D$，候选二分测试 $s$ 产生非空左右子集 $D_L,D_R$。等权样本下，可用以下形式表示贪心划分目标：

$$
s^*\in\operatorname*{arg\,min}_{s\in\mathcal S}
\left[
\frac{|D_L|}{|D|}I(D_L)
+\frac{|D_R|}{|D|}I(D_R)
\right]
$$

其中 $\mathcal S$ 为允许的候选测试集合，$|D_L|+|D_R|=|D|$，$I$ 为与任务相适应的节点准则。对固定父节点，最小化子节点加权准则，也就是最大化该准则相对父节点的下降量。

经典分类 CART 常使用[[基尼不纯度]]；平方误差回归 CART 使用节点内目标值的均方偏差，叶节点预测均值，此时上式等价于最小化左右子节点的平方误差总和。

连续特征可按阈值二分，类别特征在理论上也可按类别子集二分；某个软件是否原生支持类别特征取决于实现。基于 CART 的实现也可能提供熵等其他准则，因此不能仅凭“使用熵”就认定它是 ID3，也不能把 CART 限定为只能做分类。

参考：[定义与公式依据](https://scikit-learn.org/stable/modules/tree.html#mathematical-formulation)。

