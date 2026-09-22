---
date: 2026-05-21
tags:
  - 编译原理
---
# **定义**：

对于非终结符 A，FOLLOW(A) 是**所有可能出现在 A 之后（紧跟着）的终结符**的集合。也可以理解为在某个推导句型中，紧跟 A 后面的那个终结符。
如果 A 是开始符号，则输入结束标记 \#（或 \$）属于 FOLLOW(A)。 FOLLOW 集中**从不包含** ε。

# 理解

S → AB
A → aA | ε
B → bB | ε

S → AB → aAbB → aaAbbB → a......aAb...bB
or
S → AB → aAε
S → AB → εbB

FOLLOW(S)={ \# }(\#\$表示结束符号)
FOLLOW(A)={ b, \#}
FOLLOW(B)={ \# }

---

E->T|T+E
T->int | int\*T | (E)

E->TX                             X->+E|ε
T->(E)|int Y                    Y->\*T | ε

FOLLOW(E)={ ) , \# }
FOLLOW(T)={ + ,\# , ) }
FOLLOW(X)={ ), \# }
FOLLOW(Y)={ + ,\# , ) }

FOLLOW( ( )={ ( , int }
FOLLOW( ) )={ + ,\# , ) }
FOLLOW( + )={ ( , int }
FOLLOW( \* )={ (, int }
FOLLOW( int )={ \* , + , # , ) }

有一些比较简单的做法，如果 A -> aB，B后面为空，则将FOLLOW(A)加入到FOLLOW(B)中
比如

E->TX                             X->+E|ε
可以看见E推导得到的X在最右边，而在最右边意味着，FOLLOW(E)⊆FOLLOW(X)，
同时X推导出的E也在最右边，所以FOLLOW(X)⊆FOLLOW(E),
故FOLLOW(E)=FOLLOW(X)


---

# 判断方法

 1. 如果E是开始符号，则#(结束标记)在FOLLOW(E)中
 2. 如果 A -> aB，B后面为空，则将FOLLOW(A)加入到FOLLOW(B)中
 3. 如果 A -> aBb
	 - 当b为终结符时，b加入到FOLLOW(B)中
	 - 当b为非终结符时，FIRST(b)加入到FOLLOW(B)中        [[FIRST 集]]



---
# 代码实现

## 数据结构

### 文法Grammer

```c
unordered_map<char, set<string>> grammarMap;
```

### FOLLOW 集合单元

```c
struct followUnit { set<char> s; };
```

### FOLLOW 集

```c
map<char, followUnit> followSets;
```

## 具体实现

```C++
// 添加Follow集合
void addToFollow(char nonTerminal, const set<char>& elements)
{
    followSets[nonTerminal].s.insert(elements.begin(), elements.end());
}
// 计算Follow集合
bool calculateFollowSets()
{
    bool flag = false;
    for (auto& grammar : grammarMap)
    {
        char nonTerminal = grammar.first;
        for (auto& g : grammar.second)
        {
            for (int i = 0; i < g.size(); ++i)
            {
                if (isSmallAlpha(g[i]) || g[i] == '@') //同理，可以是ε
                {
                    continue;  // 跳过终结符
                }
                set<char> follow_k;
                size_t originalSize = followSets[g[i]].s.size();
                if (i == g.size() - 1)
                {
                    // Case A: A -> αB, add Follow(A) to Follow(B)
                    follow_k.insert(followSets[nonTerminal].s.begin(), followSets[nonTerminal].s.end());
                }
                else
                {
                    // Case B: A -> αBβ
                    int j = i + 1;
                    while (j < g.size())
                    {
                        if (isSmallAlpha(g[j]))
                        {   // 终结符直接加入并跳出
                            follow_k.insert(g[j]);
                            break;
                        }
                        else
                        {   // 非终结符加入first集合
                            set<char> first_beta = firstSets[g[j]].s;
                            follow_k.insert(first_beta.begin(), first_beta.end());

                            // 如果没有空串在first集合中，停止。
                            if (!firstSets[g[j]].isEpsilon)
                            {
                                break;
                            }
                            ++j;
                        }
                    }
                    // If β is ε or β is all nullable, add Follow(A) to Follow(B)
                    if (j == g.size())
                    {
                        follow_k.insert(followSets[nonTerminal].s.begin(), followSets[nonTerminal].s.end());
                    }
                }
                addToFollow(g[i], follow_k);
                // 检查是否变化
                if (originalSize != followSets[g[i]].s.size())
                {
                    flag = true;
                }
            }
        }
    }
    return flag;
}
void getFollowSets()
{
    // 开始符号加入$
    addToFollow(startSymbol, { '$' });
    // 不停迭代，直到Follow集合不再变化
    bool flag = false;
    do
    {
        flag = calculateFollowSets();
    } while (flag);
}
```

## 伪代码

数据结构一样，文法开始符号的FOLLOW\[E]={$}，其它为空

```
bool 计算FOLLOW集合（）
	bool 标志位=false
	for（遍历文法中的所有产生式）
		获得该表达式的左边符号A
		for（遍历该产生式的右边）
			for（遍历该产生式的右边的所有符号B）
				if(B是终结符||是ε)
					跳过
				temp存放本轮要加入的字符       //temp放的是FOLLOW(B)
				if(B是最后一个符号)           //情况1：A->aB
					temp=FOLLOW(A)
				else后面还有东西              //轻狂2：A->aBp
					从B后一个字符C开始
					while（C遍历产生式右边剩余的符号）
						if(C是终结符)
							将C加入到temp
							跳出break；
						else //C是非终结符
							temp+=FIRST[C]，FOLLOW[B]加上FIRST[C]，注意去掉ε
							if(FIRST[C]中没有ε)
								break；
					
					if C 遍历到了最后
						temp+=FOLLOW[A],FOLLOW[B]加上FOLLOW[A]
				
				FOLLOW[B]+=temp;
				if(FOLLOW[B]大小变化了)
					标志位=1
	return 标志位
	
void 获得FOLLOW集的集合
	设置开始符号的FOLLOW集为$终止符号
	bool 标志位=0
	do
		标志位=计算FOLLOW集合（）
	while(标志位)
```
