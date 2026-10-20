---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "torch.utils.data.Dataset"
  - "PyTorch Dataset"
---
# 什么是Dataset（PyTorch）

**Dataset** 是 [[PyTorch]] 中描述如何访问数据样本的抽象接口。它把“一个样本是什么、如何读出与处理”封装起来，与模型及训练循环分离；不要求一次将全部数据载入内存。

常见的映射式 Dataset 通过 `__getitem__` 根据索引或键返回样本，通常通过 `__len__` 提供样本数量。样本可以包含输入、目标或其他字段，具体由任务决定，并不要求始终有人为标注的标签。

[[DataLoader]]在此基础上负责迭代访问和组批。Dataset 本身不等同于[[训练集]]：训练集、验证集或测试集都可以用相应的 Dataset 对象表示。

参考：[PyTorch 官方文档](https://docs.pytorch.org/tutorials/beginner/basics/data_tutorial.html)。

