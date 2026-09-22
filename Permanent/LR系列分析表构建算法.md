# LR 系列分析表构建算法：从伪代码到完整实现

---

## 一、大白话理解

分析表 = 一张**查什么就做什么**的指令表。

```
Action[s][a] = "s5"   → 状态s，看到输入a → 移进，去状态5
Action[s][a] = "r3"   → 状态s，看到输入a → 归约，用第3条产生式
Action[s][a] = "acc"  → 状态s，看到输入a → 接受
Action[s][a] =  空    → 语法错误
```

四种 LR 方法的分析表结构完全一样（都是 Action + Goto），**唯一区别是归约填表的范围**。

---

## 二、数据结构定义

```cpp
// ═══════════════════════════════════════════════
// 符号编码约定
// ═══════════════════════════════════════════════

const int TERM_EOF   = 0;    // $
const int TERM_PLUS  = 1;    // +
const int TERM_N     = 2;    // n
const int TERM_LP    = 3;    // (
const int TERM_RP    = 4;    // )
const int TERM_A     = 5;    // a
// ... 其他终结符，编码 < 100

const int NONTERM_OFFSET = 100;
const int NONTERM_E  = 101;
const int NONTERM_T  = 102;
const int NONTERM_S  = 103;
const int NONTERM_A  = 104;
// ... 其他非终结符，编码 ≥ 100

bool isTerminal(int sym)     { return sym < 100; }
bool isNonTerminal(int sym)  { return sym >= 100; }


// ═══════════════════════════════════════════════
// 产生式
// ═══════════════════════════════════════════════

struct Rule {
    int left;                  // 左部非终结符编号
    vector<int> right;         // 右部符号序列
    int length() const { return right.size(); }
};

vector<Rule> Grammar;          // 全局产生式库
int startRule = 0;             // 拓广产生式 S' → S 的编号


// ═══════════════════════════════════════════════
// 分析表结构（核心！）
// ═══════════════════════════════════════════════

// Action 表:     Action[状态][终结符] = 动作串
// Goto 表:       Goto[状态][非终结符] = 目标状态
//
// 动作串的格式约定：
//   "s3"   → 移进，进入状态 3
//   "r2"   → 归约，用第 2 条产生式
//   "acc"  → 接受
//   空     → 错误（表中该格子无条目）

map<int, map<int, string>> Action;   // 状态 → 符号 → 动作
map<int, map<int, int>>    Goto;     // 状态 → 非终结符 → 目标状态

// 二维数组直观理解：
//           n       +        $       E
//   状态0   "s2"     —        —     Goto=1
//   状态1    —      "s3"    "acc"    —
//   状态2    —      "r2"    "r2"     —
//   状态3   "s4"     —        —      —
//   状态4    —      "r1"    "r1"     —


// ═══════════════════════════════════════════════
// DFA 状态（构建分析表的输入）
// ═══════════════════════════════════════════════

// LR(0) DFA
struct LR0Item {
    int ruleNo;
    int dotPos;
    bool operator==(const LR0Item& o) const {
        return ruleNo == o.ruleNo && dotPos == o.dotPos;
    }
    bool operator<(const LR0Item& o) const {
        if (ruleNo != o.ruleNo) return ruleNo < o.ruleNo;
        return dotPos < o.dotPos;
    }
};
struct LR0State { set<LR0Item> items; };

// LR(1) DFA
struct LR1State {
    map<pair<int,int>, set<int>> items;   // (ruleNo,dotPos) → 前瞻符集
    void forEachItem(function<void(int,int,int)> fn) const {
        for (auto& [key, las] : items)
            for (int la : las) fn(key.first, key.second, la);
    }
};

// 全局 DFA 数据（由 DFA 构建算法产生，作为建表算法的输入）
extern vector<LR0State> lr0States;
extern map<int, map<int, int>> lr0Goto;
extern vector<LR1State> lr1States;
extern map<int, map<int, int>> lr1Goto;
extern vector<LR1State> lalrStates;
extern map<int, map<int, int>> lalrGoto;


// ═══════════════════════════════════════════════
// FOLLOW 集（SLR(1) 建表需要）
// ═══════════════════════════════════════════════

extern map<int, set<int>> FOLLOW;  // FOLLOW[A] = {终结符集合}

// 收集所有终结符（用于 LR(0) "对所有符号归约"）
set<int> allTerminals = {TERM_EOF, TERM_PLUS, TERM_N, TERM_LP, TERM_RP, TERM_A};
```

---

## 三、LR(0) 分析表

### 3.1 填表规则

```
输入：LR(0) DFA + 文法（含产生式编号）
输出：Action 表 + Goto 表

对于 DFA 中每个状态 Iᵢ：

━━━ 规则1：移进 ━━━
若 A → α·aβ ∈ Iᵢ（点后是终结符 a），且 Goto(Iᵢ, a) = Iⱼ
  → Action[i][a] = "sⱼ"

━━━ 规则2：归约 ━━━
若 A → α· ∈ Iᵢ（点在末尾，A ≠ S'），j = 该产生式编号
  → 对所有 a ∈ V_T ∪ {$}
  → Action[i][a] = "rⱼ"

━━━ 规则3：接受 ━━━
若 S' → S· ∈ Iᵢ
  → Action[i][$] = "acc"

━━━ 规则4：Goto ━━━
若 Goto(Iᵢ, A) = Iⱼ（A ∈ V_N）
  → Goto[i][A] = j
```

### 3.2 手工建表演练

文法：`(0) E' → E,  (1) E → E + n,  (2) E → n`

LR(0) DFA：
```
I₀ = { E' → ·E,   E → ·E + n,   E → ·n }
I₁ = { E' → E·,   E → E· + n }
I₂ = { E → n· }
I₃ = { E → E +· n }
I₄ = { E → E + n· }
```

**逐状态填写**：

```
状态0:
  E → ·E + n 点后E → E是非终结符，不填Action
  E → ·n 点后n → Goto(0,n)=2 → Action[0][n] = s2
  E' → ·E 点后E → Goto(0,E)=1 → Goto[0][E] = 1

状态1:
  E' → E·  归约项目！S'→S· → Action[1][$] = acc
  E → E·+n 点后+ → Goto(1,+)=3 → Action[1][+] = s3
  注意：E'→E· 也是归约项目，LR(0)对n列也填acc?不，
  S'→S· 特殊处理为acc。实际 LR(0)填法：
  归约项目 E'→E· → 对所有a包括+都要填r0
  但同时 E→E·+n 要求移进 +
  → + 列有 s3 又有 r0 → 冲突！

状态2:
  E → n· 归约项目(产生式2)
  LR(0): 对所有 a 填 r2
  → Action[2][n]=r2, Action[2][+]=r2, Action[2][$]=r2

状态3:
  E → E+·n 点后n → Goto(3,n)=4 → Action[3][n] = s4

状态4:
  E → E+n· 归约项目(产生式1)
  LR(0): 对所有 a 填 r1
  → Action[4][n]=r1, Action[4][+]=r1, Action[4][$]=r1
```

**最终 LR(0) 表**：

```
     n    +    $    E
0    s2            1
1    ?    s3   acc      ← 状态1有冲突（+列同时有移进和归约）
2    r2   r2   r2
3    s4
4    r1   r1   r1
```

### 3.3 C++ 代码

```cpp
void buildLR0Table() {
    // Action 表: map<状态, map<终结符, string>>
    // Goto 表:  map<状态, map<非终结符, int>>

    for (int i = 0; i < states.size(); i++) {
        for (auto& item : states[i].items) {
            Rule& rule = Grammar[item.ruleNo];

            if (item.dotPos < rule.right.size()) {
                // ━━━ 移进 ━━━
                int next = rule.right[item.dotPos];
                if (isTerminal(next)) {
                    int j = dfaGoto[i][next];
                    Action[i][next] = "s" + to_string(j);
                }
            } else {
                // ━━━ 归约 ━━━
                if (item.ruleNo == startRule) {
                    // S' → S· → 接受
                    Action[i][TERM_EOF] = "acc";
                } else {
                    // A → α· → 对所有终结符归约
                    for (int a : allTerminals) {
                        Action[i][a] = "r" + to_string(item.ruleNo);
                    }
                }
            }
        }

        // ━━━ Goto ━━━
        for (auto& [X, j] : dfaGoto[i]) {
            if (isNonTerminal(X)) {
                Goto[i][X] = j;
            }
        }
    }
}
```

---

## 四、SLR(1) 分析表

### 4.1 与 LR(0) 的唯一区别

```
LR(0) 归约填表:  对所有 a ∈ V_T ∪ {$} 填 rⱼ
SLR(1) 归约填表: 仅对 a ∈ FOLLOW(A)    填 rⱼ
                        ↑
                  唯一不同之处！
```

### 4.2 填表规则

```
输入：LR(0) DFA + FOLLOW 集 + 文法
输出：Action 表 + Goto 表

对于 DFA 中每个状态 Iᵢ：

━━━ 规则1：移进（同 LR(0)）━━━
若 A → α·aβ ∈ Iᵢ，且 Goto(Iᵢ, a) = Iⱼ
  → Action[i][a] = "sⱼ"

━━━ 规则2：归约（唯一不同！）━━━
若 A → α· ∈ Iᵢ（A ≠ S'），j = 产生式编号
  → 仅对 a ∈ FOLLOW(A)              ← 不是所有符号
  → Action[i][a] = "rⱼ"

━━━ 规则3：接受（同 LR(0)）━━━
若 S' → S· ∈ Iᵢ
  → Action[i][$] = "acc"

━━━ 规则4：Goto（同 LR(0)）━━━
若 Goto(Iᵢ, A) = Iⱼ
  → Goto[i][A] = j
```

### 4.3 手工建表演练

同上的文法，FOLLOW(E) = {$, +}。

**状态0**：同 LR(0) → `Action[0][n]=s2, Goto[0][E]=1`

**状态1**：
- E' → E· → 接受 → `Action[1][$]=acc`
- E → E·+n → 移进 → `Action[1][+]=s3`
- 没有冲突！（$ 和 + 是不同的列）

**状态2**：
- E → n· 归约，FOLLOW(E)={$,+}
- 仅 `Action[2][+]=r2, Action[2][$]=r2`
- n 列不再填 r2（n ∉ FOLLOW(E)）

**状态3**：同 LR(0) → `Action[3][n]=s4`

**状态4**：
- E → E+n· 归约，FOLLOW(E)={$,+}
- 仅 `Action[4][+]=r1, Action[4][$]=r1`

**最终 SLR(1) 表**：

```
     n    +    $    E
0    s2            1
1         s3   acc
2         r2   r2        ← n列空白！(对比LR(0): n列有r2)
3    s4
4         r1   r1        ← n列空白！
```

**对比 LR(0)**：状态2的 n 列和状态4的 n 列不再有归约，冲突消除。

### 4.4 C++ 代码

```cpp
// 先计算 FOLLOW 集
map<int, set<int>> FOLLOW;

// ... (FOLLOW 计算代码见 chap03 笔记)

void buildSLR1Table() {
    for (int i = 0; i < states.size(); i++) {
        for (auto& item : states[i].items) {
            Rule& rule = Grammar[item.ruleNo];

            if (item.dotPos < rule.right.size()) {
                // ━━━ 移进（同 LR(0)）━━━
                int next = rule.right[item.dotPos];
                if (isTerminal(next)) {
                    int j = dfaGoto[i][next];
                    Action[i][next] = "s" + to_string(j);
                }
            } else {
                if (item.ruleNo == startRule) {
                    // ━━━ 接受 ━━━
                    Action[i][TERM_EOF] = "acc";
                } else {
                    // ━━━ 归约（仅 FOLLOW！）━━━
                    int A = rule.left;
                    for (int a : FOLLOW[A]) {       // ← 不是 allTerminals
                        Action[i][a] = "r" + to_string(item.ruleNo);
                    }
                }
            }
        }

        for (auto& [X, j] : dfaGoto[i]) {
            if (isNonTerminal(X))
                Goto[i][X] = j;
        }
    }
}
```

---

## 五、LR(1) 分析表

### 6.1 填表规则

```
输入：LR(1) DFA + 文法
输出：Action 表 + Goto 表

对于 DFA 中每个状态 Iᵢ：

━━━ 规则1：移进 ━━━
若 [A → α·aβ, b] ∈ Iᵢ，且 Goto(Iᵢ, a) = Iⱼ
  → Action[i][a] = "sⱼ"

━━━ 规则2：归约（关键差异！）━━━
若 [A → α·, a] ∈ Iᵢ（A ≠ S'），j = 产生式编号
  → Action[i][a] = "rⱼ"           ← 仅前瞻符 a 这一列！

━━━ 规则3：接受 ━━━
若 [S' → S·, $] ∈ Iᵢ
  → Action[i][$] = "acc"

━━━ 规则4：Goto ━━━
若 Goto(Iᵢ, A) = Iⱼ
  → Goto[i][A] = j
```

### 6.2 手工建表演练

文法：`A' → A,  A → (A) | a`

LR(1) DFA（回顾）：

```
I₀: [A'→·A, $], [A→·(A), $], [A→·a, $]
I₁: [A'→A·, $]
I₂: [A→(·A), $], [A→·(A), )], [A→·a, )]
I₃: [A→a·, $]                                   ← 归约，前瞻符 $
I₄: [A→(A·), $]
I₅: [A→a·, )]                                   ← 归约，前瞻符 )
I₆: [A→(A)·, $]
```

**逐状态填写**：

```
状态0:
  [A→·(A),$] 点后( → Goto(0,()=2 → s2
  [A→·a,$]   点后a → Goto(0,a)=3 → s3
  [A'→·A,$]  点后A → Goto(0,A)=1 → Goto

状态1:
  [A'→A·,$] → acc

状态2:
  [A→(·A),$]  点后A → Goto(2,A)=4 → Goto
  [A→·(A),)]  点后( → Goto(2,()=2 → s2
  [A→·a,)]    点后a → Goto(2,a)=5 → s5

状态3:
  [A→a·, $] 归约项目(产生式2)，前瞻符 $ → Action[3][$] = r2

状态4:
  [A→(A·),$] 点后) → Goto(4,))=6 → s6

状态5:
  [A→a·, )] 归约项目(产生式2)，前瞻符 ) → Action[5][)] = r2

状态6:
  [A→(A)·,$] 归约项目(产生式1)，前瞻符 $ → Action[6][$] = r1
```

**最终 LR(1) 表**：

```
     (     )     a     $     A
0    s2         s3          1
1                       acc
2    s2         s5          4               ← (列自循环
3                       r2                  ← 仅在$归约
4          s6
5          r2                              ← 仅在)归约
6                       r1
```

**对比 SLR(1)**：SLR(1) 表状态3会对 FOLLOW(A)={$,)} 都填 r2，而 LR(1) 只在 $ 填 r2（状态5 处理了 `)` 的情况）。

### 6.3 C++ 代码

```cpp
void buildLR1Table(vector<LR1State>& lr1States,
                   map<int, map<int, int>>& lr1Goto) {
    
    for (int i = 0; i < lr1States.size(); i++) {
        
        lr1States[i].forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];

            if (dotPos < rule.right.size()) {
                // ━━━ 移进 ━━━
                int next = rule.right[dotPos];
                if (isTerminal(next)) {
                    int j = lr1Goto[i][next];
                    Action[i][next] = "s" + to_string(j);
                }
            } else {
                if (ruleNo == startRule) {
                    // ━━━ 接受 ━━━
                    Action[i][TERM_EOF] = "acc";
                } else {
                    // ━━━ 归约（仅前瞻符列！）━━━
                    Action[i][la] = "r" + to_string(ruleNo);
                }
            }
        });

        // ━━━ Goto ━━━
        for (auto& [X, j] : lr1Goto[i]) {
            if (isNonTerminal(X))
                Goto[i][X] = j;
        }
    }
}
```

---

## 六、LALR(1) 分析表

### 6.1 填表规则

**与 LR(1) 完全相同。** 唯一区别是输入：LALR(1) 分析表的 DFA 来自合并同心集后的状态，不是原始的 LR(1) DFA。

```
规则 = LR(1) 的规则
输入 = 合并同心集后的 LALR(1) DFA

由于合并后，一个项目可能有多个前瞻符：
  [A → a·, {$)}]

→ 在 $ 列和 ) 列分别填 r2
```

### 6.2 手工建表演练

接上面 LR(1) DFA，I₃ 和 I₅ 是同心集（核心都是 {A → a·}）：

```
合并前:
  I₃: [A → a·, $]       → Action[3][$] = r2
  I₅: [A → a·, )]       → Action[5][)] = r2

合并后 I₃₅: [A → a·, {$/)}]
  → Action[3₅][$]  = r2
  → Action[3₅][)]  = r2
```

### 6.3 C++ 代码

```cpp
void buildLALR1Table(vector<LR1State>& lalrStates,
                     map<int, map<int, int>>& lalrGoto) {
    
    // 与 buildLR1Table 代码完全相同！
    // 因为填表规则一样，只是输入 DFA 不同
    
    for (int i = 0; i < lalrStates.size(); i++) {
        
        lalrStates[i].forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];

            if (dotPos < rule.right.size()) {
                int next = rule.right[dotPos];
                if (isTerminal(next)) {
                    int j = lalrGoto[i][next];
                    Action[i][next] = "s" + to_string(j);
                }
            } else {
                if (ruleNo == startRule)
                    Action[i][TERM_EOF] = "acc";
                else
                    Action[i][la] = "r" + to_string(ruleNo);
            }
        });

        for (auto& [X, j] : lalrGoto[i])
            if (isNonTerminal(X))
                Goto[i][X] = j;
    }
}
```

---

## 七、四种分析表差异速查

| | LR(0) | SLR(1) | LR(1) | LALR(1) |
|---|-------|--------|-------|---------|
| 基于的 DFA | LR(0) | LR(0) | LR(1) | LALR(1) |
| 移进规则 | 点后终结符 | 同左 | 同左 | 同左 |
| 归约范围 | 所有终结符 | **FOLLOW(A)** | **精确前瞻符** | **合并后前瞻符** |
| 接受规则 | S'→S· at $ | 同左 | 同左 | 同左 |
| Goto 规则 | 非终结符转移 | 同左 | 同左 | 同左 |

**一句话版本**：

```
LR(0): 归约 = 对所有符号
SLR(1): 归约 = 对 FOLLOW(A)
LR(1): 归约 = 对前瞻符（一个项目一个列）
LALR(1): 归约 = 对前瞻符（合并后，一个项目可能多个列）
```


## 附：简洁版数据结构与实现（实验代码风格）

### 分析表存储

```cpp
// Action 表: Action[i][终结符] = 动作
// Goto 表:   Goto[i][非终结符] = 目标状态
//
// 用 map<string, string> 而不是 map<int, string>
// 列标签直接是 "$", "+", "n" 等，不需要查编码表

vector<map<string, string>> Action;   // Action[状态][符号] = "s2" / "r3" / "acc"
vector<map<string, int>> Goto;        // Goto[状态][非终结符] = 目标状态
```

### LR(0) 分析表构建

```cpp
void buildLR0Table(const DFA0& dfa) {
    const auto& prods = dfa.augProds;
    int n = (int)dfa.states.size();
    Action.resize(n);
    Goto.resize(n);

    for (int i = 0; i < n; i++) {
        for (auto& item : dfa.states[i]) {
            const auto& rhs = prods[item.prod].rhs;
			//是否为ε表达式
            bool isEps = (rhs.size() == 1 && rhs[0] == "#");
			//如果 · 不在产生式的最后且不为ε产生你式，则可以移进
            if (item.dot < (int)rhs.size() && !isEps) {
                // 移进
                string sym = rhs[item.dot];         //点后面的符号
                Action[i][sym] = "s" + to_string(dfa.trans[i].at(sym));
            } 
            //如果点在最后或者为ε表达式，可以归约或者接受
            else if (item.dot >= (int)rhs.size() || isEps) {
            //产生式编号为0，即拓展文法编号则接受
                if (item.prod == 0) {
                    // 接受
                    Action[i]["$"] = "acc";
                } else {
                    // 归约 — LR(0): 对所有终结符
                    for (auto& t : terminals)
                        Action[i][t] = "r" + to_string(item.prod);
                    Action[i]["$"] = "r" + to_string(item.prod);
                }
            }
        }

        // Goto
        for (auto& [sym, j] : dfa.trans[i])
            if (g.isNT(sym))   // 非终结符 → Goto 表
                Goto[i][sym] = j;
    }
}
```

### SLR(1) — 仅改归约行

```cpp
// 和 LR(0) 的唯一区别：归约不是在"所有终结符"，而是在 FOLLOW(A)
for (int i = 0; i < n; i++) {
    for (auto& item : dfa.states[i]) {
        const auto& rhs = prods[item.prod].rhs;
        bool isEps = (rhs.size() == 1 && rhs[0] == "#");

        if (item.dot < (int)rhs.size() && !isEps) {
            // 移进（同 LR(0)）
            Action[i][rhs[item.dot]] = "s" + to_string(dfa.trans[i].at(rhs[item.dot]));
        } else if (item.dot >= (int)rhs.size() || isEps) {
            if (item.prod == 0) {
                Action[i]["$"] = "acc";
            } else {
                // 归约 — SLR(1): 仅对 FOLLOW(A)
                string A = prods[item.prod].lhs;
                for (auto& a : follow.at(A))              // ← 仅这一行不同
                    Action[i][a] = "r" + to_string(item.prod);
            }
        }
    }
    // Goto（同 LR(0)）
    for (auto& [sym, j] : dfa.trans[i])
        if (g.isNT(sym)) Goto[i][sym] = j;
}
```

### LR(1) — 归约仅在前瞻符列

```cpp
// LR(1) 的 item 比 LR(0) 多了一个 la 字段
for (int i = 0; i < n; i++) {
    for (auto& item : dfa1.states[i]) {
        const auto& rhs = prods[item.prod].rhs;
        bool isEps = (rhs.size() == 1 && rhs[0] == "#");

        if (item.dot < (int)rhs.size() && !isEps) {
            Action[i][rhs[item.dot]] = "s" + to_string(dfa1.trans[i].at(rhs[item.dot]));
        } else if (item.dot >= (int)rhs.size() || isEps) {
            if (item.prod == 0) {
                Action[i]["$"] = "acc";
            } else {
                // 归约 — LR(1): 仅在前瞻符 la 这一列
                Action[i][item.la] = "r" + to_string(item.prod);  // ← 注意 item.la
            }
        }
    }
    for (auto& [sym, j] : dfa1.trans[i])
        if (g.isNT(sym)) Goto[i][sym] = j;
}
```

### LALR(1) — 和 LR(1) 完全相同的填表规则

```cpp
// 表结构和填表代码和 LR(1) 一模一样
// 唯一的区别是：输入 DFA 是合并同心集后的 lalr.states
// 而不是原始的 dfa1.states
// 所以归约时 item.la 可能来自多个原始项目的并集
```

### 四种方法的代码差异只有一行

```cpp
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 四种方法的 buildTable 中，唯独这一处不同：
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LR(0):
Action[i][allSymbols] = "r" + prodNo;        // 所有符号

// SLR(1):
Action[i][FOLLOW[A]]  = "r" + prodNo;        // FOLLOW(A)

// LR(1):
Action[i][item.la]    = "r" + prodNo;        // 精确前瞻符

// LALR(1):
Action[i][item.la]    = "r" + prodNo;        // 合并后的前瞻符
//         ↑ 和 LR(1) 代码一样，只是 item.la 的范围不同
```
