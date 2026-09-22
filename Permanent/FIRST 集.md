---
date: 2026-05-21
tags:
  - 编译原理
---
# **定义**

对于文法符号（终结符或非终结符）X，FIRST(X)) 是所有可能由 X 推导出的字符串的**第一个终结符**的集合。

如果 X 可以推导出空串 ε，则 ε 也属于 FIRST(X)。

FIRST(X)={t | X->\*tα} ∪ {ε | X->\*ε}
\*表示经过0步或者多步推导

# 理解

S → AB
A → aA | ε
B → bB | ε

- FIRST(a)={a}, FIRST(b)={b}
    
- FIRST(A)={a,ε}FIRST(A)={a,ε}（因为 A→εA→ε）
    
- FIRST(B)={b,ε}FIRST(B)={b,ε}
    
- FIRST(S)=FIRST(A) \\ {ε}∪FIRST(B) …… 但注意，因为 A 可空，所以先取 FIRST(A) 的非ε部分 {a}，然后因为A可空，加上 FIRST(B) 的非ε部分 {b}，所以 FIRST(S)={a,b,ε}。


E->T|T+E
T->int | int\*T | (E)

E->TX                             X->+E|ε
T->(E)|int Y                    Y->\*T|ε

对于终结符号：
FIRST(int)={int}
FIRST( ( )+{ ( }
FIRST( \* )={ \* }
FIRST( ) )+{ ) }
FIRST( \+ )={ \+ }

对于非终结符号
FIRST( E )={ ( , int }
FIRST( T )={ ( , int }
FIRST( X )={ + , ε}
FIRST( Y )={ \* , ε}


# 判断方法

1.  如果 X 是**终结符**，则 FIRST(X)={X}。
2. 如果 X 是**非终结符**，且 X→Y1​Y2​…Yk​ 是一个产生式：
 - 将 FIRST(Y1​) 中除 ε 外的所有符号加入 FIRST(X)。
 - 如果 Y1​ 可空（即 ε∈FIRST(Y1)），则继续处理 Y2​，依此类推。
 -  如果所有 Y1​,Y2​,…,Yk​ 都可空，则将 ε 加入 FIRST(X)。

# 复合 FIRST(ab) 求法

其实很简单的，FIRST(ab)就是把ab拼成了一个字符串看，按串的FIRST规则来看
无非就三种情况：a为ε，a推得出ε，a推不出ε

1. a为ε
	FIRST(ab)=FIRST(b)
2. a推得出ε
	FIRST(ab)=FIRST(a)-{ ε }+FISRT(b)
3. a推不出ε
	FIRST(ab)=FIRST(a)

# [[FIRST 集的代码实现]]