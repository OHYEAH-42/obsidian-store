---
date: 2026-07-02
tags:
  - 编译原理
cssclasses:
  - "[[中间代码生成]]"
  - "[[逻辑表达式的翻译]]"
aliases:
---
基于[[四元组]]的回填函数，用于寻找真假出口


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
// chain表示真假出口链，chain的数值是四元组的索引，target表示要把chain上的四元组的结果改为target
void BackPatch(int chain,int target){
	int p = chain;
	while(p!=0)
		int next = quads[p].result;
		quads[p].result = target;
		p = next;
}
```