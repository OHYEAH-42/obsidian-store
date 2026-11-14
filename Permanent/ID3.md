---
date: 2026-10-23
tags:
  - 机器学习
cssclasses:
aliases:
  - "Iterative Dichotomiser 3"
  - "ID3算法"
---
# 什么是ID3

**ID3**（Iterative Dichotomiser 3）是一种自顶向下、递归构造[[分类决策树]]的算法。它在每个节点用[[贪心算法|贪心]]方式选择[[信息增益]]最大的候选属性，再按该属性的取值划分样本。

在特征取值完整、样本等权的经典离散特征情形下：

$$
a^*\in\operatorname*{arg\,max}_{a\in\mathcal A}
\operatorname{Gain}(D,a)
$$

其中 $D$ 为当前节点的非空样本集，$\mathcal A$ 为当前可用的候选属性集合，$\operatorname{Gain}(D,a)$ 是按属性 $a$ 的取值划分后，类别熵的下降量；并列时需约定选择规则。

经典 ID3 主要面向离散特征与离散类别标签，可生成多叉树；名称中的 “Dichotomiser” 不意味着每个节点只能有两个分支。连续特征和缺失值需要预处理或算法扩展，不能直接把基本 ID3 视为包含这些处理的 [[C4.5]]。

ID3 的信息增益可能偏好多值属性；它的目标是分类，不是[[回归决策树]]中的数值预测。

参考：[定义与公式依据](https://hunch.net/~coms-4771/quinlan.pdf)。

