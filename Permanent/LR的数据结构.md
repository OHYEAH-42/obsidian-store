## 数据结构（C++ 定义）

> 约定：以下代码默认已 `#include <bits/stdc++.h>` 或包含了必要的标准库头文件，并 `using namespace std;`。

---

### Token

```cpp
struct Token {
    string type;         // 终结符类型，如 "id", "+", "num"
    string value;        // 实际值，如 "x", "123"
    int    line;         // 行号（错误报告用）
    int    column;       // 列号（错误报告用）
};
```

---

### TokenStream 输入流

封装 Token 序列，提供流式读取、lookahead、末尾自动追加 `$`。

```cpp
class TokenStream {
    vector<Token> tokens;
    int pos;

public:
    TokenStream(const vector<Token>& input) : tokens(input), pos(0) {
        // 末尾自动追加 EOF 标记 $
        if (tokens.empty() || tokens.back().type != "$")
            tokens.push_back({"$", "", -1, -1});
    }

    Token  current() const          { return tokens[pos]; }
    void   advance()                { if (!isEnd()) pos++; }
    bool   isEnd()  const           { return tokens[pos].type == "$"; }
    Token  peek(int k = 1) const {
        int idx = pos + k;
        return idx < (int)tokens.size() ? tokens[idx] : tokens.back();
    }
};
```

---

### 产生式 Production

```cpp
struct Production {
    string            left;       // 产生式左部（非终结符）
    vector<string>    right;      // 产生式右部（符号序列）

    int  length()   const { return (int)right.size(); }
    bool isEpsilon() const { return right.empty(); }       // ε 产生式
};
```

---

### 文法规则 Grammar

```cpp
struct Grammar {
    vector<Production> productions;     // 产生式数组
    string             startSymbol;    // 文法起始符号（如 "E"）
    int                terminalCount;
    int                nonTerminalCount;
    set<string>        terminals;      // 终结符集合
    set<string>        nonTerminals;   // 非终结符集合
    set<string>        syncTokens;     // 同步 Token 集合（错误恢复用，可选）

    bool isNonTerminal(const string& s) const {
        return nonTerminals.count(s) > 0;
    }
    bool isTerminal(const string& s) const {
        return terminals.count(s) > 0;
    }
};
```

---

### First 与 Follow 集合

```cpp
// FIRST(X) = { a ∈ T | X ⇒* a... } ∪ { ε 若 X ⇒* ε }
map<string, set<string>> first;

// FOLLOW(A) = { a ∈ T | S ⇒* ...Aa... } ∪ { $ 若 A 是文法的开始符号 }
map<string, set<string>> follow;
```

---

### 项目 Item

#### LR(0) / SLR(1) 项

```cpp
struct LR0Item {
    int prodIdx;        // 产生式序号（Grammar.productions 中的索引）
    int dot;            // 点的位置（0 ~ production.length()）

    bool operator<(const LR0Item& other) const {
        if (prodIdx != other.prodIdx) return prodIdx < other.prodIdx;
        return dot < other.dot;
    }
    bool operator==(const LR0Item& other) const {
        return prodIdx == other.prodIdx && dot == other.dot;
    }
};
```

#### LR(1) / LALR(1) 项

```cpp
struct LR1Item {
    int           prodIdx;      // 产生式序号
    int           dot;          // 点的位置
    set<string>   lookahead;    // 前瞻符集合

    bool operator<(const LR1Item& other) const {
        if (prodIdx != other.prodIdx) return prodIdx < other.prodIdx;
        if (dot    != other.dot)    return dot    < other.dot;
        return lookahead < other.lookahead;
    }
    bool operator==(const LR1Item& other) const {
        return prodIdx == other.prodIdx
            && dot      == other.dot
            && lookahead == other.lookahead;
    }
};
```

---

### 状态 State（即项集）

```cpp
// LR(0) / SLR(1) 状态：LR0Item 的集合
using LR0State = set<LR0Item>;

// LR(1) / LALR(1) 状态：LR1Item 的集合
using LR1State = set<LR1Item>;
```

---

### DFA

#### LR(0) / SLR(1) DFA

```cpp
struct LR0DFA {
    Grammar                      augProds;   // 扩广文法（第 0 条是 S' → S）
    vector<LR0State>             states;     // 状态集合（下标即状态编号）
    vector<map<string, int>>     trans;      // 转移表 [状态][符号] = 下一状态
};
```

#### LR(1) DFA

```cpp
struct LR1DFA {
    Grammar                      augProds;   // 扩广文法
    vector<LR1State>             states;     // 状态集合
    vector<map<string, int>>     trans;      // 转移表
};
```

#### LALR(1) DFA

```cpp
struct LALR1DFA {
    Grammar                      augProds;       // 扩广文法
    vector<LR1State>             states;         // 状态集合（合并同心集后）
    vector<map<string, int>>     trans;          // 转移表
    vector<int>                  LR1ToLALR1;     // LR(1)状态 → LALR(1)状态 的映射
};
```

---

### LR 分析表（Action / Goto）

```cpp
struct LRParsingTable {
    // Action[状态][终结符] = "s3" / "r2" / "acc" / ""（空串表示报错）
    vector<map<string, string>>  action;

    // Goto[状态][非终结符] = 下一状态编号（-1 表示无转移）
    vector<map<string, int>>     gotoTable;
};
```
