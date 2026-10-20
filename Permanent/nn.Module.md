---
date: 2026-10-20
tags:
  - 神经网络
cssclasses:
aliases:
  - "torch.nn.Module"
  - "PyTorch模块"
---
# 什么是nn.Module

**nn.Module**（torch.nn.Module）是 [[PyTorch]] 中组织神经网络计算模块的基类，用于管理注册的模型参数、子模块及缓冲状态，并定义模块的[[前向传播]]行为。一个 Module 可以表示单个[[层]]，也可以由多个子模块组成完整模型。

自定义模块通常继承该类，在初始化时创建子模块，并通过重写 `forward` 方法定义输入如何得到输出。使用时一般调用 `model(x)`，让 Module 的调用机制执行 `forward` 及相应的钩子等处理，而不是直接调用 `model.forward(x)`。

Module 负责模型的结构和状态组织，不会仅因被调用就自动完成训练：[[自动微分]]负责计算梯度，[[优化器]]负责更新参数。

参考：[PyTorch 官方文档](https://docs.pytorch.org/docs/2.14/generated/torch.nn.Module.html)。

