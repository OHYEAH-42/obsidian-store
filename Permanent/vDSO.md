---
date: 2026-10-17
tags:
  - 操作系统
cssclasses:
aliases:
  - Virtual Dynamic Shared Object
  - 虚拟动态共享对象
---
# 什么是vDSO

**vDSO**（Virtual Dynamic Shared Object）是 Linux 内核映射到用户进程地址空间中的小型共享对象，提供可在用户态执行的部分内核辅助函数。它可结合内核提供的只读数据，加速某些时间查询等操作，避免每次都执行真正的[[系统调用]]。vDSO 包含可调用代码，并不等同于一张只读数据页；可提供哪些函数及何时回退到系统调用取决于体系结构和实现。

来源：[[操作系统知识索引#资料来源|Lab3，PDF 第 8–9 页；细节按 Linux vDSO 手册核对]]。

