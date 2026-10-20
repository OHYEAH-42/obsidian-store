---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "torch.utils.data.DataLoader"
  - "数据加载器（PyTorch）"
---
# 什么是DataLoader

**DataLoader** 是 [[PyTorch]] 中围绕数据集提供可迭代数据访问的组件。它依据配置从[[Dataset（PyTorch）|Dataset]]获取样本，可将多个样本整理为批次，也可配合采样、打乱顺序或多进程读取等机制，为训练和评估代码提供输入。

Dataset 定义“如何取得一个样本”，DataLoader 定义“如何组织并交付样本或批次”；它不会自动替模型完成[[前向传播]]、求导或参数更新。

是否组批、[[批量大小]]、是否打乱及使用多少读取进程由具体配置决定。DataLoader 也不意味着数据已经被移动到 GPU，设备迁移通常仍需由程序或上层框架明确处理。

参考：[PyTorch 官方文档](https://docs.pytorch.org/docs/2.14/data.html)。

