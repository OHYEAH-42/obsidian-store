---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
---
# 什么是PyTorch

**PyTorch** 是以[[张量]]计算和[[自动微分]]为基础的开源机器学习框架，常通过 Python 接口构建、训练和运行[[神经网络]]，并支持在 CPU 和 GPU 等设备上执行计算。它是实现模型的软件工具，不是像 MLP、CNN 或 Transformer 那样的模型架构，也不是一种学习算法。

在其基本组织中，`Tensor` 表示数据与参数；`torch.autograd` 根据[[计算图]]求导；[[nn.Module]]组织网络层、参数与[[前向传播]]；`torch.optim` 提供[[优化器]]；[[Dataset（PyTorch）|Dataset]]定义样本访问，[[DataLoader]]负责迭代取数和组批。

训练时，模型计算输出，[[损失函数]]形成优化目标，反向传播计算梯度，再由优化器更新参数。PyTorch 也提供[[自动混合精度]]等机制，但是否使用及其具体配置取决于任务和设备。

默认即时执行模式下，求导图随实际运算动态建立；这不意味着 PyTorch 只能逐条解释执行，它也支持编译优化等执行方式。

参考：[PyTorch 基础教程](https://docs.pytorch.org/tutorials/beginner/basics/intro.html)、[自动微分与动态计算图](https://docs.pytorch.org/tutorials/beginner/basics/autogradqs_tutorial.html)、[编译执行简介](https://docs.pytorch.org/tutorials/intermediate/torch_compile_tutorial.html)。

