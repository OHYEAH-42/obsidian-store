---
date: 2026-07-07
tags:
  - 编译原理
cssclasses:
  - "[[FIRST 集]]"
  - "[[编译原理]]"
aliases:
---
# 代码实现

## 数据结构

### 文法

```c++
unordered_map<char, set<string>> grammarMap;
```

### FIRST 集合单元

```c++
struct firstUnit { set<char> s; bool isEpsilon = false; };
```

### 非终结符的FIRST集合

```c++
map<char, firstUnit> firstSets;
```
## 具体代码

```C++
// 计算First集合
bool calculateFirstSets()
{
    bool flag = false;
    for (auto& grammar : grammarMap)
    {
        char nonTerminal = grammar.first;
        // 保存当前First集合的大小，用于检查是否有变化
        size_t originalSize = firstSets[nonTerminal].s.size();
        bool originalE = firstSets[nonTerminal].isEpsilon;
        for (auto& g : grammar.second)
        {
            int k = 0;
            while (k <= g.size() - 1)
            {
                set<char> first_k;
                if (g[k] == '@') // @是空串（实验4要求），可改为ε
                {
                    k++;
                    continue;
                }
                else if (isSmallAlpha(g[k]))
                {
                    first_k.insert(g[k]);
                }
                else
                {
                    first_k = firstSets[g[k]].s;
                }
                firstSets[nonTerminal].s.insert(first_k.begin(), first_k.end());
                // 如果是终结符或者没有空串在非终结符中，直接跳出
                if (isSmallAlpha(g[k]) || !firstSets[g[k]].isEpsilon)
                {
                    break;
                }
                k++;
            }
            if (k == g.size())
            {
                firstSets[nonTerminal].isEpsilon = true;
            }
        }
        // 看原始大小和是否变化epsilon，如果变化说明还得重新再来一次
        if (originalSize != firstSets[nonTerminal].s.size() || originalE != firstSets[nonTerminal].isEpsilon)
        {
            flag = true;
        }
    }
    return flag;
}

void getFirstSets()
{
    // 不停迭代，直到First集合不再变化
    bool flag = false;
    do
    {
        flag = calculateFirstSets(); // 改成递归就是把他放进子函数里面
    } while (flag);
}
```

## 伪代码实现

数据结构是通用的，初始化终结符的FIRST都是他自己FIRST\[+]={ + }，非终结符号的FIRST为空。

```
bool 计算First集（）
{
	bool 标志位=0；
	for（遍历文法中的每一个产生式）
		获得产生式左侧符号A
		for(遍历产生式右侧)
			for(遍历产生式右侧的所有字符B)
				if(字符B是epsilon)
					继续
				elif(B是终结符)
					放入暂时的字符集tempFirstA
				elif(B是非终结符)
					把B的FIRST集放到暂时的符号集合tempFirstA
				把暂时的符号集合放到FIRST[A]中
				if(当前符号是终结符号||当前符号是非终结符号，但推不出ε)
					结束内层循环；
			if(遍历完这个产生式右侧了)
				FIRST[A]加入ε          //因为能走完右侧，例如E->AB，则说明AB都能推出ε
		if(FIRST[A]的大小变化了)
			标志位=1             //FIRST[A]更新了
	返回 标志位
}

void 获得First集的集合（）
{
	bool 标志位=0；
	do
		flag=计算First集（）
	while（标志位）；
}
```