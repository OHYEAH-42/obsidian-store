# 第六章：语法制导翻译 — 深入讲解

## 1. 语法制导翻译的核心思想

**将语义动作"附着"在产生式上，在语法分析的同时完成翻译。**

两种实现方式：
| | 递归下降方式 | LR 方式 |
|---|---|---|
| 动作时机 | 函数调用前后 | 归约时 |
| 属性传递 | 函数参数/返回值 | 栈中属性 |
| 适用场景 | 手写编译器 | 自动生成（Yacc） |

---

## 1.5 属性和属性文法——动机与本

### 为什么需要属性？

语法分析只告诉你 `3+4*5` 这个结构是对的（E→E+T→...），但你**拿到结果 23 了吗？**没有。

```
语法分析的输出：
      E          ← 只是结构，没有"值"
     /|\
    E + T
    |   |
    n   n
```

**属性**就是给每个语法符号挂上"附加数据"：

```
      E (val=23)   ← 这个 E 携带了属性 val=23
     /|\
E(val=3) + T(val=20)
  |         |\
 n(3)   T(val=4) * F(val=5)
         |          |
        n(4)       n(5)
```

有了属性之后，这棵树不仅知道"结构是对的"，还知道"最终结果是 23"。

### 属性在代码里早就在用了，只是不叫这个名字

回头看你最熟悉的 expcal.cpp：

```cpp
int exp() {                    // 返回值 = E 的综合属性 val
    int x = term();            // x = T 的属性 val（从子节点取）
    while (token == '+') {
        match('+');
        x = x + term();        // 子节点属性 → 计算 → 父节点属性
    }
    return x;                  // ↑ 向上传递
}
```

每一行对应属性文法的概念：

| 代码 | 属性文法中对应的概念 |
|------|-------------------|
| `int exp()` 的返回值 | 非终结符 **E** 的综合属性 `E.val` |
| `int x = term()` | 从子节点 **T** 获取属性: `T.val` |
| `x = x + term()` | 语义规则: `E.val = E₁.val + T.val` |
| `return x` | 将综合属性向上传给父节点 |

**函数返回值 = 综合属性**，就这么简单。

### 两种属性：方向不同，用途不同

#### 综合属性（Synthesized）⬆ 子→父

**从子节点算出父节点**。最常见的属性类型。

产生式写法：
```
E → E₁ + T    { E.val = E₁.val + T.val }
                 ↑父       ↑子1       ↑子2
E → n         { E.val = n.val }
```

**你的三个课程实例全都在用综合属性**：

| 课程实例 | 综合属性产出 |
|---------|------------|
| expcal.cpp | `E.val = 计算结果（整数）` |
| exp2tree.cpp | `E.root = 语法树根节点指针` |
| exp2gen.cpp | `E.code = 生成的指令序列` |

在递归下降中，综合属性就是**函数返回值**。在 LR 分析中，综合属性在**归约时**从栈上子节点的属性算出。

#### 继承属性（Inherited）⬇ 父→子 / ➡ 兄→弟

**从父节点或左边的兄弟节点传过来**。

典型场景：**类型声明**

```
int k, m, n;
```

这里的语义是：`int` 这个类型要**传给**后面 `k, m, n` 三个变量。

属性文法表示：
```
D → T V              { V.type = T.type }       ← T 的 type 传给 V（继承属性）
V₁ → V₂ , id         { id.type = V₁.type;      ← 类型继续往下传
                       V₂.type = V₁.type }
V → id               { id.type = V.type }      ← 最终传给 id
T → int              { T.type = int }
```

回到你课程里的 Declare map.cpp：

```cpp
void Type() {
    IDAttr.type = token.ID;    // T.type 的来源
    // IDAttr 就是"继承属性"，等待传给后面的变量
}

void VarList() {
    SymTable[token.word] = IDAttr;  // 把继承属性"注入"每个变量
    GetToken();
    while (token.ID == COMMA) {
        GetToken();
        SymTable[token.word] = IDAttr;  // 同一个类型传给每个变量
        GetToken();
    }
}
```

`IDAttr` 是一个**全局变量**，充当了"从 Type 传递到每个 id"的**继承属性**。用全局变量传继承属性，是递归下降中的常见做法（另一种方式是用函数参数）。

### 属性文法的形式化定义（考试可能考）

**属性文法 `A(G, V, F)`**：
- **G**：一个上下文无关文法
- **V**：属性的集合。每个文法符号 X 关联一组属性 V(X)
- **F**：语义规则集合。对每个产生式 `p: X₀ → X₁ X₂ ... Xₙ`，给出如何计算各符号的属性

**考试写法的样子**：
```
产生式                    语义规则
E → n                   { E.val = n.val }
E₁ → E₂ + T             { E₁.val = E₂.val + T.val }
D → T V                 { V.type = T.type }
```

### 属性和 LR 分析

在 LR 分析（如 SLR(1)）中，归约时正好是计算综合属性的时机：

```
栈                         输入          归约产生式     属性计算
$0 n(3) 2                  +4$          E → n          E.val = 3
$0 E(3) 1                  +4$          —               —
$0 E(3) 1 + 3 n(4) 4       $            E → n          E.val = 4
$0 E(3) 1 + 3 E(4) X       $            E → E + n      E₁.val = 3 + 4 = 7
```

每个语法符号的属性**压在一起放在栈里**，归约时从栈中取出子节点属性，算出父节点属性后再入栈。

### 一句话总结

| 概念 | 一句话 | 递归下降中的体现 |
|------|--------|---------------|
| 属性 | 挂在语法符号上的"附加数据" | 变量值、类型、树指针 |
| 综合属性 | 从子节点往父节点算（⬆） | **函数返回值** |
| 继承属性 | 从父节点/兄弟节点传（⬇/➡） | **全局变量**或**函数参数** |
| 属性文法 | "谁有什么属性 + 怎么算"的规则书 | 每条产生式的语义动作代码 |
| 语义规则 | 属性之间的计算公式 | while 循环里的 `x = x + term()` |

---

## 2. 课程实例一：表达式计算（expcal.cpp）

**文法**：`E→T{+T}`, `T→F{*F}`, `F→(E)|n`

```cpp
int exp() {
    int x = term();               // 先计算左操作数
    while (TOKEN == '+' || TOKEN == '-') {
        TokenID op = TOKEN;
        match(TOKEN);
        if (op == ADD) x = x + term();   // 左结合：x 累积结果
        if (op == SUB) x = x - term();
    }
    return x;
}
```

**3+4*5 的执行**——逐帧追踪：
```
调用exp()
  → term()
      → factor() → match(3), 返回 3
      → while: TOKEN='+', 不是 * 或 /, 退出
      → 返回 3
  → while: TOKEN='+', match('+')
      → term()
          → factor() → match(4), 返回 4
          → while: TOKEN='*', match('*')
              → factor() → match(5), 返回 5
          → 4*5=20, 返回 20
      → 3+20=23
  → TOKEN=ENDINPUT, 返回 23
```

**要点**：运算的顺序由**调用顺序**决定——先算 factor(4)*factor(5)=20，再算 3+20=23。这就是**优先级**和**结合性**的实现。

---

## 3. 课程实例二：语法树构建（exp2tree.cpp）

```cpp
BTreeNode *exp() {
    BTreeNode *nodex = term();
    while (TOKEN == ADD || TOKEN == SUB) {
        BTreeNode *nodey = new BTreeNode;  // 创建操作符节点
        nodey->data = token;
        nodey->lc = nodex;         // 左子树：之前累积的结果
        match(token);
        nodey->rc = term();        // 右子树：新的 term
        nodex = nodey;             // 新节点成为当前结果
    }
    return nodex;
}
```

**3+4*5 的建树过程**：
```
步骤1: term() 返回节点 3
      nodex → [3]

步骤2: TOKEN='+', 创建 nodey
      nodey → [+]
             /  \
           [3]  ?(待term)
      match('+'), term()构建 [4] → [*] → [5] 的子树
      nodey.rc = [*]
                    / \
                  [4] [5]
      nodex = nodey
      →    [+]
          /   \
        [3]   [*]
              / \
            [4] [5]
```

---

## 4. 课程实例三：栈机汇编代码生成（exp2gen.cpp + asm-exec.cpp）

### 4.1 代码生成器（exp2gen.cpp）

```cpp
char *Instruction[5] = {"LDC", "ADD", "SUB", "MUL", "DIV"};

void Gen(TokenStru token) {
    cout << Instruction[token.ID];
    if (token.ID == NUMBER) cout << " " << token.val << endl;
    else cout << endl;
}

void factor() {
    switch (TOKEN) {
        case '(': match('('); exp(); match(')'); break;
        case NUMBER:
            Gen(token);    // LDC n —— 将常量加载到栈
            match(NUMBER); break;
    }
}

void term() {
    factor();
    while (TOKEN == MUL || TOKEN == DIV) {
        TokenStru op = token;
        match(token);
        factor();
        Gen(op);    // MUL 或 DIV
    }
}

void exp() {
    term();
    while (TOKEN == ADD || TOKEN == SUB) {
        TokenStru op = token;
        match(token);
        term();
        Gen(op);    // ADD 或 SUB
    }
}
```

**3+4*5 的代码**：
```
LDC 3        ← factor 读 3
LDC 4        ← factor 读 4
LDC 5        ← factor 读 5
MUL          ← term 中 while 输出（遇到 *）
ADD          ← exp 中 while 输出（遇到 +）
```

### 4.2 解释执行器（asm-exec.cpp）

```cpp
stack<int> st;

void AsmExec() {
    char buffer[20], Opstr[5], Operands[10];
    while (cin.getline(buffer, 20)) {
        strncpy(Opstr, buffer, 3);  // 取操作码

        if (strcmp(Opstr, "LDC") == 0) {  // 加载常量
            int val = atoi(buffer + 4);   // 取操作数
            st.push(val);
        }
        else if (strcmp(Opstr, "ADD") == 0) {
            int op1 = st.top(); st.pop();
            int op2 = st.top(); st.pop();
            st.push(op1 + op2);    // 后进先出！
        }
        else if (strcmp(Opstr, "MUL") == 0) {
            int op1 = st.top(); st.pop();
            int op2 = st.top(); st.pop();
            st.push(op1 * op2);
        }
        // SUB, DIV 同理
    }
}

main() {
    AsmExec();
    cout << st.top();  // 栈顶即为最终结果
}
```

**执行 `3+4*5` 的汇编**：
```
指令      栈（底→顶）
LDC 3     [3]
LDC 4     [3, 4]
LDC 5     [3, 4, 5]
MUL       [3, 20]     ← 弹出 5,4; 4*5=20 压栈
ADD       [23]        ← 弹出 20,3; 3+20=23 压栈
结果: 23
```

**注意**：减法/除法中操作数的顺序——`op2 - op1`（先弹出的是右操作数）。

---

## 5. 课程实例四：四元组/三地址码生成（exp2quadruples.cpp）

### 5.1 核心结构

```cpp
struct OperandsNode {
    bool flag;        // false=常量值, true=变量/临时变量
    int val;          // 常量值时存放值
    char NewVar[10];  // 变量/临时变量名
};

int varOrder = 1;  // 临时变量计数器：t1, t2, t3...

void Gen(TokenStru token, OperandsNode x, OperandsNode y, OperandsNode z) {
    cout << "(" << token.op;
    OutputOperand(x);   // 左操作数
    OutputOperand(y);   // 右操作数
    OutputOperand(z);   // 结果
    cout << " )" << endl;
}
```

### 5.2 表达式翻译逻辑

```cpp
OperandsNode exp() {
    OperandsNode x = term();  // 获取第一个操作数
    while (TOKEN == ADD || TOKEN == SUB) {
        TokenStru op = token;
        match(token);
        OperandsNode y = term();  // 获取第二个操作数

        // 创建临时变量存放结果
        OperandsNode z;
        z.flag = 1;
        sprintf(z.NewVar, "t%d", varOrder++);

        Gen(op, x, y, z);  // (op, x, y, z) → (+, a, b, t1)
        x = z;              // 结果作为下一轮的操作数
    }
    return x;
}
```

**`a*(b+c)` 的输出**：
```
( + , b , c , t1 )
( * , a , t1 , t2 )
```

### 5.3 翻译过程追踪

```
调用 exp()
  → term()
      → factor() → 遇到 ID 'a', x = a
      → while: TOKEN='*', match('*')
           → factor() → 遇到 '(' → match('(') → exp()
               → term() → factor() → ID 'b', x = b
               → while: TOKEN='+', match('+')
                    → term() → factor() → ID 'c', y = c
                    → z = t1, Gen(+, b, c, t1), x = t1
               → match(')')
               → 返回 t1
           → y = t1
           → z = t2, Gen(*, a, t1, t2)
      → 返回 t2
```

---

## 6. LR 分析中的属性文法

### 6.1 综合属性（最常用）

在 LR 分析中，**归约时**计算综合属性。

```
E → n         { E.val = n.val; }
E → E₁ + n    { E.val = E₁.val + n.val; }
```

**LR 分析计算 3+4+5**：
```
栈              输入          动作/属性
$0             3+4+5$       s2
$0 n(3) 2      +4+5$        r2, E.val = 3
$0 E(3) 1      +4+5$        s3
$0 E(3) 1 + 3  4+5$         s2
$0 E(3) 1 + 3 n(4) 4       +5$  r2, E.val = 4
  → 但这里需要正确的状态转移...
$0 E(3) 1 + 3 E(4) X        +5$  r1, E.val = 3+4 = 7
  ...
```

### 6.2 属性文法定义

`A(G, V, F)`：
- **G**：上下文无关文法
- **V**：属性的并集，每个文法符号 X 关联一组属性 V(X)
- **F**：语义规则，对每个产生式 `p: X₀→X₁X₂...Xₙ` 给出属性计算公式

### 6.3 三种翻译示例

**翻译1：表达式求值**
```
E → n      { E.val = n }
E₂ → E₁ + n { E₂.val = E₁.val + n }
```

**翻译2：构建语法树**
```
E → n      { p = new node; p->data = n;
             p->lc = p->rc = NULL;
             E.root = p; }
E₂ → E₁ + n {
    p = new node; p->data = n;
    nr = new node; nr->data = '+';
    nr->lc = E₁.root; nr->rc = p;
    E₂.root = nr;
}
```

**翻译3：生成代码**
```
E → n      { Gen(LDC, n) }
E → E + n  { Gen(LDC, n); Gen(ADI) }
```

---

## 7. 符号表管理（Declare map.cpp）

### 7.1 符号表结构

```cpp
struct Symbol {
    int type;       // INT, DOUBLE, BOOL, CHAR, FLOAT
    char *kind;     // "VAR", "FUNC", "ARRAY" 等
};

map<string, Symbol> SymTable;  // 简单的符号表实现

int LookUp(char *IDName) {
    auto it = SymTable.find(IDName);
    if (it != SymTable.end()) return 0;  // 已存在
    else return 1;                        // 未找到
}
```

### 7.2 说明语句的翻译

**文法**：
```
DeclareStmt → Type VarList ;
VarList → id { , id }
Type → int | double | bool | char | float
```

```cpp
void DeclareStmt() {
    Type();                        // 设置 IDAttr.type
    VarList();                     // 逐个登记变量
    match(SEMICOLON);
}

void VarList() {
    if (LookUp(token.word) == 0)
        error("重复定义!");
    SymTable[token.word] = IDAttr;  // 登记（类型+种类）
    GetToken();
    while (token.ID == COMMA) {
        GetToken();
        if (LookUp(token.word) == 0)
            error("重复定义!");
        SymTable[token.word] = IDAttr;
        GetToken();
    }
}

void Type() {
    if (token.ID 是 INT/DOUBLE/BOOL/CHAR/FLOAT 之一) {
        IDAttr.type = token.ID;   // 记录当前类型
        IDAttr.kind = "VAR";
        GetToken();
    } else error("缺少类型!");
}
```

**处理 `int k, m, n;`**：
1. Type() → IDAttr.type = INT
2. VarList → k 不在符号表，加入 SymTable["k"]=(INT, "VAR")
3. 遇到逗号 → m 加入
4. 遇到逗号 → n 加入
5. 匹配分号

### 7.3 LR 方式的符号表管理

使用属性传递类型信息：
```
D → T V        { V.type = T.type; }
V₁ → V₂ , id   { enter(id, V₂.type); V₁.type = V₂.type; }
V → id         { enter(id, V.type); }
T → int        { T.type = int; }
T → double     { T.type = double; }
```

---

## 8. 类型检查

在表达式求值的基础上加入类型信息：

```
E₁ → E₂ + T {
    if (E₂.type == int && T.type == int)
        { E₁.val = E₂.val + T.val; E₁.type = int; }
    else if (E₂.type == double && T.type == double)
        { E₁.val = E₂.val + T.val; E₁.type = double; }
    else if (E₂.type == int && T.type == double)
        { E₁.val = double(E₂.val) + T.val; E₁.type = double; }
    else if (E₂.type == double && T.type == int)
        { E₁.val = E₂.val + double(T.val); E₁.type = double; }
    else ERROR("类型不匹配");
}
```

---

## 9. 后缀表达式生成（exp2post.cpp 详解）

### 9.1 原理

递归下降中嵌入输出，操作数先输出、操作符后输出：

```cpp
void factor() {
    switch (TOKEN) {
        case NUMBER:
            post[p++] = token.val;   // 操作数立即输出
            post[p++] = '@';         // 分隔符
            match(NUMBER);
            break;
        case '(':
            match('('); exp(); match(')');
            break;
    }
}

void term() {
    factor();
    while (TOKEN == '*') {
        match('*'); factor();
        post[p++] = '*';  // 操作符在操作数之后输出
    }
}

void exp() {
    term();
    while (TOKEN == '+') {
        match('+'); term();
        post[p++] = '+';
    }
}
```

**`3*(5+4)` → `3 @ 5 @ 4 @ + *`**

---

## 10. 控制流语句与回填（Backpatching）

### 10.1 布尔表达式的中间代码

**文法**：
```
BE → BE || BT | BT
BT → BT && BF | BF
BF → !BF | (BE) | E rop E | i rop i | i
```

**翻译思路**：每个布尔表达式有两个出口：
- **TC (True Chain)**：值为真时跳转去哪
- **FC (False Chain)**：值为假时跳转去哪

### 10.2 基本布尔表达式的翻译

```
BF → i₁ rop i₂:
    BF.TC = NextStat;          // 真出口指向下条指令
    BF.FC = NextStat + 1;      // 假出口指向再下条
    Gen(Jrop, i₁, i₂, 0);      // 条件跳转（目标待填）
    Gen(J, _, _, 0);            // 无条件跳转（目标待填）
```

**`a > b` 的四元组**：
```
(1) (J>, a, b, ?)     ← TC = 1 (目标待定)
(2) (J, _, _, ?)      ← FC = 2 (目标待定)
```

### 10.3 短路求值的实现

**`&&`（与）的翻译**：
```
BTand → BT &&:
    BackPatch(BT.TC, NextStat);   // BT 为真时：进入 && 的右侧
    BTand.FC = BT.FC;              // BT 为假时：短路，跳过右侧

BT → BTand BF:
    BT.TC = BF.TC;                 // 两者都真 → 真
    BT.FC = Merge(BTand.FC, BF.FC);  // 任一假 → 假
```

**`||`（或）的翻译**：
```
BEor → BE ||:
    BackPatch(BE.FC, NextStat);   // BE 为假时：进入 || 的右侧
    BEor.TC = BE.TC;              // BE 为真时：短路，跳过右侧

BE → BEor BT:
    BE.FC = BT.FC;                // 两者都假 → 假
    BE.TC = Merge(BEor.TC, BT.TC);  // 任一真 → 真
```

### 10.4 if 语句的回填

```
C → if (BE):
    BackPatch(BE.TC, NextStat);   // 条件真 → 执行 then 部分
    C.Chain = BE.FC;              // 条件假 → 跳到 else 或出口

T → C S₁ else:                   // 有 else
    q = NextStat;
    Gen(J, _, _, 0);              // 跳过 else 部分
    BackPatch(C.Chain, NextStat); // 条件假 → 执行 else 部分
    T.Chain = Merge(S₁.Chain, q); // 合并退出链

S → C S₁:                        // 无 else
    S.Chain = Merge(C.Chain, S₁.Chain);
```

**if (A && B) x = 1; else x = 0; 的四元组**：
```
(1) (JNZ, A, _, 3)      ← A 真 → 检查 B
(2) (J, _, _, 9)        ← A 假 → else
(3) (JNZ, B, _, 5)      ← B 真 → then
(4) (J, _, _, 9)        ← B 假 → else
(5) (=, 1, _, x)        ← then: x=1
(6) (J, _, _, 10)       ← 跳过 else
(7) —                    （保留）
(8) —                    （保留）
(9) (=, 0, _, x)        ← else: x=0
(10)                     ← 出口
```

### 10.5 while 语句的回填

```
W → while:
    W.Head = NextStat;           // 记录循环头

Wd → W (BE):
    BackPatch(BE.TC, NextStat);  // 条件真 → 进入循环体
    Wd.Chain = BE.FC;            // 条件假 → 退出循环
    Wd.Head = W.Head;

S → Wd S₁:
    BackPatch(S₁.Chain, Wd.Head); // 循环体结束 → 跳回条件判断
    Gen(J, _, _, Wd.Head);
    S.Chain = Wd.Chain;           // 循环出口
```

**while (A && B) x = 1; 的四元组**：
```
(1) (JNZ, A, _, 3)      ← 回填到这里（循环头：1）
(2) (J, _, _, 7)        ← A 假 → 退出
(3) (JNZ, B, _, 5)      ← B 真 → 循环体
(4) (J, _, _, 7)        ← B 假 → 退出
(5) (=, 1, _, x)        ← 循环体
(6) (J, _, _, 1)        ← 跳回循环头
(7)                      ← 出口
```

---

## 11. 关键函数实现

```cpp
// 回填：将链 P 中所有指令的第4字段填为 t
void BackPatch(P, t) {
    Q = P;
    while (Q != 0) {
        S = Q;                      // 当前指令编号
        Q = 取 S 的下一条链指针;     // 下一跳
        将指令 S 的目标字段设为 t;
    }
}

// 合并两条链
Pointer Merge(P1, P2) {
    if (P2 == 0) return P1;
    P = P2;
    while (P->next != 0) P = P->next;  // 找 P2 的链尾
    P->next = P1;                        // 把 P1 接在 P2 末尾
    return P2;
}
```

---

## 12. TINY factorial 程序翻译示例

TINY 源码求 n! 的四元组：
```
(1) (RD, _, _, x)       ← read x
(2) (:=, 1, _, fact)    ← fact = 1
(3) (j<, x, 0, 10)      ← if x < 0 goto 结束
(4) (=, x, 0, 9)        ← if x == 0 goto ...
(5) (*, fact, x, T1)    ← T1 = fact * x
(6) (:=, T1, _, fact)   ← fact = T1
(7) (-, x, 1, T2)       ← T2 = x - 1
(8) (:=, T2, _, x)      ← x = T2
(9) (J, _, _, 3)        ← goto 循环头
(10) (WR, _, _, fact)   ← write fact
```

---

## 13. 复习自测题

1. 用递归下降分析器为 `3+4*5` 生成四元组序列。
2. 用递归下降分析器为 `a*(b+c)` 生成后缀表达式。
3. 用递归下降分析器为 `3*(5-2)` 生成栈机汇编代码，并模拟栈执行过程。
4. 写出 `if (a>b || c<d) x=1; else x=0;` 的四元组序列（含回填）。
5. 写出 `while (a>b && c<d) x=x+1;` 的四元组序列（含回填）。
6. 符号表的主要操作有哪些？简述 LOOKUP 和 ENTER 的区别。
