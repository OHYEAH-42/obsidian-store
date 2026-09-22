# 第三章：上下文无关文法 — 深入讲解

## 1. 为什么正则表达式不够用？

### 1.1 一个经典例子

语言 `L = { aⁿ b aⁿ | n ≥ 0 } = { b, aba, aabaa, aaabaaa, ... }`

**无法用正则表达式描述**！因为正则表达式/有限自动机不能"数数"——无法记住前面匹配了多少个 a。

**但可以用文法**：
```
G₁: S → aSa | b
```

推导 `aabaa`：
```
S ⇒ aSa ⇒ aaSaa ⇒ aabaa
```

### 1.2 正则文法的局限性

| 能描述的 | 不能描述的 |
|---------|-----------|
| 标识符 `letter(letter\|digit)*` | 括号匹配 `{ⁿ}ⁿ` |
| 数字常量 `digit+` | 嵌套 if-else |
| 关键字 | 表达式的优先级 |

**结论**：词法用正则（自动机），语法用 CFG（下推自动机）。

---

## 2. CFG 的形式化定义

### 2.1 四元组 G = (V_N, V_T, P, S)

```
G_exp = ({E, O},                      // V_N：非终结符
         {(, ), +, -, *, /, v, d},    // V_T：终结符
         P,                            // P：产生式集
         E)                            // S：开始符号

其中 P（产生式集）：
E → E O E
E → (E)
E → v
E → d
O → +
O → -
```

**约定**：
- 非终结符用大写字母（或尖括号）：A, B, C, S
- 终结符用小写字母或实际符号：a, b, c, +
- α, β, γ 表示符号串
- a, b, c（小写）表示终结符
- u, v, w, x, y, z 表示终结符串

### 2.2 文法的多种写法

```
写法一（标准 BNF）：                 写法二（简写 G[E]式）：
E → EOE                             E → EOE | (E) | v | d
E → (E)                             O → + | -
E → v
E → d
O → +
O → -
```

---

## 3. 推导、归约与句型

### 3.1 一个完整的推导链示例

G[E]: E → EOE | (E) | v | d,  O → + | -

**最左推导 v+(v+d)**：
```
E ⇒_lm EOE          （用 E→EOE，替换最左的 E）
  ⇒_lm vOE          （E→v）
  ⇒_lm v+E          （O→+）
  ⇒_lm v+(E)        （E→(E)）
  ⇒_lm v+(EOE)      （E→EOE）
  ⇒_lm v+(vOE)      （E→v）
  ⇒_lm v+(v+E)      （O→+）
  ⇒_lm v+(v+d)      （E→d）
```
共 7 步推导，每次替换**最左边**的非终结符。

**最右推导（规范推导）v+(v+d)**：
```
E ⇒_rm EOE          （E→EOE，替换最右的 E）
  ⇒_rm EO(E)        （E→(E)）
  ⇒_rm EO(EOE)      （E→EOE）
  ⇒_rm EO(EOd)      （E→d）
  ⇒_rm EO(Ed)       （O→-... 这里实际上要看具体的 O）
  ⇒_rm EO(vd)       （E→v）
  ⇒_rm E+(vd)       （O→+）
  ⇒_rm v+(vd)       （E→v）
```

**技巧**：最右推导是**自底向上分析（LR）**的基础，也称为规范推导。

### 3.2 什么是句型（Sentential Form）

- **句型**：从开始符号推导出的**任意**符号串（可含非终结符）
- **句子**：全是终结符的句型（即推导的终点）
- **最左句型**：由最左推导得到的句型
- **最右句型**：由最右推导得到的句型

**例**：`vOE` 是一个最左句型（含两个非终结符），`v+(v+d)` 是句子。

### 3.3 推导与语法树的关系

```
         v+(v+d) 的语法树：
              E
           /  |  \
          E   O   E
          |   |   /|\
          v   +  ( E )
                  /|\
                 E O E
                 | | |
                 v + d

一棵语法树 = 多种推导方式
但最左推导和最右推导各只有一种（针对同一棵树）
```

**重要**：语法树反映了语句的**结构**，而推导反映了分析**过程**。

---

## 4. 语法树的数据结构

### 4.1 子节点列表法（适合固定产生式）
```c
typedef struct TreeNode {
    int NodeNo;           // 节点编号
    int NodeKind;         // 终结符 or 非终结符
    int Father;           // 父节点编号
    int ChildBegin;       // 第一个孩子编号
    int Brother;          // 下一个兄弟编号
} TreeNode;
TreeNode SyntaxTree[MaxNodeNum];
```

以 `i+i*i` 为例：
```
Node 0: E  (根)
Node 1: E  (左孩子)
Node 2: +  (下一个兄弟 = 中)
Node 3: T  (再下一个兄弟 = 右)
...
```

### 4.2 指针法（适合 AST）
```c
typedef enum { Plus, Minus, Times, Division } OpKind;
typedef enum { OpK, ConstK, VarK } ExpKind;

typedef struct streenode {
    ExpKind kind;
    OpKind op;
    struct streenode *lchild, *rchild;
    int val;
    char varname[20];
} STreeNode;
typedef STreeNode *SyntaxTree;
```

对于 `v + v * d`：
```
        +
       / \
      v   *
         / \
        v   d
```

### 4.3 文法的数值化存储

课程中将终结符和非终结符编码为整数：

```
V_T 用原始编码（ASCII 码或自定义）
V_N 编码为 V_N_i + 100（加偏移 100 便于区分）

例如：E→101, T→102, F→103
      +→1, *→2, i→3, (→4, )→5
```

产生式存储结构：
```c
typedef struct {
    int LeftPart;                            // 左部非终结符编号
    int RightPart[MaxRightPartLength + 1];   // 右部符号序列
    int RightPartLength;                     // 右部长度
} Rule;
Rule Grammar[MaxRuleNum + 1];
```

**文法 EE+T|T, TT*F|F, F(E)|i 的存储**：
```
Grammar[1]: LeftPart = 101  (E)
            RightPart = {101, 1, 102}  (E + T)
            RightPartLength = 3
Grammar[2]: LeftPart = 101  (E)
            RightPart = {102}  (T)
            RightPartLength = 1
Grammar[3]: LeftPart = 102  (T)
            RightPart = {102, 2, 103}  (T * F)
            RightPartLength = 3
...
```

链式存储（便于解析遍历）：
```
^ E ^ E T F i i i i i  ← 终结符层
+ ++ + ++ + +          ← 对应的关系指针
T ^ T^ T^ T^ T F i i
* * * *                 ← 运算符层
F ^ F^ F^ i ^           ← 终结符层
```

---

## 5. 文法的歧义性

### 5.1 最经典的歧义：if-else 悬挂问题

```
S → if e then S | if e then S else S | a
```

句子：**if e then if e then a else a**

树1（else 匹配第一个 if）：
```
      if-then-else
     /    |     \
    e   if-then  a
        /   |
       e    a
```

树2（else 匹配第二个 if——期望行为）：
```
      if-then
     /    |
    e   if-then-else
         /   |     \
        e    a      a
```

**三种解决方案**：

**方案1：拆分文法**
```
S → matched | unmatched
matched   → if e then matched else matched | a
unmatched → if e then S | if e then matched else unmatched
```

**方案2：添加结束符号**
```
if-stmt → if e then state-seq end if
        | if e then state-seq else state-seq end if
```

**方案3：就近匹配原则**（C/C++/Java 采用）
规定 else 匹配最近的未匹配 if。

### 5.2 表达式歧义：优先级和结合性

歧义文法：
```
exp → exp op exp | (exp) | number
op  → + | - | * | /
```

`34 - 3 * 42` 可以理解为 (34-3)*42 或 34-(3*42)。

**消除歧义——分层表示**：
```
exp   → exp addop term | term
addop → + | -
term  → term mulop factor | factor
mulop → * | /
factor → (exp) | number
```
- 越底层（factor）优先级越高
- 左递归表示左结合

`34-3*42` 的唯一推导：
```
exp ⇒ term ⇒ ... ⇒ exp - term ⇒ term - term * factor
   ⇒ ... ⇒ 34 - 3 * 42
```

---

## 6. Chomsky 文法分类

| 类型 | 名称 | 产生式约束 | 识别器 | 示例 |
|------|------|----------|--------|------|
| 0 | 无限制 | α→β，α,β 任意 | 图灵机 | 任意计算 |
| 1 | 上下文有关 | αAβ→αγβ (γ≠ε) | 线性界限自动机 | `aⁿbⁿcⁿ` |
| 2 | 上下文无关 | A→α, A∈V_N | 下推自动机 | 编程语言语法 |
| 3 | 正则 | A→aB 或 A→a | 有限自动机 | 词法规则 |

**包含关系**：类型3 ⊂ 类型2 ⊂ 类型1 ⊂ 类型0

**考试要点**：给定文法，判断属于哪一型？

例：
```
G[S]: S→A0|B1|0, A→A0|B1|S0, B→B1|1|0
```
判断：右部有非终结符出现在多个位置，不是3型。但左部都是单个非终结符 → **2型(CFG)**。

例：
```
G[S]: S→CD, C→aCA, C→bCB, C→a, D→b, bA→ab, dD→d
```
判断：bA→ab 的左部含终结符和非终结符，不是纯粹的 A→α 形式 → **1型或0型**。

---

## 7. 一些重要题目

### 题目1：`VT={a,b}`, 描述 `S = { aⁿ b aⁿ | n ≥ 0 }`

写出两个等价的文法：
```
G₁: S → aSa | b
G₂: S → aA | b
    A → Sa
```
验证 G₁: S⇒aSa⇒aaSaa⇒aabaa ✓
验证 G₂: S⇒aA⇒aSa⇒aaSaa⇒aAaa⇒abaa? S→b... S⇒aA⇒aSa⇒aaSaa...

实际上 G₂: S⇒aA⇒aSa⇒aaAa⇒aab a? Wait...

验证 G₂ = aⁿbaⁿ:
n=0: S⇒b ✓
n=1: S⇒aA⇒aSa⇒aba ✓（S→b）
n=2: S⇒aA⇒aSa⇒aaAa⇒aaSaa⇒aabaa ✓

所以 L(G₁)=L(G₂)，G₁ 和 G₂ 等价。

### 题目2：描述 L₁ = {aⁱ bʲ cᵏ | i, j, k ≥ 1}

```
S → ABC
A → aA | a
B → bB | b
C → cC | c
```
保证 a、b、c 各至少一个，且严格按 abc 顺序。

### 题目3：描述 L₂ = {abⁱ | i ≥ 0}（a 后跟任意个 b）

```
S → aB
B → bB | ε
```

---

## 8. 复习自测题

1. CFG 的四元组是什么？每个元素解释清楚。
2. 给定文法 E→EOE|(E)|v|d, O→+|-, 写出 v+(v*d) 的最左推导和最右推导。
3. 什么是文法的歧义性？如何消除 if-else 的歧义？
4. 判断以下文法类型：
   - G1: A→aB, B→bC, C→c
   - G2: S→aSb | ε
   - G3: AB→BA
5. 描述语言 `{aⁱbʲ | i<j}` 的 CFG。
