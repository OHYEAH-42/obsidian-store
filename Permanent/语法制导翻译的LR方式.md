---
date: 2026-07-03
tags:
  - 编译原理
cssclasses:
  - "[[中间代码生成]]"
  - "[[语义分析]]"
aliases:
---
以[[LR]]为蓝本

# 数据结构

相比较[[LR#数据结构 LR的数据结构]]，这里需要增加[[中间表示]]的数据结构和valStack属性栈

## [[后缀式]]的数据结构

```
stack <string> valstack                      //属性为字符串，只要在栈中存属性即可
```

## [[三元组]]的数据结构

```
stack <string> valstack                      //属性 — 变量名或编号引用 "(1)"

struct Triple { string op, arg1, arg2; };    //三元组结构体
vector<Triple> triples;                      //三元组数组
int NextStat = 1;                            //下一三元组的编号
```

## [[四元组]]的数据结构

```
stack<string> valStack;                      //属性 — 变量名或临时变量名 "t1"

struct Quad { string op, arg1, arg2; int result; };   //result 存链或目标编号，0=链尾
vector<Quad> quads = {{"", "", "", 0}};       //quads[0] 占位，指令从 1 开始编号
int NextStat = 1;                             //下一条四元组的编号
int tempCount = 0;                            //临时变量命名计数

// 生成四元组，返回其编号
int Gen(string op, string a1, string a2, int res) {
    quads.push_back({op, a1, a2, res});
    return NextStat++;                        //返回当前编号后自增
}
// 临时变量名 = "t" + 指令编号（第 q 条指令的结果存入 tq）
```



# 框架代码

归约部分会根据需要生成的[[中间表示]]不同而不同，其它部分则大差不差，以下先给出主循环（移进 + 接受）的框架，再分别给出三种 IR 的归约动作。

### 主循环（通用）

```cpp
// ══════════════════════════════════════════════════════════════════════
// LR 语法制导翻译 — 主循环
//
//  三栈架构:
//    stateStack   ─  状态栈，驱动分析表查找
//    symStack     ─  符号栈，记录已识别的文法符号（辅助调试/错误恢复）
//    valStack     ─  属性栈，存综合属性值（三种 IR 的共用通道）
//
//  三种操作:
//    移进 (shift)  ─  读入一个 Token，三栈同步 push
//    归约 (reduce) ─  按产生式反向替换，三栈同步 pop 再 push
//    接受 (accept) ─  分析成功
// ══════════════════════════════════════════════════════════════════════

// ──────────── 数据结构 ────────────
stack<int>    stateStack;                    // 状态栈，存状态编号 0, 3, 5...
stack<string> symStack;                     // 符号栈，存文法符号 "+", "E", "id"...
stack<string> valStack;                     // 属性栈，存 IR 相关属性值
                                            //   后缀式 → 子串,  三元组 → "(n)",  四元组 → "t1"

TokenStream input(tokens);                   // 输入 Token 流，自带 $ 结尾
const LRParsingTable& parsingTable;          // 分析表（LR 自动机生成）
const Grammar& grammar;                      // 文法（产生式集合）

// ──────────── 初始化 ────────────
stateStack.push(0);                          // 从状态 0 出发
symStack.push("$");                         // 栈底标记

// ──────────── 主循环 ────────────
while (true) {
    // ① 查表：当前状态 × 当前输入 → 动作
    int    s   = stateStack.top();            // 栈顶状态
    string a   = input.current().type;        // 当前输入符号（终结符）
    string act = parsingTable.action[s][a];   // 动作 = "s3"/"r2"/"acc"/""(报错)

    // ── 错误：Action 表项为空 ──
    if (act.empty()) {
        cerr << "语法错误: 状态 " << s
             << " 遇到 " << a << endl;
        break;
    }

    // ═══════════════════════════════════════════════
    // ② 移进 (shift)  — 读入 Token，入栈
    // ═══════════════════════════════════════════════
    if (act[0] == 's') {
        // 例: act = "s5" → 将输入符号移进并转到状态 5
        int next = stoi(act.substr(1));        // 取出目标状态编号

        stateStack.push(next);                 // 状态入栈
        symStack.push(a);                      // 符号入栈：当前输入的终结符
        valStack.push(input.current().value);  // 属性入栈：词素值（如 "x", "123"）

        input.advance();                       // 读入下一个 Token
    }

    // ═══════════════════════════════════════════════
    // ③ 归约 (reduce) — 按产生式反向替换，执行语义动作
    // ═══════════════════════════════════════════════
    else if (act[0] == 'r') {
        // 例: act = "r2" → 用第 2 条产生式归约
        int prodIdx = stoi(act.substr(1));     // 产生式编号
        Production& prod = grammar.productions[prodIdx];
        int rhsLen = prod.length();            // 产生式右部符号个数

        // ── 第 1 步：三栈同步弹出 |RHS| 个元素 ──
        // 产生式 E → E + T （rhsLen = 3）为例：
        //   归约前三栈顶：
        //     stateStack: ... s5        ← 进入 E 后的状态
        //     symStack:   ... E  T  "+"  ← 右部符号
        //     valStack:   ... E_val T_val "+" ← 属性
        //   归约就是将栈顶这 3 个符号替换为产生式左部 E
        for (int i = 0; i < rhsLen; i++) {
            stateStack.pop();                  // 弹状态
            symStack.pop();                    // 弹符号
        }

        // 收集 RHS 各符号的属性值（从右向左弹出 valStack）
        vector<string> attrs(rhsLen);
        for (int i = rhsLen - 1; i >= 0; i--) {
            attrs[i] = valStack.top();
            valStack.pop();
        }

        // ── 第 2 步：语义动作（关键差异点！）──
        //  根据产生式计算左部综合属性
        //  三种 IR 的具体实现见下文
        // [在此插入归约语义动作]
        string result = /* 由 IR 实现填入 */;

        // ── 第 3 步：三栈同步入栈 ──
        //  新的栈顶状态 × 产生式左部 → Goto 转移
        int gotoState = parsingTable.gotoTable[stateStack.top()][prod.left];
        stateStack.push(gotoState);            // 新状态入栈
        symStack.push(prod.left);              // 左部非终结符入栈（如 E）
        valStack.push(result);                 // 左部综合属性入栈

    }

    // ═══════════════════════════════════════════════
    // ④ 接受 (accept) — 分析成功
    // ═══════════════════════════════════════════════
    else if (act == "acc") {
        // 状态栈只剩 0 + goto(0, S')，输入已读完
        cout << "分析成功!" << endl;
        break;
    }
}
```

### 归约时的语义动作

以下为上述 `// [在此插入归约语义动作]` 处的三种实现，每次选其一。

---
#### 1. 生成后缀式（逆波兰式）

```cpp
// ══════════════════════════════════════
// 归约语义动作 —— 后缀式
// ══════════════════════════════════════

// attrs[0..rhsLen-1] 已在主框架第 1 步从 valStack 中弹出
// 这里只需计算 result，主框架第 3 步会 push 回 valStack

// 产生式编号约定（实际编号取决于 augmented grammar 中的顺序）：
//   1: E → E + T    2: E → E - T    3: E → T
//   4: E → -T
//   5: T → T * F    6: T → T / F    7: T → F
//   8: F → ( E )    9: F → i

switch (prodIdx) {
    case 1:  // E → E + T
    case 2:  // E → E - T
        // 二元运算：左操作数 + 右操作数 + 运算符
        result = attrs[0] + " " + attrs[2] + " " + attrs[1];
        break;
    case 3:  // E → T
        result = attrs[0];          // 单产生式传递
        break;
    case 4:  // E → -T （一元负）
        result = "0 " + attrs[1] + " -";
        break;
    case 5:  // T → T * F
    case 6:  // T → T / F
        // 二元运算：左操作数 + 右操作数 + 运算符
        result = attrs[0] + " " + attrs[2] + " " + attrs[1];
        break;
    case 7:  // T → F
        result = attrs[0];          // 单产生式传递
        break;
    case 8:  // F → ( E )
        result = attrs[1];          // 剥括号
        break;
    case 9:  // F → i
        result = attrs[0];          // 词素本身
        break;
    default:
        // 其它产生式：原序拼接
        for (int i = 0; i < rhsLen; i++) {
            if (i > 0) result += " ";
            result += attrs[i];
        }
}
// result 由主框架第 3 步 push 回 valStack
```

---
#### 2. 生成三元组

需要配合前面定义的数据结构：

```cpp
// ══════════════════════════════════════
// 归约语义动作 —— 三元组
// ══════════════════════════════════════

// 前置数据结构（主循环前全局定义）：
//   struct Triple { string op, arg1, arg2; };
//   vector<Triple> triples;
//   int NextStat = 1;

// attrs[0..rhsLen-1] 已在主框架第 1 步中弹出
// 这里只需计算 result

// 产生式编号（与后缀式同）：
//   1: E → E + T    2: E → E - T    3: E → T
//   4: E → -T
//   5: T → T * F    6: T → T / F    7: T → F
//   8: F → ( E )    9: F → i

switch (prodIdx) {
    case 1:  // E → E + T
    case 2:  // E → E - T
        triples.push_back({attrs[1], attrs[0], attrs[2]});
        result = "(" + to_string(NextStat++) + ")";
        break;
    case 3:  // E → T
        result = attrs[0];
        break;
    case 4:  // E → -T
        triples.push_back({"neg", attrs[1], ""});
        result = "(" + to_string(NextStat++) + ")";
        break;
    case 5:  // T → T * F
    case 6:  // T → T / F
        triples.push_back({attrs[1], attrs[0], attrs[2]});
        result = "(" + to_string(NextStat++) + ")";
        break;
    case 7:  // T → F
        result = attrs[0];
        break;
    case 8:  // F → ( E )
        result = attrs[1];
        break;
    case 9:  // F → i
        result = attrs[0];
        break;
    default:
        for (int i = 0; i < rhsLen; i++) {
            if (i > 0) result += " ";
            result += attrs[i];
        }
}
// result 由主框架第 3 步 push 回 valStack
```

---
#### 3. 生成四元组

需要配合前面定义的数据结构：

```cpp
// ══════════════════════════════════════
// 归约语义动作 —— 四元组
// ══════════════════════════════════════

// 前置数据结构（主循环前全局定义）：
//   struct Quad { string op, arg1, arg2, result; };
//   vector<Quad> quads;
//   string NewTemp()  { static int n; return "t" + to_string(++n); }
//   void Gen(string op, string a1, string a2, string r) {
//       quads.push_back({op, a1, a2, r});
//   }

// attrs[0..rhsLen-1] 已在主框架第 1 步中弹出
// 这里只需计算 result

// 产生式编号：
//   0: S' → S        （赋值语句）
//   1: E → E + T     2: E → E - T     3: E → T
//   4: E → -T
//   5: T → T * F     6: T → T / F     7: T → F
//   8: F → ( E )     9: F → i
//   ...

switch (prodIdx) {
    case 1:  // E → E + T
    case 2:  // E → E - T
    {
        int q = Gen(attrs[1], attrs[0], attrs[2], 0);
        result = "t" + to_string(q);
        break;
    }
    case 3:  // E → T
        result = attrs[0];
        break;
    case 4:  // E → -T
    {
        int q = Gen("neg", attrs[1], "", 0);
        result = "t" + to_string(q);
        break;
    }
    case 5:  // T → T * F
    case 6:  // T → T / F
    {
        int q = Gen(attrs[1], attrs[0], attrs[2], 0);
        result = "t" + to_string(q);
        break;
    }
    case 7:  // T → F
        result = attrs[0];
        break;
    case 8:  // F → ( E )
        result = attrs[1];
        break;
    case 9:  // F → i
        result = attrs[0];
        break;
    default:
        for (int i = 0; i < rhsLen; i++) {
            if (i > 0) result += " ";
            result += attrs[i];
        }
}
// result 由主框架第 3 步 push 回 valStack
```

---

### 具体语句的翻译：

[[中间代码生成#几种常见语句的翻译方法]]

### 小结

| 环节 | 后缀式 | 三元组 | 四元组 |
|------|--------|--------|--------|
| 移进 | 词素值入 `valStack` | 词素值入 `valStack` | 词素值入 `valStack` |
| 归约 | 拼接为后缀串入栈 | 生成 Triple，压入引用编号 | 生成 Quad + 临时变量，压入临时变量名 |
| 接受 | 打印 `valStack.top()`（即最终后缀式） | `triples` 数组即为结果 | `quads` 数组即为结果 |
