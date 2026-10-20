---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "Tensor Cores"
  - "张量核心"
---
# 什么是Tensor Core

**Tensor Core**（张量核心）是 NVIDIA GPU 中用于加速矩阵乘加等运算的专用计算单元，其典型计算可表示为：

$$
D=AB+C
$$

其中 $A,B$ 为相容维度的输入矩阵，$C$ 为累加输入，$D$ 为结果。它批量执行矩阵乘加，而不是某一种[[张量]]数据类型。

不同代际支持的输入格式和累加精度不同。例如，一些路径使用[[FP16]]或[[BF16]]输入并以[[FP32]]累加，支持的设备还可使用 [[TF32]] 等格式。Tensor Core 的名称不表示任意张量运算都会自动使用它；是否调用以及实际收益取决于硬件、数据类型、形状和软件实现。

参考：[定义与数值格式来源](https://docs.nvidia.com/deeplearning/performance/mixed-precision-training/index.html#tensor-core-math)。

