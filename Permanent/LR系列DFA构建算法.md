---
date: 2026-06-14
tags:
  - 编译原理
---

# LR 系列 DFA 构建算法：从伪代码到完整实现

代码中
\# 表示 ε

---

## 一、大白话理解

DFA 的每个状态 = **一堆带点项目的集合**，表示"分析到这儿，可能处于哪些情况"。

```
项目 E → E·+ n 的意思是："我刚看到了 E，接下来期望 +
```

DFA 构造过程的本质：从初始状态 I₀ 出发，不断问"如果接下来读到一个符号 X，会进入什么状态？"，把新状态找出来，直到没有新状态为止。

---

## 二、数据结构定义

```cpp
// ═══════════════════════════════════════════════
// 全局基础定义
// ═══════════════════════════════════════════════

// 符号编码约定（课程风格：终结符用原始编码，非终结符+100偏移）
const int TERM_EOF   = 0;    // $
const int TERM_PLUS  = 1;    // +
const int TERM_N     = 2;    // n
const int TERM_LP    = 3;    // (
const int TERM_RP    = 4;    // )
const int TERM_A     = 5;    // a
const int TERM_B     = 6;    // b
// ... 其他终结符

const int NONTERM_OFFSET = 100;
const int NONTERM_E  = 101;  // E
const int NONTERM_T  = 102;  // T
const int NONTERM_S  = 103;  // S
const int NONTERM_A  = 104;  // A
const int NONTERM_B  = 105;  // B
// ... 其他非终结符

bool isTerminal(int sym)     { return sym < NONTERM_OFFSET; }
bool isNonTerminal(int sym)  { return sym >= NONTERM_OFFSET; }


// ═══════════════════════════════════════════════
// 产生式
// ═══════════════════════════════════════════════

struct Rule {
    int left;                  // 左部非终结符编号
    vector<int> right;         // 右部符号序列
    int length() const { return right.size(); }
};

vector<Rule> Grammar;          // 全局产生式库

// 示例：E' → E (编号0), E → E + n (编号1), E → n (编号2)
void initGrammar() {
    // (0) E' → E     (E' 实际在代码中用 E 表示，拓广产生式)
    Grammar.push_back({NONTERM_E, {NONTERM_E}});
    // (1) E → E + n
    Grammar.push_back({NONTERM_E, {NONTERM_E, TERM_PLUS, TERM_N}});
    // (2) E → n
    Grammar.push_back({NONTERM_E, {TERM_N}});
}
int startRule = 0;   // 拓广产生式的编号


// ═══════════════════════════════════════════════
// LR(0) 项目与状态
// ═══════════════════════════════════════════════

struct LR0Item {
    int ruleNo;      // 产生式编号（Grammar 中的下标）
    int dotPos;      // 点的位置，0=最左边，length()=最右边（归约项目）

    bool operator==(const LR0Item& o) const {
        return ruleNo == o.ruleNo && dotPos == o.dotPos;
    }
    bool operator<(const LR0Item& o) const {
        if (ruleNo != o.ruleNo) return ruleNo < o.ruleNo;
        return dotPos < o.dotPos;
    }
};

struct LR0State {
    set<LR0Item> items;        // 该状态包含的所有 LR(0) 项目
};


// ═══════════════════════════════════════════════
// LR(1) 项目与状态
// ═══════════════════════════════════════════════

struct LR1Item {
    int ruleNo;                // 产生式编号
    int dotPos;                // 点的位置
    set<int> lookaheads;       // 前瞻符集合 ← LR(1) 相比 LR(0) 唯一多出的字段
};

// LR(1) 状态用 map<核心, 前瞻符集> 存储
// 优点：同一个核心的不同前瞻符自动合并在一起，方便后续合并同心集
struct LR1State {
    // key = (ruleNo, dotPos), value = 该核心的所有前瞻符
    map<pair<int,int>, set<int>> items;

    // 遍历所有项目，对每个 (ruleNo, dotPos, lookahead) 调用回调
    void forEachItem(function<void(int, int, int)> fn) const {
        for (auto& [key, las] : items) {
            for (int la : las) {
                fn(key.first, key.second, la);
            }
        }
    }

    // 提取核心（去掉前瞻符）—— 用于判断同心集
    set<pair<int,int>> getCore() const {
        set<pair<int,int>> core;
        for (auto& [key, _] : items)
            core.insert(key);
        return core;
    }
};


// ═══════════════════════════════════════════════
// DFA 存储结构（全局）
// ═══════════════════════════════════════════════

// LR(0) DFA
vector<LR0State> lr0States;
map<int, map<int, int>> lr0Goto;   // Goto[状态][符号] = 目标状态

// LR(1) DFA
vector<LR1State> lr1States;
map<int, map<int, int>> lr1Goto;

// LALR(1) DFA
vector<LR1State> lalrStates;       // 复用 LR1State
map<int, map<int, int>> lalrGoto;


// ═══════════════════════════════════════════════
// FIRST 集（构建 LR(1) DFA 时需要）
// ═══════════════════════════════════════════════

map<int, set<int>> FIRST;    // FIRST[X] = X的FIRST集，ε编码为 0

// 计算符号串 right[start..end] 连接前瞻符 a 的 FIRST 集
void computeFirstOfString(const vector<int>& right, int start, int a,
                          set<int>& result) {
    for (int i = start; i < right.size(); i++) {
        set<int>& fi = FIRST[right[i]];
        result.insert(fi.begin(), fi.end());
        result.erase(0);            // 去掉 ε

        if (fi.count(0) == 0)       // 该符号推不出 ε → 停止
            return;
    }
    result.insert(a);               // 全部能推 ε → a 继承进来
}
```

---

## 三、LR(0) DFA 构建

### 3.1 伪代码

```
算法：构造 LR(0) 项目集规范族

输入：拓广文法 G'（已添加 S' → S）
输出：状态集合 States，转移函数 Goto

1. I₀ = Closure({S' → ·S})
2. States = {I₀}
3. while (States 有变化)
4.     for (每个状态 I ∈ States)
5.         for (每个文法符号 X ∈ V_N ∪ V_T)
6.             J = Goto(I, X)
7.             if (J ≠ ∅ 且 J 不在 States 中)
8.                 将 J 加入 States
9.                 记录转移 Goto(I, X) = J

──────────────────────────────────

Closure(I)：
    J = I
    while (J 有变化)
        for (J 中每个项目 A → α·Bβ)      // 点后是非终结符 B
            for (B 的每个产生式 B → γ)
                if (B → ·γ 不在 J 中)
                    将 B → ·γ 加入 J
    return J

──────────────────────────────────

Goto(I, X)：
    J = ∅
    for (I 中每个项目 A → α·Xβ)
        将 A → αX·β 加入 J            // 点跨过 X
    return Closure(J)
```

### 3.2 手工演算示例

文法：`E' → E,  E → E + n | n`

**步骤1：I₀ = Closure({E' → ·E})**

```
种子:  E' → ·E

E' → ·E        点后是 E（非终结符）→ 把 E 的产生式加进来
  加入 E → ·E + n
  加入 E → ·n

E → ·E + n     点后是 E → 但 E 的产生式已有，不重复
E → ·n         点后是 n → n 是终结符，不展开

I₀ = { E' → ·E,  E → ·E + n,  E → ·n }
```

**步骤2：从 I₀ 出发求 Goto**

```
Goto(I₀, E):
  哪些项目的点后是 E？
    E' → ·E  → 点跨过 → E' → E·
    E  → ·E + n → 点跨过 → E → E·+ n
  
  J = {E' → E·,  E → E·+ n}
  Closure(J): 这两个项目点后分别是 无 和 +，都不是非终结符 → 不再展开
  → I₁ = {E' → E·,  E → E·+ n}

Goto(I₀, n):
  E → ·n → 点跨过 → E → n·
  J = {E → n·}
  Closure(J): 点后为空，不展开
  → I₂ = {E → n·}

Goto(I₀, +):
  没有任何项目的点后是 + → 返回空
```

**步骤3：从 I₁ 出发**

```
Goto(I₁, +):
  E → E·+ n → 点跨过 → E → E+·n
  J = {E → E+·n}
  Closure: 点后是 n（终结符），不展开
  → I₃ = {E → E+·n}
```

**步骤4：从 I₃ 出发**

```
Goto(I₃, n):
  E → E+·n → 点跨过 → E → E+n·
  → I₄ = {E → E+n·}
```

**最终 DFA**：

```
         E           +           n
  → (I₀)───→(I₁)───→(I₃)───→(I₄)
      │ n
      └───→(I₂)
```

### 3.3 C++ 实现

```cpp
// --- LR(0) 项目 ---
struct LR0Item {
    int ruleNo;      // 产生式编号
    int dotPos;      // 点的位置 (0=最左, rule.length=最右)
    
    bool operator==(const LR0Item& o) const {
        return ruleNo == o.ruleNo && dotPos == o.dotPos;
    }
    bool operator<(const LR0Item& o) const {
        if (ruleNo != o.ruleNo) return ruleNo < o.ruleNo;
        return dotPos < o.dotPos;
    }
};

// --- LR(0) 状态 ---
struct LR0State {
    set<LR0Item> items;
};

// --- 文法 ---
struct Rule {
    int left;                  // 左部非终结符
    vector<int> right;         // 右部符号序列
};

extern vector<Rule> Grammar;   // 产生式库（全局）

// ==================== Closure ====================
LR0State closure(LR0State I) {
    LR0State J = I;
    bool changed = true;
    
    while (changed) {
        changed = false;
        set<LR0Item> snapshot = J.items;  // 快照，避免迭代中插入
        
        for (const LR0Item& item : snapshot) {
            Rule& rule = Grammar[item.ruleNo];
            
            // 点不在末尾，且点后是非终结符
            if (item.dotPos < rule.right.size()) {
                int B = rule.right[item.dotPos];   // 点后符号
                
                if (isNonTerminal(B)) {
                    // 对 B 的每个产生式，加入 B → ·γ
                    for (int r = 0; r < Grammar.size(); r++) {
                        if (Grammar[r].left == B) {
                            LR0Item newItem = {r, 0};  // 点在开头
                            if (J.items.count(newItem) == 0) {
                                J.items.insert(newItem);
                                changed = true;
                            }
                        }
                    }
                }
            }
        }
    }
    return J;
}

// ==================== Goto ====================
LR0State goTo(LR0State I, int X) {
    LR0State J;
    
    for (const LR0Item& item : I.items) {
        Rule& rule = Grammar[item.ruleNo];
        
        if (item.dotPos < rule.right.size() &&
            rule.right[item.dotPos] == X) {
            // 点跨过 X
            LR0Item moved = {item.ruleNo, item.dotPos + 1};
            J.items.insert(moved);
        }
    }
    
    return closure(J);  // 对跨过后的集合求闭包
}

// ==================== 构建完整 DFA ====================
vector<LR0State> states;          // 所有状态
map<int, map<int, int>> dfaGoto;  // Goto[state][symbol] = nextState

void buildLR0DFA(int startRule) {
    states.clear();
    dfaGoto.clear();
    
    // I₀ = Closure({S' → ·S})
    LR0State I0;
    I0.items.insert({startRule, 0});   // startRule = S' → S 的编号
    I0 = closure(I0);
    states.push_back(I0);
    
    // 收集所有文法符号（终结符 + 非终结符）
    set<int> allSymbols;
    for (Rule& r : Grammar)
        for (int sym : r.right)
            allSymbols.insert(sym);
    
    // 不断扩展
    bool changed = true;
    while (changed) {
        changed = false;
        
        for (int i = 0; i < states.size(); i++) {
            for (int X : allSymbols) {
                LR0State J = goTo(states[i], X);
                
                if (!J.items.empty()) {
                    // 检查 J 是否已经存在
                    int idx = findState(J);
                    if (idx == -1) {
                        idx = states.size();
                        states.push_back(J);
                        changed = true;
                    }
                    dfaGoto[i][X] = idx;
                }
            }
        }
    }
}

int findState(LR0State& J) {
    for (int i = 0; i < states.size(); i++)
        if (states[i].items == J.items)
            return i;
    return -1;
}
```

---

## 四、LR(1) DFA 构建

### 4.1 与 LR(0) 的核心区别

|         | LR(0)        | LR(1)                         |
| ------- | ------------ | ----------------------------- |
| 项目      | `A → α·β`    | `[A → α·β, a]`                |
| Closure | 直接加 `B → ·γ` | 加 `[B → ·γ, b]`，b = FIRST(βa) |
| Goto    | 点跨过 X        | 点跨过 X，前瞻符**不变**               |

### 5.2 伪代码（考试版）

```
LR(1) Closure(I)：
    J = I
    while (J 有变化)
        for (J 中每个项目 [A → α·Bβ, a])
            for (B 的每个产生式 B → γ)
                for (每个 b ∈ FIRST(βa))        ← 关键！
                    if ([B → ·γ, b] 不在 J 中)
                        将 [B → ·γ, b] 加入 J
    return J

──────────────────────────────────

LR(1) Goto(I, X)：
    J = ∅
    for (I 中每个项目 [A → α·Xβ, a])
        将 [A → αX·β, a] 加入 J     // 前瞻符 a 不变
    return Closure(J)
```

### 5.3 手工演算示例

文法：`A' → A,  A → (A) | a`

**I₀ = Closure({ [A' → ·A, $] })**

```
种子: [A' → ·A, $]
  点后 A，β=ε，a=$ → FIRST(ε$) = {$}
  加入 [A → ·(A), $]
  加入 [A → ·a, $]

I₀ = { [A' → ·A, $],
       [A → ·(A), $],
       [A → ·a, $] }
```

**Goto(I₀, "(") = I₂**

```
跨过 (：来自 [A → ·(A), $] → [A → (·A), $]

Closure([A → (·A), $]):
  点后 A，β=)，a=$ → FIRST()$) = {)}
  加入 [A → ·(A), )]
  加入 [A → ·a, )]

I₂ = { [A → (·A), $],
       [A → ·(A), )],    ← 前瞻符是 ) 不是 $
       [A → ·a, )] }
```

**注意**：`[A → ·(A), )]` 和 I₀ 中 `[A → ·(A), $]` 核心相同但前瞻符不同，是**不同的 LR(1) 项目**。这直接导致 LR(1) DFA 状态更多。

### 5.4 C++ 实现

```cpp
struct LR1Item {
    int ruleNo;
    int dotPos;
    set<int> lookaheads;        // ← 相比 LR0Item 的唯一区别
};

struct LR1State {
    // 用 map<核心, 前瞻符集> 存储，方便合并同核心不同前瞻符的项目
    map<pair<int,int>, set<int>> items;
    
    // 遍历所有项目
    void forEachItem(function<void(int, int, int)> fn) {
        for (auto& [key, las] : items) {
            int ruleNo = key.first;
            int dotPos = key.second;
            for (int la : las) {
                fn(ruleNo, dotPos, la);
            }
        }
    }
};

// ==================== LR(1) Closure ====================
LR1State closureLR1(LR1State I) {
    LR1State J = I;
    bool changed = true;
    
    while (changed) {
        changed = false;
        LR1State snapshot = J;
        
        snapshot.forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];
            
            if (dotPos < rule.right.size()) {
                int B = rule.right[dotPos];     // 点后非终结符
                
                if (isNonTerminal(B)) {
                    // 计算 FIRST(βa)，其中 β = 点后符号的右边部分
                    set<int> firstBetaA;
                    computeFirst(rule.right, dotPos + 1, la, firstBetaA);
                    
                    for (int b : firstBetaA) {
                        // 对 B 的每个产生式
                        for (int r = 0; r < Grammar.size(); r++) {
                            if (Grammar[r].left == B) {
                                pair<int,int> core = {r, 0};  // B → ·γ
                                if (J.items[core].count(b) == 0) {
                                    J.items[core].insert(b);
                                    changed = true;
                                }
                            }
                        }
                    }
                }
            }
        });
    }
    return J;
jj}

// ==================== 计算 FIRST(βa) ====================
void computeFirst(vector<int>& right, int start, int a, set<int>& result) {
    bool allHaveEpsilon = true;
    
    for (int i = start; i < right.size(); i++) {
        set<int> fi = FIRST[right[i]];
        result.insert(fi.begin(), fi.end());
        result.erase(0);   // 去掉 ε（假设 ε 编码为 0）
        
        if (fi.count(0) == 0) {   // 不能推出 ε
            allHaveEpsilon = false;
            break;
        }
    }
    
    if (allHaveEpsilon)
        result.insert(a);   // a 继承进来
}

// ==================== LR(1) Goto ====================
LR1State gotoLR1(LR1State I, int X) {
    LR1State J;
    
    I.forEachItem([&](int ruleNo, int dotPos, int la) {
        Rule& rule = Grammar[ruleNo];
        
        if (dotPos < rule.right.size() &&
            rule.right[dotPos] == X) {
            pair<int,int> core = {ruleNo, dotPos + 1};  // 点跨过 X
            J.items[core].insert(la);  // 前瞻符不变！
        }
    });
    
    return closureLR1(J);
}
```

---

## 五、LALR(1) DFA 构建

### 5.1 核心思想

LR(1) DFA 状态太多 → 把"核心相同"的状态合并 → 状态数 = LR(0) 级别。

### 5.2 伪代码

```
算法：LALR(1) DFA = 合并 LR(1) 的同心集

输入：LR(1) DFA（状态集合 States，转移 Goto）
输出：LALR(1) DFA

1. 对每个 LR(1) 状态，提取核心（去掉前瞻符）
2. 找出核心相同的状态 → 这些状态是同心集
3. 合并同心集：
     新状态 items = 各同心集的 items 的并集
     每个项目的前瞻符 = 原来各状态该核心项目前瞻符的并集
4. 更新转移：合并状态之间的边
```

### 5.3 手工演算

前面 LR(1) DFA 的例子中：

```
LR(1) 状态：
  I₃: { [A → a·, $] }
  I₅: { [A → a·, )] }

核心相同（都是 {A → a·}）→ 同心集 → 合并！

合并后 I₃₅: { [A → a·, {$/)}] }    ← 前瞻符取并集
```

### 5.4 C++ 实现

```cpp
vector<LR1State> lalrStates;
map<int, map<int, int>> lalrGoto;

void buildLALR1DFA(vector<LR1State>& lr1States,
                   map<int, map<int, int>>& lr1Goto) {
    
    // 第1步：提取每个状态的核心
    // 核心 = 去掉前瞻符后的项目集
    vector<set<pair<int,int>>> cores;
    for (auto& state : lr1States) {
        set<pair<int,int>> core;
        for (auto& [key, _] : state.items)
            core.insert(key);
        cores.push_back(core);
    }
    
    // 第2步：找出同心集 → 分组
    map<set<pair<int,int>>, vector<int>> groups;
    for (int i = 0; i < cores.size(); i++)
        groups[cores[i]].push_back(i);
    
    // 第3步：合并每组同心集
    vector<int> oldToNew(lr1States.size(), -1);  // LR(1)状态 → LALR(1)状态
    
    for (auto& [core, stateList] : groups) {
        LR1State merged;
        
        // 合并：遍历该组所有状态，前瞻符取并集
        for (int idx : stateList) {
            for (auto& [key, las] : lr1States[idx].items)
                merged.items[key].insert(las.begin(), las.end());
        }
        
        int newIdx = lalrStates.size();
        lalrStates.push_back(merged);
        
        for (int idx : stateList)
            oldToNew[idx] = newIdx;
    }
    
    // 第4步：更新转移边
    for (int i = 0; i < lr1States.size(); i++) {
        if (lr1Goto.count(i)) {
            for (auto& [X, j] : lr1Goto[i]) {
                lalrGoto[oldToNew[i]][X] = oldToNew[j];
            }
        }
    }
    
    // 第5步：检查是否引入新冲突
    checkConflicts(lalrStates);
}
```

---

## 六、三种 DFA 对比

以 `A → (A) | a` 为例：

|          | LR(0)  | LR(1) | LALR(1)   |
| -------- | ------ | ----- | --------- |
| 状态数      | 7      | 10+   | **7**     |
| I₃: A→a· | 无前瞻符   | `[$]` | `[$]`     |
| I₅: A→a· | —（不存在） | `[)]` | —（合并入 I₃） |
| 合并后      | —      | —     | `[$ / )]` |

### DFA 图对比

```
LR(0):     (I₀)─(─→(I₂)─A─→(I₄)─)─→(I₆)
               a→(I₃)

LR(1):     (I₀)─(─→(I₂²)─A─→(I₄²)─)─→(I₆²)
               a→(I₃²)   (I₂)又有自己……
           （多个同核心不同前瞻符状态 → 状态爆炸）

LALR(1):  (I₀)─(─→(I₂)─A─→(I₄)─)─→(I₆)
               a→(I₃₅)
          （合并后状态数和 LR(0) 一样）
```


---

## 附：简洁版数据结构与实现（实验代码风格）

> 上面的实现用了 `int` 编码符号（课程数值化风格）。下面是实验四 `parser_core.cpp` 的写法，直接用 `string` 做符号，代码量减半。

### 数据结构

```cpp
// ═══════ 符号直接用 string，不需要编码层 ═══════

using SymSet = std::set<std::string>;
using SetMap = std::map<std::string, SymSet>;

// 产生式
struct Production {
    std::string lhs;                    // 左部："E", "S", "T"...
    std::vector<std::string> rhs;       // 右部：{"E", "+", "n"} 或 {"#"} 表示 ε
};

// 文法
struct Grammar {
    std::vector<Production> productions;
    std::vector<std::string> nonTerminals;   // 第一个就是开始符号
    std::vector<std::string> terminals;
    bool isNT(const std::string& s) const { /* 查 nonTerminals */ }
};

//所有文法符号的集合allSyms
  std::set<std::string> allSyms;
  for (auto& p : dfa.augProds)
      for (auto& s : p.rhs)
          if (s != "#") allSyms.insert(s);

// ═══════ LR(0)：项目 = {产生式编号, 点位置} ═══════

struct LR0Item {
    int prod;    // 产生式编号（Grammar 数组中第几条产生式）
    int dot;     // 点的位置（0=最左边，length=最右边）
	
	//数据结构set需要升序排列，所以需要下列函数来确定次序
	
	 // operator< ：先比产生式编号，再比点位置
    bool operator<(const LR0Item& o) const {
        return prod < o.prod || (prod == o.prod && dot < o.dot);
    }
    
    // operator== ：两个项目相同 ⇔ 产生式相同 且 点位置相同
    bool operator==(const LR0Item& o) const {
        return prod == o.prod && dot == o.dot;
    }
};
using S0 = std::set<LR0Item>;           // 状态 = 项目集合

// DFA = 增广产生式 + 状态列表 + 转移表
struct DFA0 {
    std::vector<Production> augProds;               // 第0条是 S' -> S
    std::vector<S0> states;                         // 每个状态是一个 S0,就是一个项集
    std::vector<std::map<std::string, int>> trans;  // trans[i][符号] = 目标状态
};

// ═══════ LR(1)：只比 LR(0) 多一个 la 字段 ═══════

struct LR1Item {
    int prod, dot;
    std::string la;                     // 向前看符号，例如 "$" 或 ")"
    bool operator<(const LR1Item& o) const {
        if (prod != o.prod) return prod < o.prod;
        if (dot != o.dot) return dot < o.dot;
        return la < o.la;
    }
    bool operator==(const LR1Item& o) const {
        return prod == o.prod && dot == o.dot && la == o.la;
    }
};
using S1 = std::set<LR1Item>;

struct DFA1 {
    std::vector<Production> augProds;
    std::vector<S1> states;
    std::vector<std::map<std::string, int>> trans;
};

// ═══════ LALR(1)：复用 S1，多加一个映射表 ═══════

struct DFAl {
    std::vector<Production> augProds;
    std::vector<S1> states;                         // 合并后的状态
    std::vector<std::map<std::string, int>> trans;
    std::vector<int> lr1ToLALR;                     // LR(1)状态 → LALR(1)状态
};

```

### FIRST(βa) — 一行搞定

```cpp
// 计算符号串 seq[from..] 连接 la 的 FIRST 集
// 这个函数同时服务于：FIRST 集计算、FOLLOW 计算、LR(1) 闭包
SymSet seqFirst(const std::vector<std::string>& seq, int from,
                const SetMap& first) {
    SymSet result;
    for (int i = from; i < (int)seq.size(); i++) {
        SymSet f = first.at(seq[i]);            //map.at(n)，返回键为n的值
        for (auto& s : f) if (s != "#") result.insert(s);
        if (!f.count("#")) return result;       // 不能推出 ε → 停止
    }
    result.insert("#");                         // 全都推 ε
    return result;
}

// 在 LR(1) Closure 中调用：
// betaA = dot 右边部分 + 父项前瞻符
vector<string> betaA(rhs.begin() + item.dot + 1, rhs.end());
betaA.push_back(item.la);
SymSet la_set = seqFirst(betaA, 0, first);
```

这个函数同时服务于：FIRST 集计算、FOLLOW 计算、LR(1) 闭包，值得说一下

  具体说明

  seq — 一个字符串数组，就是"谁跟谁拼起来"的那个串。

  from — 从 seq 的第几个位置开始看。通常传 0（从头开始），但也可以传非零（跳过前面）。

  first — 一张查找表，first["E"] 就能查到 E 的 FIRST 集。

1. FIRST 集计算
	产生式 E → T X，想求 FIRST(TX)
	seq = ["T", "X"], from = 0
	seqFirst(prod.rhs, 0, first);      //prod.rhs产生式右侧的意思
2. FOLLOW 集计算
	产生式 E → T X，求跟在 T 后面的 FIRST，即 FIRST(X)
	seq = ["T", "X"], from = 1 (从 X 开始看)
	seqFirst(prod.rhs, i + 1, first);
3. LR(1)闭包
	项目 [E → T·X, $]，dot=1，β=X，a=$
	seq = ["X", "$"]  （β + a 拼起来）
	from = 0


### LR(0) DFA — BFS 构建

```cpp
DFA0 buildDFA0(const Grammar& g) {
    DFA0 dfa;

    // 拓广：S' → S
    Production aug{g.nonTerminals[0] + "'", {g.nonTerminals[0]}};
    dfa.augProds.push_back(aug);
    for (auto& p : g.productions) dfa.augProds.push_back(p);

    // 初始状态
    // { [S'→·S] }，{0，0}表示产生式编号和点的位置
    //closure0 看到点后是 E（非终结符），把 E 的所有产生式加进去 → 变成：
  I₀ = { [E' → ·E],  [E → ·E + n],  [E → ·n] }
    S0 init = closure0({{0, 0}}, dfa.augProds);   
    //dfa状态写入，states[0] = I₀
    dfa.states.push_back(init);
    //trans[0] = {}  ← 状态0的转移表，先空着
    dfa.trans.push_back({});

    // BFS扩展
    std::queue<int> wl; wl.push(0);
	//队列非空则循环
    while (!wl.empty()) {
    //取出队首元素记录为si
        int si = wl.front(); wl.pop();
		//遍历所有文法符号
        for (auto& sym : allSyms) {
	        //求 Goto(si, X)
            S0 next = goto0(dfa.states[si], sym, dfa.augProds);
            //没找到就跳过
            if (next.empty()) continue;
            // 找已有状态（状态用 set<Item> 直接 == 比较）
            int found = -1;
            
            //遍历dfa的状态，判断是否是老状态，如果是，让found=老状态
            for (int j = 0; j < (int)dfa.states.size(); j++)
                if (dfa.states[j] == next) { found = j; break; }
			//是新状态 → 加入 states，加入队列
            if (found == -1) {
                found = (int)dfa.states.size();
                dfa.states.push_back(next);
                dfa.trans.push_back({});
                wl.push(found);
            }
            //记录转移 trans[si][X] = 目标状态
            dfa.trans[si][sym] = found;
        }
    }
    return dfa;
}
```

### LR(1) DFA — 和 LR(0) 骨架完全一样

```cpp
// 唯二差异：
// 1. 初始项目带前瞻符：{{0, 0, "$"}} 而不是 {{0, 0}}
// 2. closure1 内部调用 seqFirst 计算新项目的前瞻符
// 其余 BFS 逻辑和 buildDFA0 完全相同
DFA1 buildDFA1(const Grammar& g, const SetMap& first) {
    // ... 和 buildDFA0 结构一样 ...
    S1 init = closure1({{0, 0, "$"}}, dfa.augProds, first);
    // ... 其余相同 ...
}
```

### LALR(1) DFA — 合并同心集

```cpp
// 提取核心：去掉前瞻符，只留 (prod, dot)
set<pair<int,int>> stateCore(const S1& state) {
	//核心，prod和dot的存储结构
    set<pair<int,int>> core;
    //遍历状态里的所有项，将每个项的核心加入到状态核心
    for (auto& item : state) core.insert({item.prod, item.dot});
	//返回状态核心
    return core;
}

DFAl buildLALR1(const Grammar& g, const DFA1& dfa1) {
    DFAl lalr;
    lalr.augProds = dfa1.augProds;

    // 按核心分组
    map<set<pair<int,int>>, int> coreToIdx;
	// lr1和lalr1的状态映射表，用于寻找lr1合并后的状态，初始全为-1
    lalr.lr1ToLALR.resize(dfa1.states.size(), -1);

    for (int i = 0; i < (int)dfa1.states.size(); i++) {
	    //状态核心
        auto core = stateCore(dfa1.states[i]);
        //寻找核心
        auto it = coreToIdx.find(core);
        //没找到核心，那就是第一次见，则创建新的lalr状态
        if (it == coreToIdx.end()) {
	        //新创建lalr1状态 
		    int idx = (int)lalr.states.size();
            coreToIdx[core] = idx;
            lalr.states.push_back(dfa1.states[i]);    // 复制
            lalr.trans.push_back({});
            lalr.lr1ToLALR[i] = idx;
	        
        }
        //找到了，那就把这个lr1状态映射到之前的lalr状态
		 else {
            int idx = it->second;
            // 同核心：前瞻符"并"进去
            for (auto& item : dfa1.states[i])
                lalr.states[idx].insert(item);
            lalr.lr1ToLALR[i] = idx;
        }
    }

    // 重建转移表
    //遍历 LR(1) 的每条转移边，把起点和终点都换成 LALR(1) 的状态编号。
    for (int i = 0; i < (int)dfa1.states.size(); i++) {
        int li = lalr.lr1ToLALR[i];
        for (auto& [sym, j] : dfa1.trans[i]) {
            int lj = lalr.lr1ToLALR[j];
            lalr.trans[li][sym] = lj;
        }
    }
    return lalr;
}
```

### 两种风格对比

|     | 笔记原版（数值编码风格）                                 | 简洁版（实验代码风格）                              |
| --- | -------------------------------------------- | ---------------------------------------- |
| 符号  | `int`，终结符<100，非终结符≥100                       | `string`，直接用                             |
| 项目  | `struct LR0Item { int ruleNo, dotPos; }`     | `struct LR0Item { int prod, dot; }`      |
| 状态  | `struct LR0State { set<LR0Item> items; }`    | `using S0 = set<LR0Item>;`               |
| DFA | `vector<LR0State>` + `map<int,map<int,int>>` | `vector<S0>` + `vector<map<string,int>>` |
| 找状态 | 单独函数 `findState()`                           | 内联 for 循环 + `==`                         |
| 构造  | `while(States变化)` 全局扫描                       | `queue<int>` 标准 BFS                      |
| 优点  | 访问快，适合大规模                                    | 代码少，可读性好，考试手算思想映射直接                      |


## 七、一句话总结

| DFA 类型  | 本质                                 |
| ------- | ---------------------------------- |
| LR(0)   | 无前瞻符，只靠点时位置判断                      |
| LR(1)   | 每个项目带上精确的前瞻符，状态最多                  |
| LALR(1) | LR(1) 去重——把长得像的状态合并，状态数回到 LR(0) 级别 |

