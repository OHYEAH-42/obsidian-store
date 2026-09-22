---
date: 2026-05-21
tags:
  - 编译原理
cssclasses:
  - "[[预测分析算法]]"
---
LL(1)中的第一个“ L”表示从左向右扫描输入，第二个“L”表示产生最左推导，而“1”则表示在每一步中只需要向前看一个输入符号来决定语法分析动作。

对于产生式
E->T|T+E
T->int|int\*T|(E)

可以得到：
E->TX                             X->+E|ε
T->(E)|int Y                    Y->\*T->ε

其LL(1)文法表格如下

![[Pasted image 20260521132134.png]]


# 如何构建LL(1)文法表

设分析表为M\[A,a]
- 行：非终结符号A
- 列：终结符a
- 表项：某一条产生式 A->α

前提：
- 消除[[左递归]]
- 提取[[左公因子]](消除文法的回溯)
- 求[[FIRST 集]]
- 求[[FOLLOW 集]]

对于每个产生式 A->α，按照如下规则填写
1. 如果a∈FIRST(α)，则把A->α填入M\[A,a]
	看到输入符号是a，就用产生式 A->α
2. 如果ε∈FIRST(α)，说明α->\*ε(表示空串)，那么对所有b∈FOLLOW(A)，把A->α填入M\[A,b]
	当A可以推出空(ε)的时候，如果后面出现FOLLOW(A)中的符号，则可以使用这个空产生式
3. 所有没有定义的位置，留空

## 例子

E->TX                             X->+E|ε
T->(E)|int Y                    Y->\*T|ε

其LL(1)文法表格如下

![[Pasted image 20260521132134.png]]
其非终结符号的FIRST集 和 FOLLOW集如下
FIRST( E )={ ( , int }
FIRST( T )={ ( , int }
FIRST( X )={ + , ε}
FIRST( Y )={ \* , ε}

FOLLOW(E)={ ) , \# }
FOLLOW(T)={ + ,\# , ) }
FOLLOW(X)={ ), \# }
FOLLOW(Y)={ + ,\# , ) }

- 对于产生式 E->TX  
	由于T不能推导得到ε，所以FIRST(T)=FIRST(TX)
	( 和 int ∈FIRST( TX )，所以我们把该产生式填入M\[E, ( ]和M\[E,int]

- 对于产生式 X->+E
	显然FIRST(+E)={+}
	\+ ∈FIRST( E )，所以把产生式+E填入M\[X,+]
- 对于产生式 X->ε
	ε∈FIRST(ε)，对所有b∈FOLLOW(X)={ ），# }，把该产生式填入M\[X, ) ]和M\[X, # ]

- 对于产生式 T->(E)
	显然FIRST((E))={ ( }
	（∈FIRST((E))，所以把产生式(E)填入M\[T , ( ]
- 对于产生式 T->int Y 
	显然FIRST(int Y)={int}
	int ∈FIRST(int Y)，所以把产生式int Y填入M\[T , int ]

-  对于产生式Y->\*T
	显然FIRST(\*T)={ \* }
	\*∈FIRST(i\*T)，所以把产生式\*T填入M\[Y , \* ]
- 对于产生式Y->ε
	ε∈FIRST(ε)，对所有b∈FOLLOW(Y)={ + ,\# , ) }，把该产生式填入M\[Y, +]，M\[Y, ) ]和M\[Y, # ]