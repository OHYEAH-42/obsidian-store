---
date: 2026-07-02
tags:
  - 编译原理
cssclasses:
  - "[[逻辑表达式的翻译]]"
  - "[[中间代码生成]]"
aliases:
---
基于[[四元组]]的合并函数，用于将两条指向相同真假出口的链合并

# 代码实现

## 数据结构

### 四元组

```c++
struct Quad {
    string op, arg1, arg2;
    int result;    // 待回填时 = 下一条指令编号，已回填时 = 目标编号
};
vector<Quad> quads;   // quads[0] 空着，从 quads[1] 开始
int nextQuad = 1;
```


## 具体代码

```c++
// 合并两条链，返回新链头
int Merge(int p1, int p2) {
    if (p1 == 0) return p2;
    if (p2 == 0) return p1;

    int tail = p1;
	    while (quads[tail].result != 0) {    // 走到 p1 链尾
	        tail = quads[tail].result;
        }
	    quads[tail].result = p2;              // 链尾接上 p2
        return p1;                            // 返回新链头
  }
```