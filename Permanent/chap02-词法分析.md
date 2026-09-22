# 第二章：词法分析 — 深入讲解

## 1. 词法分析的本质问题

**输入**：字符序列（字符串）
**输出**：Token 序列（每个 Token = 类别 + 属性值）

```
输入：a[index] = 314 + 25
       ↓ 词法分析
输出：IDENT("a")  LBRACK  IDENT("index")  RBRACK  ASSIGN  NUM(314)  PLUS  NUM(25)
```

**Token 的类别**（本课程的分类）：
- 保留字（关键字）：if, else, while, for, int, double 等
- 标识符：用户定义的变量名、函数名
- 数字：整数、浮点数（含科学计数法）
- 运算符：算术（+ - * /）、比较（< > <= >= == !=）、赋值（=）
- 分隔符：（ ）{ } ; ,

---

## 2. 正则表达式 — 词法规则的形式化描述

### 2.1 为什么用正则表达式？

正则表达式的描述能力恰好等于有限自动机，正适合描述 token 的词法结构。

### 2.2 核心运算（完整表）

| 优先级 | 运算 | 写法 | 含义 | 示例 |
|--------|------|------|------|------|
| 最高 | 闭包 | `r*` | r 出现 0 次或多次 | `a*` = {ε, a, aa, aaa, ...} |
| | 正闭包 | `r+` | r 出现 1 次或多次 (= rr*) | `a+` = {a, aa, aaa, ...} |
| | 可选 | `r?` | r 出现 0 次或 1 次 (= r\|ε) | `a?` = {ε, a} |
| 中 | 连接 | `rs` | r 后面紧跟 s | `ab` = {ab} |
| 最低 | 选择 | `r\|s` | r 或 s | `a\|b` = {a, b} |

**技巧**：
- `a* = {a}*`，含 ε
- `a+ = aa*`，不含 ε
- `(a|b)*` = 由 a 和 b 组成的任意串（包含 ε）
- `(a|b)+` = 由 a 和 b 组成的任意非空串

### 2.3 正则表达式简写法（扩展记法）

```re
[0-9]     → 0|1|2|...|9
[a-z]     → a|b|...|z
[A-Z]     → A|B|...|Z
[a-zA-Z]  → 所有大小写字母
[abc]     → a|b|c
.         → 任意单字符（通常不含换行）
~a        → 除 a 外的任意字符
"string"  → 字面量字符串本身
```

### 2.4 经典正则表达式——从简单到复杂

#### 例1：无符号整数 natural
```
详细写法：digit = 0|1|2|3|4|5|6|7|8|9
         natural = digit digit*
简写：    natural = [0-9]+
```

#### 例2：有符号整数
```
详细：signedNatural = (+|-|ε) natural
简写：signedNatural = (+|-)? [0-9]+
```

#### 例3：浮点数（含科学计数法）——最重要！
```
nat       = [0-9]+
signedNat = (+|-)? nat
number    = signedNat ("." nat)? (E signedNat)?
```
这个正则可以匹配：`123`, `3.14`, `-4.5`, `2.71E-2`, `1.5E+10`

**逐步理解**：
1. `signedNat` → 整数部分（带可选符号）
2. `("." nat)?` → 小数部分可选
3. `(E signedNat)?` → 指数部分可选

#### 例4：标识符
```
letter     = a|b|...|z|A|B|...|Z
digit      = 0|1|...|9
identifier = letter (letter | digit)*
简写：      identifier = [a-zA-Z][a-zA-Z0-9]*
```

#### 例5：题目示例——`Σ = {a,b,c}`，至少包含一个 b
```
(a|c)* b (a|c)*
```
解析：b 前可以有任意个 a 或 c，b 后也可以有任意个 a 或 c。**保证至少有一个 b**。

#### 例6：最多包含一个 b 的串
```
(a|c)* | (a|c)* b (a|c)*
```
分析：要么没有 b（前面那部分），要么恰好一个有 b。

#### 例7：b 后面跟的一定是 a 或 c（即不允许 bb）
```
(a|c)* (b(a|c)+)* b?
```
理解：每个 b 后面必须跟至少一个 a 或 c。

#### 例8：Pascal 注释
```
{ 内容 }
```
正则：`{ (~})* }`（左花括号 + 任意非右花括号字符的重复 + 右花括号）

#### 例9：C 语言注释
```
/* 内容 */
```
正则：`/* (~(*/))* */`（注意要排除的是 `*/` 这个双字符序列）

### 2.5 课程中的数字 DFA 完整构造

```
digit     = [0-9]
nat       = digit+
signedNat = (+|-)? nat
number    = signedNat ("." nat)? (E signedNat)?
```

**分步构造 DFA**：

**Step 1: nat 的 DFA**
```
    [0-9]
  ┌───────┐
  ↓       │
→(S)─────→((A))   // A 是接受态
  [0-9]
```

**Step 2: signedNat 的 DFA**（在 nat 前加可选符号）
```
       [0-9]
  ┌─────────────┐
  │ + or -      ↓
→(S)──→(1)────→((A))
  │             ↑
  └──[0-9]──────┘
```
S 可以直接读数字到 A（无符号），也可以先读 +/- 再读数字。

**Step 3: 加上可选的小数部分** `signedNat ("." nat)?`
```
                                  [0-9]
       [0-9]    .    [0-9]   ┌───────────┐
→(S)──→(1)──→((A))──→(B)──→((C))          │
  │     ↑              ↑      └───────────┘
  └─────┘              └── ε（无小数）
```
A 是整数结束（接受态），如果有 `.` 则进入 B，再读数字到 C（也是接受态）。

**Step 4: 完整的 number DFA**（加上指数部分）
```
                                  [0-9]
       [0-9]    .    [0-9]   ┌───────────┐   E   +|-|ε   [0-9]
→(S)──→(1)──→((A))──→(B)──→((C))          │ → (D) → (E) → ((F))
  │     ↑              ↑      └───────────┘              ↑   ┌──┘
  └─────┘              └── ε ────────────────────────────┘   └─ [0-9] ─┘
```

---

## 3. 从正则表达式到 NFA：Thompson 构造法

### 3.1 算法的递归结构

对于给定的正则表达式 r，递归地构造 NFA N(r)，满足：
- N(r) 恰好有一个起始状态和一个终态
- 从起始到终态恰好识别 L(r)

### 3.2 四类基本构造

#### (1) 基本正则表达式 a
```
   a
○──→◎

新建两个状态 s 和 t，s 经字符 a 到达 t。
```

#### (2) 连接 rs
```
N(r) 的终态  ε→  N(s) 的初态
```
直接将 N(r) 的终态用 ε 边连接到 N(s) 的初态，合成后的初态 = N(r) 的初态，终态 = N(s) 的终态。

#### (3) 选择 r|s
```
       ε → N(r) → ε
     ↗              ↘
   ○                  ◎
     ↘              ↗
       ε → N(s) → ε
```
新建初态和终态。初态用 ε 分叉到 N(r) 和 N(s) 各自的初态，各自的终态用 ε 汇聚到新终态。

#### (4) Kleene 闭包 r*
```
       ε → N(r) → ε
     ↗    ↑        ↘
   ○      └── ε ──  ◎
     ↘──────────────↗
           ε
```
新建初态和终态。初态用 ε 直接到终态（匹配 0 次），也 ε 到 N(r) 初态。N(r) 终态 ε 到新终态，也 ε 回到 N(r) 初态（匹配多次）。

### 3.3 Thompson 构造法完整示例

**构造 `ab|a` 的 NFA**：

```
Step 1: 构造 a 的 NFA        Step 2: 构造 b 的 NFA
   a                           b
○──→◎                      ○──→◎

Step 3: 连接 ab（a 的终态 ε→ b 的初态）
   a    ε    b
○──→◎───→○──→◎

Step 4: 选择 ab|a
          ε → (ab的NFA) → ε
        ↗                    ↘
      ○                        ◎
        ↘                    ↗
          ε → (a的NFA)  → ε
```

**构造 `letter(letter|digit)*` 的 NFA**（标识符的核心）：

```
Step 1: letter 的 NFA       Step 2: digit 的 NFA
   letter                       digit
○─────→◎                     ○─────→◎

Step 3: letter|digit 的 NFA（选择）
          ε → (letter) → ε
        ↗                  ↘
      ○                      ◎
        ↘                  ↗
          ε → (digit)  → ε

Step 4: (letter|digit)* 的 NFA（闭包）
  加上 ε 自循环

Step 5: letter(letter|digit)* 的 NFA（连接）
  letter 的 NFA 的终态 ε→ (letter|digit)* 的初态
```

### 3.4 课程代码实现：正则表达式 → NFA（只做选择运算）

```cpp
// 正则表达式 2 NFA-arr-set-fill-only or 规则.cpp
// 文法：RE → RF { "|" RF }
//       RF → ( RE ) | char

const int maxlen = 100;
set<char> NFAtable[maxlen][maxlen];  // NFA 转换表，每个边可有一个字符集

struct node { int start, end; };  // 一个子 NFA 的起止状态
int currNumber = 0;                // 当前已用状态数

// 合并两个 NFA（选择运算 "|"）
node Ormerge(node x, node y) {
    node currNode;
    currNode.start = currNumber++;     // 新起始状态
    NFAtable[currNode.start][x.start].insert('#');  // ε 边到 x
    NFAtable[currNode.start][y.start].insert('#');  // ε 边到 y
    currNode.end = currNumber++;       // 新终态
    NFAtable[x.end][currNode.end].insert('#');      // x 的终态 ε 到新终态
    NFAtable[y.end][currNode.end].insert('#');      // y 的终态 ε 到新终态
    return currNode;
}

// 递归下降解析正则表达式并构造 NFA
node rexp() {
    node temp1 = rfactor();    // 解析第一个 RF
    while (token == '|') {
        match(token);
        node temp2 = rfactor();
        temp1 = Ormerge(temp1, temp2);  // 合并（选择运算）
    }
    return temp1;
}

node rfactor() {
    node temp1;
    if (token == '(') {
        match('(');
        temp1 = rexp();        // 递归解析括号中的内容
        match(')');
    } else if (isalpha(token)) {
        temp1.start = currNumber;
        temp1.end = currNumber + 1;
        currNumber += 2;
        NFAtable[temp1.start][temp1.end].insert(token);  // 字符边
        match(token);
    }
    return temp1;
}
```

**输出示例**（`a|b|c`）：
```
0: NFA 的起始状态
   ├── ε → 状态1（a 的 NFA 起点）
   └── ε → 状态3（b|c 的 NFA 起点）
1:
   └── a → 状态2（a 的 NFA 终点）
2:
   └── ε → 状态7（统一终点）
3:
   ├── ε → 状态4（b 的 NFA 起点）
   └── ε → 状态5（c 的 NFA 起点）
...
```

**注意**：这里用 `#` 表示 ε 边。

---

## 4. 从 NFA 到 DFA：子集构造法

### 4.1 为什么需要转换

NFA 有不确定性：
- 同一个状态下，读入同一个字符可能去往多个状态
- 有 ε 边，可以不消耗输入就转换状态

DFA 没有这些问题，因此更容易编码实现。**NFA 和 DFA 在表达能力上是等价的**。

### 4.2 两个关键运算

**ε-闭包（ε-closure）**：
```
ε-closure(S) = S ∪ { 从 S 中任意状态经 0 条或多条 ε 边能到达的所有状态 }
```
例：若 S={1}，且 1→(ε)→2, 2→(ε)→4，则 ε-closure({1}) = {1,2,4}。

**Move 运算**：
```
Move(S, a) = { t | 存在 s∈S 使得 s→(a)→t }
```
然后对该结果求 ε-闭包。

### 4.3 子集构造算法（伪代码）

```
输入：NFA N
输出：等价的 DFA D

D 的状态集 = { ε-closure({N的初态}) }   // D 的初态
while (存在未标记的 D 状态 T) {
    标记 T;
    for (每个输入字符 a) {
        U = ε-closure( Move(T, a) );
        if (U 不在 D 的状态集中)
            将 U 加入 D 的状态集（未标记）;
        添加 D 的转换: T →(a)→ U;
    }
}
包含 NFA 终态的 D 状态即为 DFA 的终态。
```

### 4.4 完整示例：a* 的 NFA → DFA

**NFA for a\***（Thompson 构造）：
```
状态：0(初态), 1, 2, 3, 4(终态=接受态)
转换：
  0 → ε → 1
  0 → ε → 4
  1 → a → 2
  2 → ε → 3
  2 → ε → 1
  3 → ε → 4
```

**子集构造过程**：

DFA 初态 A = ε-closure({0}) = {0, 1, 4}
（0 是起点，1 和 4 分别由 ε 可达）

Move(A, a) = {2}（只有状态 1 经 a 到 2）
ε-closure({2}) = ε-closure({1, 2, 3, 4}) = B = {0, 1, 2, 3, 4}
（2 经 ε 回 1，2 经 ε 到 3，3 经 ε 到 4，4 经 ε... 自反）

Move(B, a) = {2}
ε-closure({2}) = B（自身）

DFA 结果：
```
状态 A = {0, 1, 4}  —— 接受态（含 4）
状态 B = {0, 1, 2, 3, 4}  —— 接受态（含 4）

  ┌── a ──┐
  ↓       │
→(A)─────→(B)
      a
```

### 4.5 课程示例：数字文法的完整 DFA 构造

```
digit = [0-9]
nat = digit+
signedNat = (+|-)? nat
number = signedNat ("." nat)? (E signedNat)?
```

**NFA（Thompson 构造）→ 子集构造 → DFA** 的完整过程课后务必手算一遍。

### 4.6 DFA 最小化（补充知识）

有些 DFA 状态可以合并。方法：
1. 将所有状态分为两组：接受态 vs 非接受态（初划分）
2. 不断细分：若同组中两个状态对某字符的转换目标不在同一组，分开
3. 直到不再变化

---

## 5. DFA 的代码实现

### 5.1 方式一：switch-case 驱动

```cpp
state = 1;  // 初态
while (not done) {
    ch = getchar();
    switch (state) {
        case 1:
            if (isalpha(ch)) { state = 2; }
            else { error(); }
            break;
        case 2:
            if (isalpha(ch) || isdigit(ch)) { /* 留在状态 2 */ }
            else { done = true; accept(); }
            break;
    }
}
```

### 5.2 方式二：二维数组表驱动

```c
int DFA_table[MAX_STATES][MAX_CHARS];  // 状态转换表
int accept_states[MAX_STATES];         // 接受态标记

state = START_STATE;
while (state != ERROR) {
    ch = getchar();
    state = DFA_table[state][ch];
}
return accept_states[state];
```

### 5.3 C 注释的 DFA 实现

课程代码展示了一个完整的状态机实现：

```
状态 1: 初始 → 读 '/' 进状态 2
状态 2: 读 '*' 进状态 3（注释内部），否则走其他处理
状态 3: 非 '*' 留状态 3，'*' 进状态 4
状态 4: 非 '*' 非 '/' 回状态 3，'/' 进状态 5（接受）
状态 5: 注释识别完成
```

---

## 6. 正则表达式 → NFA → DFA → 代码 完整流程

| 步骤 | 输入 | 输出 | 算法 |
|------|------|------|------|
| 1 | 正则表达式（如 `digit+`） | NFA | Thompson 构造法 |
| 2 | NFA | DFA | 子集构造法 |
| 3 | DFA | DFA（最简） | DFA 最小化 |
| 4 | DFA | C/C++ 代码 | switch-case 或表驱动 |

---

## 7. 复习自测题

1. 写出以下 token 的正则表达式：C语言浮点数、Pascal标识符、C语言注释。
2. 用 Thompson 构造法画出 `(a|b)*abb` 的 NFA。
3. 用子集构造法将上述 NFA 转换为 DFA。
4. DFA 和 NFA 的区别是什么？为什么编译器中用的是 DFA？
5. 写出识别 `/* ... */` 注释的 DFA 状态转换图，并用 switch-case 实现。
