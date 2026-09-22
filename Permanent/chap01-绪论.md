# 第一章：绪论（深入讲解）

## 1. 编译程序概述

### 1.1 翻译程序的两种形式
| | 编译程序 (Compiler) | 解释程序 (Interpreter) |
|---|---|---|
| 工作方式 | 一次性翻译整个源程序为目标代码 | 逐条翻译并执行，不产生目标代码 |
| 输出 | 目标程序 (.exe, .obj) | 直接输出执行结果 |
| 执行速度 | 快（一次翻译，多次执行） | 慢（每次执行都要翻译） |
| 典型代表 | C/C++(gcc), Rust(rustc), Go | Python, JavaScript(早期), Ruby |

### 1.2 编译程序的六个阶段（详解）

```
源程序（字符流）
    │
    ▼
┌──────────────────────┐
│ ① 词法分析 (Scanner)  │  识别 Token：a[index]=4+2 → a [ index ] = 4 + 2
└──────────────────────┘
    │ Token流
    ▼
┌──────────────────────┐
│ ② 语法分析 (Parser)   │  构建语法树：检查 Token 序列是否符合文法规则
└──────────────────────┘
    │ 语法树 (AST)
    ▼
┌──────────────────────┐
│ ③ 语义分析 (Semantic) │  类型检查、作用域分析、符号表构建
└──────────────────────┘
    │ 带注解的语法树
    ▼
┌──────────────────────┐
│ ④ 中间代码生成+优化   │  生成中间表示，做常量折叠等优化（如 4+2→6）
└──────────────────────┘
    │ 中间代码 (IR)
    ▼
┌──────────────────────┐
│ ⑤ 目标代码生成        │  IR → 机器指令：MOV R0, index; MUL R0, 2; ...
└──────────────────────┘
    │ 目标代码
    ▼
┌──────────────────────┐
│ ⑥ 目标代码优化        │  机器相关优化：MUL R0,2 → SHL R0,1
└──────────────────────┘
    │ 优化后的目标代码
    ▼
  可执行程序
```

**贯穿全过程的两个模块**：
- **符号表管理**：记录变量名、类型、作用域、存储位置
- **错误处理**：报告错误位置和类型，尽可能恢复以发现更多错误

### 1.3 实例：a[index] = 4 + 2 的编译过程

**词法分析输出**（Token 流）：
```
标识符 a, 左括号 [, 标识符 index, 右括号 ], 赋值号 =, 数字 4, 加号 +, 数字 2
```

**语法分析输出**（抽象语法树）：
```
        =
       / \
    a[index] +
           / \
          4   2
```

**语义分析**：
- 检查 a 是否为数组、index 是否为整数类型
- 表达式 4+2 的类型为 int

**中间代码优化**：4+2 常量折叠为 6

**目标代码生成**（示意）：
```asm
MOV  R0, index    ; R0 = index 的值
MUL  R0, 2        ; R0 = R0 * 2（假设 int 占 2 字节）
MOV  R1, &a       ; R1 = 数组 a 的基地址
ADD  R1, R0       ; R1 = a[index] 的地址
MOV  *R1, 6       ; 将常量 6 存入该地址
```

**目标代码优化**：
```asm
MOV  R0, index
SHL  R0, 1        ; 移位代替乘法
MOV  &a[R0], 6    ; 地址计算合并
```

---

## 2. TINY 语言详解

TINY 是这门课的核心教学语言。你的四个实验就是对 TINY 编译器各阶段的实现。

### 2.1 TINY 的完整语法

**关键字**：`if`, `then`, `else`, `end`, `repeat`, `until`, `read`, `write`

**运算符和分隔符**：`+`, `-`, `*`, `/`, `<`, `=`, `{`, `}`, `(`, `)`, `:=`

**词法规则**：
```
letter   = a | b | ... | z | A | B | ... | Z
digit    = 0 | 1 | 2 | ... | 9
identifier = letter (letter | digit)*
number   = digit digit*
```

### 2.2 TINY 编译器架构

```
globals.h ─── 全局定义
main.c    ─── 主程序入口
  │
  ├── scan.h / scan.c     ─── 词法分析器（对应实验1）
  ├── parse.h / parse.c   ─── 语法分析器（对应实验2、3）
  ├── symtab.h / symtab.c ─── 符号表（对应实验3）
  ├── analyze.h / analyze.c── 语义分析（对应实验3）
  ├── code.h / code.c     ─── 中间代码
  └── cgen.h / cgen.c     ─── 目标代码生成
```

**主流程**（main.c 的核心四步）：
```c
syntaxTree = parse();           // 语法分析 → 语法树
buildSymtab(syntaxTree);        // 构建符号表
typeCheck(syntaxTree);          // 类型检查
codeGen(syntaxTree, codefile);  // 代码生成
```

### 2.3 示例：TINY 程序及其 TM 输出

一个 TINY 程序 `sample.tny` 编译后生成 `sample.tm`（TM 虚拟机汇编代码），然后通过 `tm sample.tm` 执行。

C++ 预处理作为类比：
```
C++ 程序                      TINY 程序
#include<iostream.h>          —
main()                        —
{                             —
  int i;                      —
  cin>>i;                     read i;
  i:=i+1;                     i := i + 1;
  if (i<>3)                   if (i <> 3)
    cout<<"ok";                 write "ok";
}                             end
```

---

## 3. 词法分析器的渐进式构建（课程演示程序）

课程提供了四个版本，展示了词法分析器从简单到复杂的演进：

### 第一版：expLexl.cpp — 只识别数字和运算符
```cpp
enum TokenID {NUMBER, ADD, SUB, MUL, DIV, LBRACKET, RBRACKET, ENDINPUT};
// 只识别：数字、+、-、*、/、(、)
// 输入：12+34  → 输出：token序列
```
核心逻辑：
1. 跳过空白符（空格和Tab）
2. 如果当前字符是数字 → 连续读入数字组成整数 → 返回 NUMBER token
3. 否则用 switch 匹配运算符 → 返回对应 token
4. 遇到 `\0` → 返回 ENDINPUT

### 第二版：expLexl-var.cpp — 增加标识符识别
```cpp
enum TokenID {NUMBER, ID, ADD, SUB, MUL, DIV, LBRACKET, RBRACKET, ENDINPUT};
// 新增 ID 类型
```
新增逻辑：
```cpp
if (isalpha(buffer[pos])) {
    // 读入字母、数字、下划线组成的标识符
    while (isalpha(buffer[pos]) || isdigit(buffer[pos]) || buffer[pos]=='_') {
        token.word[len++] = buffer[pos++];
    }
    token.ID = ID;
}
```
可以识别：`abc+34`, `a_b1`, `var1` 等含变量名的表达式。

### 第三版：expLexl-var-float.cpp — 增加浮点数识别
```cpp
// 先读整数部分
while (buffer[pos] >= '0' && buffer[pos] <= '9')
    { s = s*10 + buffer[pos] - '0'; pos++; }
token.ID = NUMBER; token.val = s;

// 如果遇到小数点，继续读小数部分
if (buffer[pos] == '.') {
    int len = 0;
    s = 0; pos++;  // 跳过小数点
    while (buffer[pos] >= '0' && buffer[pos] <= '9')
        { s = s*10 + buffer[pos] - '0'; len++; pos++; }
    token.val = token.val + s / pow(10, len);
}
```
可以识别：`3.45`, `0.123`, `12.34` 等浮点数。

### 第四版：expLexl-if-map.cpp — 增加关键字和比较运算符
```cpp
enum TokenID {IF, ELSE, FOR, WHILE, ASSIGN, EQ, LT, GT, LTE, GTE,
              NOTEQ, NUMBER, ID, ADD, SUB, MUL, DIV, LBRACKET,
              RBRACKET, SEMICOLON, ENDINPUT};

map<string, TokenID> keywords;  // 用 map 存储保留字

void init() {
    keywords["if"]    = IF;
    keywords["else"]  = ELSE;
    keywords["for"]   = FOR;
    keywords["while"] = WHILE;
}
```
新增：
- **关键字识别**：通过 map 区分保留字和普通标识符
- **双字符运算符**：`>=`, `<=`, `==`, `!=`（预读下一个字符判断）
- **分号**作为语句分隔符

### 总结：词法分析器的核心结构
```cpp
void GetToken() {
    跳过空白;
    if (当前是数字)     → 读数字(可能含小数点);
    else if (当前是字母) → 读字母/数字 → 查关键字表判断是保留字还是标识符;
    else               → switch 匹配单字符/双字符运算符;
    if (到字符串结尾)    → 返回 ENDINPUT;
}
```

---

## 4. 课程要点 & 考试提示

### 4.1 编译与解释的区别
- 编译是**翻译**后将控制权交给目标程序
- 解释是翻译一条、执行一条

### 4.2 编译的六个阶段要能按顺序默写
每个阶段的**输入**和**输出**是什么？

### 4.3 TINY 语言
- 知道 TINY 的保留字有哪些
- 理解 TINY 编译器的模块结构
- 课程强调了 Rust 语言实现这些模块

### 4.4 课程评分
平时(30%) + 考试(70%)，实验一~四对应词法分析、正则→DFA、语法树生成、LALR(1)语法分析生成器。

---

## 5. 复习自测题

1. 编译程序分为哪六个阶段？每个阶段做什么？
2. 解释程序与编译程序有什么区别？
3. 以 `a = b + c * d` 为例，描述各阶段如何处理这条语句。
4. TINY 语言的标识符和数字如何定义？
5. 词法分析器如何区分关键字和普通标识符？
