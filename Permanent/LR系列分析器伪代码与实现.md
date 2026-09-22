# LR 语法分析器：从伪代码到完整实现

---

## 一、用大白话理解算法

LR 分析就像**做一道需要反复"合并"的菜**：

```
栈 = 你的操作台（放已经处理好的东西）
输入 = 还没处理的原材料（从左往右一个个拿）
分析表 = 菜谱（告诉你现在该干什么）

两种操作：
  移进 = 把原材料拿到操作台上（栈增长）
  归约 = 操作台上的东西够了，合并成一个中间品（栈缩小）
```

例子：n + n
文法：E→E+n|n

```
栈           输入      动作
$            n+n$     拿一个原材料（移进 n）
$ n          +n$      够了，合并成 E（归约 E→n）
$ E          +n$      继续拿（移进 +）
$ E +        n$       拿（移进 n）
$ E + n      $        够了，合并（归约 E→E+n）
$ E          $        接受！
```

---

## 二、伪代码（考试版，可直接默写）

```
算法：LR 语法分析
输入：Token 数组 input[1..n]，LR 分析表 Action、Goto
输出：归约序列（或报错）

stack.push('$');
stack.push(0);          // 初始状态
ip = 1;                 // 指向第一个输入符号

while (true) {
    s = stack.top();            // 栈顶状态
    a = input[ip];              // 当前输入符号

    if (Action[s][a] == "移进 sⱼ") {
        stack.push(a);          // 压入文法符号
        stack.push(j);          // 压入新状态
        ip++;                   // 读下一个符号
    }
    else if (Action[s][a] == "归约 rⱼ") {
        // 第 j 条产生式: A → X₁ X₂ ... Xₖ
        弹出 2×k 个元素;         // k个符号 + k个状态
        t = stack.top();        // 露出新栈顶
        stack.push(A);          // 压入左部符号
        stack.push(Goto[t][A]); // 压入新状态
        // 注意：ip 不变！
    }
    else if (Action[s][a] == "接受") {
        输出"分析成功";
        return;
    }
    else {
        输出"语法错误: 行" + input[ip].line;
        return;
    }
}
```

---

## 三、C++ 完整实现（可直接运行）

### 3.1 数据结构定义

```cpp
#include <iostream>
#include <stack>
#include <map>
#include <vector>
#include <string>
using namespace std;

// --- 符号编码 ---
// 终结符: n=1, +=2
// 非终结符: E=101 (加100方便区分)
// 特殊: $=0

const int TERM_N   = 1;
const int TERM_PLUS = 2;
const int TERM_EOF = 0;      // $

const int NONTERM_E  = 101;

// --- Token 结构 ---
struct Token {
    int type;       // 符号编码
    int value;      // 语义值（如数字的字面量）
    int line;       // 行号，用于报错
};

// --- 产生式存储 ---
struct Rule {
    int left;                    // 左部非终结符
    vector<int> right;           // 右部符号序列
    int length() { return right.size(); }
};

// 产生式库
vector<Rule> Grammar = {
    {NONTERM_E, {}},                              // (0) 占位
    {NONTERM_E, {NONTERM_E, TERM_PLUS, TERM_N}},  // (1) E → E + n
    {NONTERM_E, {TERM_N}},                         // (2) E → n
};

// --- 分析表 ---
// 用 map 实现稀疏表: Action[state][symbol] = action_string
// "s2" = 移进到状态2, "r2" = 按产生式2归约, "acc" = 接受

map<int, map<int, string>> Action;
map<int, map<int, int>>    Goto;

void buildTable() {
    // Action 表
    Action[0][TERM_N]   = "s2";
    Action[1][TERM_PLUS]= "s3";
    Action[1][TERM_EOF] = "acc";
    Action[2][TERM_PLUS]= "r2";
    Action[2][TERM_EOF] = "r2";
    Action[3][TERM_N]   = "s4";
    Action[4][TERM_PLUS]= "r1";
    Action[4][TERM_EOF] = "r1";

    // Goto 表
    Goto[0][NONTERM_E] = 1;
}
```

### 3.2 核心分析器

```cpp
class LRParser {
private:
    stack<int> stateStack;ymbolStack;   // 符号栈（用于调试）
    vector<Token> input;      // Token 数组
    int ip;                   // 输入指针

public:
    LRParser(vector<Token>& tokens) : input(tokens), ip(0) {
        stateStack.push(0);   // 初始状态
    }

    bool parse() {
        while (true) {
            int s = stateStack.top();           // 步骤1: 取状态
            int a = currentToken();             // 步骤2: 取输入

            if (Action[s].count(a) == 0) {      // 步骤3: 查表
                error("语法错误");
                return false;
            }

            string act = Action[s][a];

            if (act[0] == 's') {                // 移进
                int nextState = stoi(act.substr(1));
                shift(a, nextState);
            }
            else if (act[0] == 'r') {           // 归约
                int ruleNo = stoi(act.substr(1));
                reduce(ruleNo);
            }
            else if (act == "acc") {            // 接受
                cout << "分析成功！" << endl;
                return true;
            }
        }
    }

private:
    int currentToken() {
        if (ip < input.size())
            return input[ip].type;
        return TERM_EOF;    // 输入读完，返回 $
    }

//移进要做的事：
//1. 进入nextState状态
//2. 移入符号symbol
    void shift(int symbol, int nextState) {
        cout << "移进: 符号=" << symbol
             << ", 进入状态 " << nextState << endl;
        symbolStack.push(symbol);
        stateStack.push(nextState);
        ip++;                                // ← 指针前进
    }


//归约要做的事：
//1. 弹出产生式右侧长度数量的符号栈
//2. 弹出产生式右侧长度数量的状态栈
//3. Goto转移到栈顶元素和产生式左部的状态，符号栈和状态栈入栈
    void reduce(int ruleNo) {
        Rule& rule = Grammar[ruleNo];
        int len = rule.length();

        cout << "归约: 按产生式(" << ruleNo << ") "
             << rule.left << " → ";
        for (int x : rule.right) cout << x << " ";
        cout << "  (弹出 " << len << " 个符号)" << endl;

        // 弹出: len个符号 + len个状态 = 2*len 个
        for (int i = 0; i < len; i++) {
            symbolStack.pop();
            stateStack.pop();
        }

        // 查 Goto
        int t = stateStack.top();               // 露出的栈顶状态
        int A = rule.left;                      // 产生式左部
        int gotoState = Goto[t][A];

        cout << "  Goto[" << t << "][" << A << "] = " << gotoState << endl;

        // 压入 A + 新状态
        symbolStack.push(A);
        stateStack.push(gotoState);
        // 注意：ip 不变！
    }

    void error(string msg) {
        int line = (ip < input.size()) ? input[ip].line : -1;
        cout << msg << " (第 " << line << " 行, 符号="
             << currentToken() << ")" << endl;
    }
};
```

### 3.3 main 函数

```cpp
int main() {
    buildTable();

    // 输入: n + n
    vector<Token> tokens = {
        {TERM_N,    3, 1},    // n (val=3)
        {TERM_PLUS, 0, 1},    // +
        {TERM_N,    4, 1},    // n (val=4)
    };

    LRParser parser(tokens);
    parser.parse();

    return 0;
}
```

### 运行输出

```
移进: 符号=1, 进入状态 2
归约: 按产生式(2) 101 → 1   (弹出 1 个符号)
  Goto[0][101] = 1
移进: 符号=2, 进入状态 3
移进: 符号=1, 进入状态 4
归约: 按产生式(1) 101 → 101 2 1   (弹出 3 个符号)
  Goto[0][101] = 1
分析成功！
```

---

## 四、带语义值的完整版

实际编译器中归约时要**计算属性**。在课程 `expcal.cpp` 的栈机模拟中也一样：

```cpp
class LRParserWithValue {
private:
    stack<int> stateStack;
    stack<int> valStack;        // ← 新增：语义值栈，和符号栈对应

    void reduceWithValue(int ruleNo) {
        Rule& rule = Grammar[ruleNo];

        // 在弹出之前，先从 valStack 取子节点的属性
        int val = 0;
        if (ruleNo == 1) {          // E → E + n
            int v3 = valStack.top(); valStack.pop();   // n 的值
            valStack.pop();                             // + 无值
            int v1 = valStack.top(); valStack.pop();   // E 的值
            val = v1 + v3;
            cout << "  计算: " << v1 << " + " << v3 << " = " << val << endl;
        }
        else if (ruleNo == 2) {     // E → n
            val = valStack.top(); valStack.pop();
            cout << "  取值: n = " << val << endl;
        }

        // 弹出状态栈
        for (int i = 0; i < rule.length(); i++)
            stateStack.pop();

        // Goto
        int t = stateStack.top();
        int gotoState = Goto[t][rule.left];

        valStack.push(val);             // 属性值压入 valStack
        stateStack.push(gotoState);
    }
};
```

### 分析 `n(3) + n(4)` 的语义值追踪

```
步骤  栈(状态)    栈(值)       输入   动作
1     0           []          n+$    移进 n(3)
2     0 2         [3]         +$     归约 E→n: 弹出值[3], val=3
3     0 1         [3]         +$     移进 +
4     0 1 3       [3, -]      n$     移进 n(4)
5     0 1 3 4     [3, -, 4]   $      归约 E→E+n: v3=4, v1=3, val=7
6     0 1         [7]         $      acc, 结果=7
```

---

## 五、算法逐行动画（最重要的一节）

文法：E→E+n|n
以 `n + n` 为例，SLR(1) 表：

```
     n    +    $    E
0    s2            1
1         s3   acc
2         r2   r2
3    s4
4         r1   r1
```

### 第1轮：状态0，输入 n

```
栈: [$][0]          输入: n + n $  ← ip指向n

查表: Action[0][n] = s2
动作: 移进 n，进入状态2

栈: [$][0][n][2]    输入: + n $    ← ip前进到+
```

### 第2轮：状态2，输入 +

```
栈: [$][0][n][2]    输入: + n $    ← ip指向+

查表: Action[2][+] = r2
产生式(2): E → n, 右部长度 = 1

动作: 弹出1个符号+1个状态 = 弹出 [n][2]

栈: [$][0]          输入: + n $    ← ip不动！

t = 栈顶状态 = 0
Goto[0][E] = 1
压入 [E][1]

栈: [$][0][E][1]    输入: + n $    ← ip仍然在+
```

### 第3轮：状态1，输入 +

```
栈: [$][0][E][1]    输入: + n $

查表: Action[1][+] = s3
动作: 移进 +，进入状态3

栈: [$][0][E][1][+][3]  输入: n $     ← ip前进到n
```

### 第4轮：状态3，输入 n

```
栈: [$][0][E][1][+][3]  输入: n $

查表: Action[3][n] = s4
动作: 移进 n，进入状态4

栈: [$][0][E][1][+][3][n][4]  输入: $    ← ip前进到$
```

### 第5轮：状态4，输入 $

```
栈: [$][0][E][1][+][3][n][4]  输入: $

查表: Action[4][$] = r1
产生式(1): E → E + n, 右部长度 = 3

动作: 弹出3个符号+3个状态 = 弹出 [E][1][+][3][n][4]

栈: [$][0]          输入: $       ← ip不动

t = 栈顶状态 = 0
Goto[0][E] = 1
压入 [E][1]

栈: [$][0][E][1]    输入: $
```

### 第6轮：状态1，输入 $

```
栈: [$][0][E][1]    输入: $

查表: Action[1][$] = acc
→ 分析成功！接受！
```

---

## 六、核心调试技巧

### 技巧1：画栈的快照

每一步都记下：`状态栈 | 符号栈 | 剩余输入 | 动作`，格式如下：

```
状态   栈              输入   动作
1      $0             n+n$   s2
2      $0 n 2         +n$    r2
3      $0 E 1         +n$    s3
...
```

### 技巧2：归约三步口诀

```
归约 = 弹 → 查 → 压

弹：弹 2k 个
查：查栈顶  t，查 Goto[t][A]
压：压 A  +  Goto[t][A]
```

### 技巧3：空产生式陷阱

`A → ε` 归约时 k=0，弹0个，但压入2个——栈反而变高了！

```
归约前:  $ 0 ... X m     ← 栈顶状态 m
归约:   弹出0个
        t = m (栈顶没变！)
        压入 [A][Goto[m][A]]

归约后:  $ 0 ... X m A Goto[m][A]
```

---

## 七、LR(0)/SLR(1)/LR(1)/LALR(1) 代码差异

四种方法只有**填表逻辑**不同，分析器代码**完全一样**。

```cpp
// 四种方法共用同一个 parse() 函数
// 区别只在 buildTable() 中：

void buildTable_LR0() {
    // 归约项目：对所有终结符填 rⱼ
    for (int a : ALL_TERMINALS) {
        Action[i][a] = "r" + to_string(ruleNo);
    }
}

void buildTable_SLR1() {
    // 归约项目：只对 FOLLOW(A) 中的符号填 rⱼ
    for (int a : FOLLOW[leftPart]) {
        Action[i][a] = "r" + to_string(ruleNo);
    }
}

void buildTable_LR1() {
    // 归约项目：只对精确前瞻符填 rⱼ
    for (int a : item.lookaheads) {
        Action[i][a] = "r" + to_string(item.ruleNo);
    }
}

void buildTable_LALR1() {
    // 与 LR(1) 相同，但状态来自合并同心集后的 DFA
    // 填表规则不变
}
```
