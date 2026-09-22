# 第四章：自顶向下语法分析 — 深入讲解

## 1. 自顶向下分析的核心挑战

### 1.1 本质问题
给定一个非终结符 A 和**当前输入符号（lookahead）**，确定该用 A 的哪个产生式展开。

**这个决策必须正确，否则需要回溯（代价高昂）。**

### 1.2 三大障碍

| 障碍 | 例子 | 问题 |
|------|------|------|
| 左递归 | A→Aa\|b | A 永远在第一步展开自己 → 死循环 |
| 回溯 | A→ab\|a | 两个候选项 FIRST 交集含 a，选哪个？ |
| 空产生式 | A→ε\|aB | 何时选 ε？需要 FOLLOW 信息 |

**解决**：
1. 消除左递归
2. 提取左公因子 + FIRST 集指导
3. 引入 FOLLOW 集

---

## 2. 消除左递归（完整算法）

### 2.1 直接左递归

```
A → Aα₁ | Aα₂ | ... | Aαₘ | β₁ | β₂ | ... | βₙ
```
转换为：
```
A  → β₁A' | β₂A' | ... | βₙA'
A' → α₁A' | α₂A' | ... | αₘA' | ε
```

**EBNF 记法**：`A → (β₁|β₂|...|βₙ) { α₁|α₂|...|αₘ }`

### 2.2 间接左递归消除（通用算法）

```
输入：无环、无 ε-产生式的文法 G
输出：等价的无左递归文法

步骤：
(1) 将非终结符排序为 A₁, A₂, ..., Aₙ
(2) for i = 1 to n:
        for j = 1 to i-1:
            对每个形如 Aᵢ → Aⱼγ 的产生式：
            用 Aⱼ → δ₁ | δ₂ | ... | δₖ 替换为
            Aᵢ → δ₁γ | δ₂γ | ... | δₖγ
        消除 Aᵢ 的直接左递归
(3) 删除无用的产生式
```

**举例**：消除以下文法的左递归
```
G[Z]: Z → Za | Sbc | dS
      S → Zef | gSh
```

**步骤**：
排序：先 Z，后 S

(1) Z 的直接左递归：`Z → Za | ...`
提取：`Z → (Sbc | dS) Z'`
      `Z' → aZ' | ε`

(2) 处理 S：`S → Zef | gSh`
Z 已处理，代入：`S → (Sbc | dS) Z' ef | gSh`
       = `S → SbcZ'ef | dSZ'ef | gSh`
消除 S 的直接左递归：
```
S → dSZ'ef S' | gSh S'
S' → bcZ'ef S' | ε
```
最终合并回去。

### 2.3 消除左递归后立即得到 EBNF 形式

**方法1**：左递归 `A → Aα | β` → EBNF `A → β { α }`
**方法2**：右递归 `A → β { α }` → `A → βA', A' → αA' | ε`

**例**：算术表达式文法的消除
```
// 原始（含左递归）
exp   → exp + term | exp - term | term
term  → term * factor | term / factor | factor
factor → (exp) | number

// 消除左递归后
exp   → term { '+' term | '-' term }
                  或 term { (+|-) term }
term  → factor { '*' factor | '/' factor }
                  或 factor { (*|/) factor }
factor → (exp) | number
```

---

## 3. 提取左公因子

### 3.1 问题
```
A → αβ₁ | αβ₂
```
面对输入，读了 α 之后才能区分。

### 3.2 解法
```
A  → αA'
A' → β₁ | β₂
```

### 3.3 一般形式
```
A → αA' | γ₁ | γ₂ | ... | γₘ   （γᵢ 不以 α 开头）
A' → β₁ | β₂ | ... | βₙ
```

**提取左公因子可能引入新的非终结符**。虽然增加非终结符数量，但这是实现确定型自顶向下分析的必要代价。

---

## 4. FIRST 集与 FOLLOW 集（重点）

### 4.1 FIRST 的直观理解

**FIRST(α)** = 从 α 推导出的**第一个终结符**的集合。如果 α 能推导出 ε，则 ε 也在 FIRST(α) 中。

### 4.2 FIRST 算法详解

**情况1：α = X（单个符号）**
```
若 X ∈ V_T：FIRST(X) = {X}
若 X ∈ V_N：
  对 X 的每个产生式 X → Y₁Y₂...Yₖ：
    若 Y₁ ∈ V_T → FIRST(X) += {Y₁}
    若 Y₁ ∈ V_N → FIRST(X) += FIRST(Y₁) - {ε}
                 若 ε ∈ FIRST(Y₁) → 继续看 Y₂
                 ...
    若所有 Y₁...Yₖ 都有 ε → FIRST(X) += {ε}
```

**情况2：α = X₁X₂...Xₙ（符号串）**
```
FIRST(α) = {}
for i = 1 to n:
    FIRST(α) += FIRST(Xᵢ) - {ε}
    if ε ∉ FIRST(Xᵢ): break
if i == n+1 (全都能推出 ε): FIRST(α) += {ε}
```

### 4.3 例题：计算 FIRST

**grammar**：
```
S → ABC | D
A → aB | ε
B → cC | bD
C → eC | ε
D → i | j
```

**计算过程**：

FIRST(aB) = {a}
FIRST(ε) = {ε} → FIRST(A) = {a, ε}

FIRST(cC) = {c}, FIRST(bD) = {b} → FIRST(B) = {b, c}

FIRST(eC) = {e}, FIRST(ε) = {ε} → FIRST(C) = {e, ε}

FIRST(i) = {i}, FIRST(j) = {j} → FIRST(D) = {i, j}

FIRST(ABC)：
  A → FIRST(A) = {a, ε}, 有 ε → 继续
  B → FIRST(B) = {b, c}, 无 ε → 停止
  FIRST(ABC) = {a} ∪ {b, c} - {ε} = {a, b, c}

FIRST(D) = {i, j}

FIRST(S) = FIRST(ABC) ∪ FIRST(D) = {a, b, c, i, j}

### 4.4 FOLLOW 的直观理解

**FOLLOW(A)** = 在某个句型中，**紧跟在 A 后面**的终结符的集合。$ 表示输入结束。

### 4.5 FOLLOW 算法详解

```
(1) FOLLOW(开始符号) = {$}
(2) 对每个产生式 B → αAβ：
       FOLLOW(A) += FIRST(β) - {ε}
       若 ε ∈ FIRST(β) 或 β = ε：
       FOLLOW(A) += FOLLOW(B)
(3) 重复(2)直到 FOLLOW 不再变化
```

### 4.6 例题：计算 FOLLOW

**grammar**：S→ABC, A→aB\|bB, B→cC\|ε, C→ef\|gh

```
(1) FOLLOW(S) = {$}

(2) 产生式 S→ABC：
    FOLLOW(A) += FIRST(BC) - {ε}
    先算 FIRST(BC)：B→cC|ε，所以从 B 开始
    FIRST(B) = {c} (C 开头的？)
    实际上 FIRST(B→cC)={c}, FIRST(B→ε)={ε}
    FIRST(B) = {c, ε}
    FIRST(BC)：B 有 ε → FIRST(C) = {e, g}
    FIRST(BC) = {c, e, g}
    FOLLOW(A) = {c, e, g}

    处理 β = BC 中的 C：
    FOLLOW(B) += FIRST(C) - {ε} = {e, g}
    FIRST(C)={e,g} 无 ε
    → FOLLOW(B) = {e, g}

    FOLLOW(C) += FOLLOW(S) = {$}

产生式 A→aB：
    FOLLOW(B) += FOLLOW(A)    // β=ε
    先算 FOLLOW(A)...
    从 S→ABC 得到 FOLLOW(A) = FIRST(BC)-{ε} = {c, e, g}
    → FOLLOW(B) = {e, g, c}

产生式 A→bB 同理。

产生式 B→cC：
    FOLLOW(C) += FOLLOW(B) = {e, g, c, $}

最终：
FOLLOW(S) = {$}
FOLLOW(A) = {c, e, g}
FOLLOW(B) = {c, e, g, $}
FOLLOW(C) = {c, e, g, $}
```

---

## 5. LL(1) 文法

### 5.1 判定条件

文法 G 是 LL(1) 的**当且仅当**对其每个非终结符 A 的任意两个不同的产生式 A→α 和 A→β：
1. **FIRST(α) ∩ FIRST(β) = ∅**
2. 若 ε ∈ FIRST(β)，则 **FIRST(α) ∩ FOLLOW(A) = ∅**

### 5.2 LL(1) 分析表的构造

```
M[A, a] 的填写规则（A 为非终结符，a 为终结符或 $）：

规则1：若 a ∈ FIRST(α)，则 M[A, a] = A→α
规则2：若 ε ∈ FIRST(α) 且 a ∈ FOLLOW(A)，则 M[A, a] = A→α
规则3：其他 = ERROR
```

**表中不应有任何格子含两个产生式**，否则不是 LL(1)。

### 5.3 为何 if-else 不是 LL(1)

```
statement → if-stmt | other
if-stmt  → if (exp) statement else-part
else-part → else statement | ε
exp → 0 | 1
```

FIRST(else statement) = {else}
FIRST(ε) = {ε}
FOLLOW(else-part) = {$, else}

**冲突**：else-part 的两条产生式：
- `else-part → else statement`：用到 M[else-part, else]
- `else-part → ε`：也用到 M[else-part, else]（因为 else ∈ FOLLOW(else-part)）

LL(1) 表中 M[else-part, else] 有两个条目 → **不是 LL(1)**。

---

## 6. 递归下降分析器的完整实现

### 6.1 课程实例一：表达式计算器（expcal.cpp）

**文法**（EBNF）：
```
exp   → term { ('+'|'-') term }
term  → factor { ('*'|'/') factor }
factor → '(' exp ')' | NUMBER
```

**完整实现**：
```cpp
enum TokenID {NUMBER, ADD, SUB, MUL, DIV, LBRACKET, RBRACKET, ENDINPUT};

void match(TokenID expect) {
    if (token.ID == expect) GetToken();
    else { cout << "Error at " << pos+1; exit(1); }
}

int exp() {
    int x = term();
    while (token.ID == ADD || token.ID == SUB) {
        TokenID op = token.ID;
        match(token.ID);
        if (op == ADD) x = x + term();
        if (op == SUB) x = x - term();
    }
    return x;
}

int term() {
    int x = factor();
    while (token.ID == MUL || token.ID == DIV) {
        TokenID op = token.ID;
        match(token.ID);
        if (op == MUL) x = x * factor();
        if (op == DIV) x = x / factor();
    }
    return x;
}

int factor() {
    int x;
    switch (token.ID) {
        case LBRACKET: match(LBRACKET); x = exp(); match(RBRACKET); break;
        case NUMBER:   x = token.val; match(NUMBER); break;
        default:       cout << "error at " << pos+1; exit(1);
    }
    return x;
}

int main() {
    cin.getline(buffer, 255);
    pos = 0;
    GetToken();
    int res = exp();
    if (token.ID == ENDINPUT) cout << "Result: " << res;
    else cout << "error at " << pos+1;
}
```

**执行 `3+4*5`**：
- exp 调用 term
  - term 调用 factor → 读 3，返回 3
  - term 的 while 检查：TOKEN=+，不是 * 或 /，退出
  - term 返回 3
- exp 的 while：TOKEN=+，match('+')
  - term 调用 factor → 读 4，返回 4
  - term 的 while：TOKEN=*，match('*')，factor 读 5，返回 5
  - 4*5=20，term 返回 20
- 3+20=23
- exp 返回 23

### 6.2 课程实例二：语法树构建器（exp2tree.cpp）

**核心**：产生式归约时创建树节点，连成树。

```cpp
struct BTreeNode {
    TokenStru data;
    BTreeNode *lc, *rc;
};

BTreeNode *exp() {
    BTreeNode *nodex = term();
    while (token.ID == ADD || token.ID == SUB) {
        BTreeNode *nodey = new BTreeNode;
        nodey->data = token;     // 运算符存为节点数据
        nodey->lc = nodex;       // 左子树：之前的结果
        match(token.ID);
        nodey->rc = term();      // 右子树：下一项
        nodex = nodey;
    }
    return nodex;
}

BTreeNode *term() {
    BTreeNode *nodex = factor();
    while (token.ID == MUL || token.ID == DIV) {
        BTreeNode *nodey = new BTreeNode;
        nodey->data = token;
        nodey->lc = nodex;
        match(token.ID);
        nodey->rc = factor();
        nodex = nodey;
    }
    return nodex;
}

BTreeNode *factor() {
    BTreeNode *nodex;
    switch (token.ID) {
        case LBRACKET:
            match(LBRACKET); nodex = exp(); match(RBRACKET); break;
        case NUMBER:
            nodex = new BTreeNode;
            nodex->data = token;
            nodex->lc = nodex->rc = NULL;
            match(NUMBER); break;
        default: cout << "error"; exit(1);
    }
    return nodex;
}

main() {
    GetToken();
    BTreeNode *root = exp();
    if (token.ID == ENDINPUT)
        preorder(root);   // 前序遍历输出语法树
}
```

**`3+4*5` 构建的树**：
```
       +
      / \
    3     *
         / \
        4   5
```
前序遍历输出：`+ 3 * 4 5`（即波兰表示法）

### 6.3 课程实例三：后缀表达式生成（exp2post.cpp）

```cpp
void exp() {
    TokenStru op;
    term();
    while (token.ID == ADD || token.ID == SUB) {
        op = token;
        match(token.ID);
        term();
        Gen(op);     // 操作符在操作数之后输出
    }
}

void term() {
    TokenStru op;
    factor();
    while (token.ID == MUL || token.ID == DIV) {
        op = token;
        match(token.ID);
        factor();
        Gen(op);
    }
}

void factor() {
    switch (token.ID) {
        case LBRACKET: match(LBRACKET); exp(); match(RBRACKET); break;
        case NUMBER:   Gen(token); match(NUMBER); break;
    }
}
```
`3*(5+4)` → 输出：`3 @ 5 @ 4 @ + *`（@ 分隔操作数）

### 6.4 课程实例四：栈机汇编生成（exp2asm.cpp）

```cpp
void exp() {
    term();
    while (token.ID == ADD || token.ID == SUB) {
        TokenID op = token.ID;
        match(token.ID);
        term();
        if (op == ADD) cout << "ADD" << endl;
        else           cout << "SUB" << endl;
    }
}

void factor() {
    switch (token.ID) {
        case LBRACKET: match(LBRACKET); exp(); match(RBRACKET); break;
        case NUMBER:   cout << "LDC  " << token.val << endl;
                       match(NUMBER); break;
    }
}
```
`3+4*5` → 输出：
```
LDC  3
LDC  4
LDC  5
MUL
ADD
```
**栈的执行过程**：
```
指令      栈（从左到右=栈底到顶）
LDC 3     [3]
LDC 4     [3, 4]
LDC 5     [3, 4, 5]
MUL       [3, 20]     (弹出4和5，压入20)
ADD       [23]        (弹出3和20，压入23)
```

### 6.5 课程实例五：四元组生成（exp2quadruples.cpp）

**含变量名**的文法处理——生成三地址码。

```cpp
struct OperandsNode {
    bool flag;       // true=临时变量，false=常量值
    int val;         // 常量值
    char NewVar[10]; // 变量名/临时变量名
};

void Gen(TokenStru token, OperandsNode x, OperandsNode y, OperandsNode z) {
    cout << "(" << token.op;
    OutputOperand(x); OutputOperand(y); OutputOperand(z);
    cout << " )" << endl;
}

OperandsNode exp() {
    OperandsNode x = term();      // 获取第一操作数
    while (token.ID == ADD || token.ID == SUB) {
        TokenStru op = token;
        match(token.ID);
        OperandsNode y = term();  // 获取第二操作数

        OperandsNode z;
        z.flag = 1;
        strcpy(z.NewVar, "t");    // 生成临时变量 t1, t2, ...
        itoa(varOrder, str, 10);
        strcat(z.NewVar, str);
        varOrder++;

        Gen(op, x, y, z);         // 输出四元组
        x = z;                    // 结果作为下一轮的操作数
    }
    return x;
}
```

**`a*(b+c)` 输出**：
```
( + , b , c , t1 )
( * , a , t1 , t2 )
```

### 6.6 课程实例六：说明语句的递归下降（Declare map.cpp）

**文法**：
```
DeclareStmt → Type VarList ;
VarList → ID { , ID }
Type → int | double | bool | char | float
```

```cpp
map<string, Symbol> SymTable;  // 符号表

void DeclareStmt() {
    Type();           // 读取类型
    VarList();        // 处理变量列表
    if (token.ID == SEMICOLON) GetToken();
    else { cout << "Error: Missing Semicolon!"; exit(1); }
}

void VarList() {
    if (LookUp(token.word) == 0)   // 重复定义检查
        { cout << "Error: duplicate!"; exit(1); }
    SymTable[token.word] = IDAttr;  // 写入符号表
    GetToken();
    while (token.ID == COMMA) {    // 逗号分隔的多个变量
        GetToken();
        if (LookUp(token.word) == 0)
            { cout << "Error: duplicate!"; exit(1); }
        SymTable[token.word] = IDAttr;
        GetToken();
    }
}

void Type() {
    if (token.ID == INT || token.ID == BOOL ||
        token.ID == DOUBLE || token.ID == CHAR ||
        token.ID == FLOAT) {
        IDAttr.type = token.ID;
        IDAttr.kind = "VAR";
        GetToken();
    } else { cout << "Error: Missing data type!"; exit(1); }
}
```

**处理 `int k, m, n;`**：
1. Type()：读到 int，设置 IDAttr.type = INT
2. VarList()：
   - k 不在符号表 → 加入，类型 INT
   - , → 读 m → 不在符号表 → 加入
   - , → 读 n → 不在符号表 → 加入
3. 检查分号

---

## 7. LL(1) 分析器（非递归/表驱动）

### 7.1 与递归下降的区别
- 递归下降：**代码递归**（每个非终结符一个函数）
- LL(1) 表驱动：**显式用栈模拟递归**，查表决定动作

### 7.2 表驱动 LL(1) 算法

```
初始化：栈 = [$] + [S]
while (栈非空) {
    X = 栈顶;
    if (X ∈ V_T ∪ {$}) {
        if (X == 当前输入符号) {
            if (X == $) 接受;
            else { 弹出栈顶; 读下一符号; }
        } else ERROR();
    } else {   // X ∈ V_N
        if (M[X][当前输入] == X→Y₁Y₂...Yₖ) {
            弹出 X;
            逆序压入 Yₖ, ..., Y₂, Y₁;  // Y₁ 在栈顶
        } else ERROR();
    }
}
```

### 7.3 例：表达式文法 LL(1) 分析

消除左递归后：
```
E  → T E'
E' → + T E' | ε
T  → F T'
T' → * F T' | ε
F  → ( E ) | i
```

FIRST 和 FOLLOW：
```
FIRST(F) = {(, i}
FIRST(T) = {(, i}
FIRST(E) = {(, i}
FIRST(E') = {+, ε}
FIRST(T') = {*, ε}

FOLLOW(E) = {$, )}
FOLLOW(E') = {$, )}
FOLLOW(T) = {+, $, )}
FOLLOW(T') = {+, $, )}
FOLLOW(F) = {*, +, $, )}
```

LL(1) 表（部分）：

| | i | + | * | ( | ) | $ |
|---|---|---|---|---|---|---|
| E | E→TE' | | | E→TE' | | |
| E' | | E'→+TE' | | | E'→ε | E'→ε |
| T | T→FT' | | | T→FT' | | |
| T' | | T'→ε | T'→*FT' | | T'→ε | T'→ε |
| F | F→i | | | F→(E) | | |

**分析 `i+i*i`**：
```
栈                 输入         动作
$E                 i+i*i$       E→TE'
$E'T               i+i*i$       T→FT'
$E'T'F             i+i*i$       F→i
$E'T'i             i+i*i$       match i
$E'T'              +i*i$        T'→ε
$E'                +i*i$        E'→+TE'
$E'T+              +i*i$        match +
$E'T               i*i$         T→FT'
$E'T'F             i*i$         F→i
$E'T'i             i*i$         match i
$E'T'              *i$          T'→*FT'
$E'T'F*            *i$          match *
$E'T'F             i$           F→i
$E'T'i             i$           match i
$E'T'              $            T'→ε
$E'                $            E'→ε
$                  $            接受！
```

---

## 8. 复习自测题

1. 消除以下文法的左递归：`A→Aa|Bb|Cc`, `B→Ab|Bb`, `C→Ac|Cb`
2. 计算以下文法的 FIRST 和 FOLLOW，并说明它是否是 LL(1)：
   `S→aA|bB`, `A→cdA|d`, `B→efB|f`
3. 写出手工递归下降分析器来处理以下文法：
   `S→if E then S else S | id = E`
4. 为 `E→TE'`, `E'→+TE'|ε`, `T→FT'`, `T'→*FT'|ε`, `F→(E)|i` 构造 LL(1) 分析表。
5. 课程代码 expcal.cpp 为什么需要先消除左递归？如果不消除会怎样？
