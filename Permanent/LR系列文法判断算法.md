---
date: 2026-06-14
tags:
  - 编译原理
---

# 判断方法

## 判断总流程

```
给定文法 G
  │
  ├─ 构造 LR(0) DFA
  │     │
  │     ├─ 无任何冲突？ ──────────── YES → LR(0) ✓（自动也是 SLR(1)/LALR(1)/LR(1)）
  │     │
  │     └─ 有冲突 → 用 FOLLOW 过滤
  │           │
  │           ├─ FOLLOW 过滤后无冲突？ ── YES → SLR(1) ✓
  │           │
  │           └─ 仍有冲突 → 构造 LR(1) DFA
  │                 │
  │                 ├─ LR(1) DFA 无冲突？ ── YES → LR(1) ✓
  │                       │
  │                       └─ 合并同心集后无新冲突？ ── YES → LALR(1) ✓
  │                       └─ 有新冲突 → 仅是 LR(1)，不是 LALR(1)
  │                 │
  │                 └─ LR(1) DFA 有冲突 → 不是任何 LR 文法
```

---

## 一、[[LR(0)]] 文法的判断

### 判定标准

**LR(0) DFA 的每个状态中，不同时存在以下两类项目**：

| 冲突类型  | 判断                      | 例子                 |
| ----- | ----------------------- | ------------------ |
| 移进-归约 | 同一状态有 `A→α·aβ` 和 `B→γ·` | `E→E·+n` 和 `E'→E·` |
| 归约-归约 | 同一状态有两个不同产生式的归约项目       | `A→a·` 和 `B→a·`    |

### 通俗说法

> 每个状态要么全是移进/待约项目，要么**只有一个**归约项目。不能又有移进又有归约，也不能同时有两个归约项目。

---

## 二、[[SLR(1)]] 文法的判断

### 判定标准

先构造 LR(0) DFA，然后对每个有冲突的状态逐一检查：

**移进-归约冲突**：
```
若状态中有 A→α·aβ（移进 a）和 B→γ·（归约）：
   若 a ∉ FOLLOW(B) → 不冲突！
   若 a ∈ FOLLOW(B) → 冲突！
```

**归约-归约冲突**：
```
若状态中有 A→α· 和 B→β·：
   若 FOLLOW(A) ∩ FOLLOW(B) = ∅ → 不冲突！
   若 FOLLOW(A) ∩ FOLLOW(B) ≠ ∅ → 冲突！
```

### 通俗说法

> LR(0) DFA 有冲突，但用 **FOLLOW 集缩小归约范围**后冲突消失了。

*直接判断FOLLOW集合的交集就可以，也就是无论哪种冲突都可以使用归约-归约冲突的判断方法来判断*

---

## 三、[[LR(1)]] 文法的判断

### 判定标准

构造完整的 **LR(1) DFA**（带前瞻符），直接看：

> LR(1) DFA 的**每个状态中无任何冲突** → 是 LR(1)

也就是：每个状态中，对**同一个**输入符号，最多只有一条动作（移进或归约），且不存在两个不同归约项目对同一个前瞻符归约。

### 通俗说法

> 不偷懒，老老实实给每个项目附上精确前瞻符。精确到不同程度了 → 是 LR(1)。

---

## 四、[[LALR(1)]] 文法的判断

### 判定标准

1. 先构造完整的 LR(1) DFA（必须先确认是 LR(1)）
2. 合并所有核心相同的状态（同心集合并，前瞻符取并集）
3. 检查合并后是否有**新的归约-归约冲突**

| 合并后情况     | 结论                      |
| --------- | ----------------------- |
| 无新冲突      | **是 LALR(1)** ✓         |
| 有新归约-归约冲突 | 仅是 LR(1)，**不是 LALR(1)** |

**注意**：合并不会引入新的移进-归约冲突。

### 通俗说法

> LR(1) 去重——把长得像的状态合并。合并后没打架 → LALR(1)。

---

## 五、一张图判断

```
                LR(0) DFA 无冲突？
                   /        \
                 YES         NO
                  │           │
                  │    用 FOLLOW 过滤后无冲突？
                  │        /        \
                  │      YES         NO
                  │       │           │
                  ▼       ▼           ▼
               LR(0)   SLR(1)    构造 LR(1) DFA
                                        │
                                   无冲突？
                                 /        \
                               YES         NO
                                │           │
                          合并同心集      不是任何
                          后无新冲突？    LR 文法
                         /        \
                       YES         NO
                        │           │
                        ▼           ▼
                    LALR(1)       LR(1)
                                (仅此，不是
                                 LALR(1))
```

---

## 六、判断速查表

| 文法      | 看什么 DFA  | 归约条件      | 判断关键词        |
| ------- | -------- | --------- | ------------ |
| LR(0)   | LR(0)    | 任何符号      | 无冲突          |
| SLR(1)  | LR(0)    | FOLLOW(A) | FOLLOW 消解冲突  |
| LR(1)   | LR(1)    | 精确前瞻符     | 精确，无冲突       |
| LALR(1) | LR(1)→合并 | 合并后精确前瞻符  | 合并后无新归约-归约冲突 |

---

## 七、包含关系

```
LR(0)  ⊂  SLR(1)  ⊂  LALR(1)  ⊂  LR(1)
 真子集      真子集       真子集       真子集
```

- 是 LR(0) → 一定是 SLR(1)、LALR(1)、LR(1)
- 是 SLR(1) → 一定是 LALR(1)、LR(1)
- 是 LALR(1) → 一定是 LR(1)
- 是 LR(1) → 不一定是 LALR(1)（反过来不成立）





---





# LR 系列文法判断算法：从伪代码到完整实现

---

## 一、大白话理解

判断文法属于哪类 LR，本质就是**检查分析表里有没有冲突**。

```
一个格子里有两条动作 → 冲突 → 不是该类文法
所有格子最多一条动作 → 无冲突 → 是该类文法
```

四种方法的区别在于**用多精确的手段来判断"什么时候归约"**，越精确冲突越少，能判定的文法越多。

---

## 二、数据结构定义

```cpp
// ═══════════════════════════════════════════════
// 符号编码（同前两个文件）
// ═══════════════════════════════════════════════

const int TERM_EOF   = 0;    // $
const int TERM_PLUS  = 1;    // +
const int TERM_N     = 2;    // n
const int TERM_LP    = 3;    // (
const int TERM_RP    = 4;    // )
const int TERM_A     = 5;    // a
const int TERM_B     = 6;    // b

const int NONTERM_OFFSET = 100;
const int NONTERM_E  = 101;
const int NONTERM_T  = 102;
const int NONTERM_S  = 103;
const int NONTERM_A  = 104;
const int NONTERM_B  = 105;

bool isTerminal(int sym)     { return sym < 100; }
bool isNonTerminal(int sym)  { return sym >= 100; }


// ═══════════════════════════════════════════════
// 产生式
// ═══════════════════════════════════════════════

struct Rule {
    int left;                  // 左部非终结符
    vector<int> right;         // 右部符号序列
    int length() const { return right.size(); }
};

vector<Rule> Grammar;
int startRule = 0;             // 拓广产生式 S' → S 的编号


// ═══════════════════════════════════════════════
// LR(0) 项目与状态
// ═══════════════════════════════════════════════

struct LR0Item {
    int ruleNo;                // 产生式编号
    int dotPos;                // 点位置

    bool operator==(const LR0Item& o) const {
        return ruleNo == o.ruleNo && dotPos == o.dotPos;
    }
    bool operator<(const LR0Item& o) const {
        if (ruleNo != o.ruleNo) return ruleNo < o.ruleNo;
        return dotPos < o.dotPos;
    }

    // 判断项目类型
	//归约项的点位置与项右侧长度一样     归约项
    bool isReduceItem() const {
        return dotPos == Grammar[ruleNo].length();
    }
	//移进项的点位置小于项目长度，且点右侧为终结符     移进项
    bool isShiftItem() const {
        return dotPos < Grammar[ruleNo].length() &&
               isTerminal(Grammar[ruleNo].right[dotPos]);
    }
    //移进项目的点的右侧即为移进的符号
    int getShiftSymbol() const {
        return Grammar[ruleNo].right[dotPos];  // 点后终结符
    }
};

struct LR0State {
    set<LR0Item> items;

    // 收集该状态中所有移进符号
    vector<int> getShiftSymbols() const {
        vector<int> result;
        for (auto& item : items)
            if (item.isShiftItem())
                result.push_back(item.getShiftSymbol());
        return result;
    }

    // 收集该状态中所有归约产生式编号
    vector<int> getReduceRules() const {
        vector<int> result;
        for (auto& item : items)
            if (item.isReduceItem() && item.ruleNo != startRule)
                result.push_back(item.ruleNo);
        return result;
    }

    // 检查移进-归约冲突（LR(0)级别）
	//当该状态同时存在移进归约项目时，则冲突
    bool hasShiftReduceConflict() const {
        return !getShiftSymbols().empty() && !getReduceRules().empty();
    }

    // 检查归约-归约冲突（LR(0)级别）
	//当该状态同时存在两个及以上归约项目时，则冲突
    bool hasReduceReduceConflict() const {
        return getReduceRules().size() >= 2;
    }
};


// ═══════════════════════════════════════════════
// LR(1) 项目与状态
// ═══════════════════════════════════════════════

struct LR1State {
    // (ruleNo, dotPos) 键值对→ 前瞻符集合
    map<pair<int,int>, set<int>> items;

    // 遍历所有项目
    void forEachItem(function<void(int,int,int)> fn) const {
        for (auto& [key, las] : items)
            for (int la : las) fn(key.first, key.second, la);
    }

    // 提取核心（去掉前瞻符）,利用集合来排除重复
    set<pair<int,int>> getCore() const {
        set<pair<int,int>> core;
        for (auto& [key, _] : items) core.insert(key);
        return core;
    }

    // 检查对某个输入符号 a，是否有多个动作
    bool hasConflict() const {
        map<int, set<string>> actions;  // 符号 → 动作集合

        forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];
			//点不在项的最右侧且点后为终结符号，则为移进
            if (dotPos < rule.length() && isTerminal(rule.right[dotPos]))
                actions[rule.right[dotPos]].insert("s");     // 移进
			//点在项最右且该项不为接受项，则归约
            else if (dotPos == rule.length() && ruleNo != startRule)
                actions[la].insert("r" + to_string(ruleNo));  // 归约
        });

        for (auto& [sym, acts] : actions)
            if (acts.size() > 1) return true;
        return false;
    }

    // 检查归约-归约冲突（合并后专用）
    bool hasReduceReduceConflict() const {
        map<int, set<int>> reduceOnly;  // 符号 → 产生式集合

        forEachItem([&](int ruleNo, int dotPos, int la) {
            if (dotPos == Grammar[ruleNo].length() && ruleNo != startRule)
                reduceOnly[la].insert(ruleNo);
        });

        for (auto& [sym, rules] : reduceOnly)
            if (rules.size() > 1) return true;
        return false;
    }
};


// ═══════════════════════════════════════════════
// 外部依赖（由 DFA 构建模块提供）
// ═══════════════════════════════════════════════

extern vector<LR0State> lr0States;
extern vector<LR1State> lr1States;
extern vector<LR1State> lalrStates;
extern map<int, set<int>> FOLLOW;


// ═══════════════════════════════════════════════
// 判定结果枚举
// ═══════════════════════════════════════════════

enum LRType {
    IS_LR0,
    IS_SLR1,
    IS_LALR1,
    IS_LR1,
    NOT_LR
};

// 包含关系自动推导：
//   IS_LR0   → 自动也是 IS_SLR1, IS_LALR1, IS_LR1
//   IS_SLR1  → 自动也是 IS_LALR1, IS_LR1
//   IS_LALR1 → 自动也是 IS_LR1
//   IS_LR1   → 仅此，不一定是 IS_LALR1 (反过来不成立)
```

---

## 三、两类冲突

贯穿所有四种方法，只存在两种冲突：

```
类型1：移进-归约冲突
  同一状态下，输入同一个符号 a
  同时有 A→α·aβ（要求移进 a）
  又有    B→γ·  （要求按 B→γ 归约）
  → 不知道该移进还是归约

类型2：归约-归约冲突
  同一状态下，输入同一个符号 a
  同时有 A→α·（要求按 A→α 归约）
  又有    B→β·（要求按 B→β 归约）
  → 不知道该按哪个产生式归约
```

---

## 四、LR(0) 文法判断

### 4.1 判定标准

```
输入：LR(0) DFA
输出：是/否 LR(0)

是 LR(0) ⇔ DFA 的每个状态中：
  1. 最多只有一个归约项目，且
  2. 如果有归约项目，则没有移进项目
（即：移进和归约不能共存，两个不同的归约也不能共存）
```

### 4.2 伪代码

```
算法：判断是否是 LR(0) 文法

for (每个状态 I ∈ LR(0) DFA)
    reduceCount = 0;
    shiftExists = false;

    for (I 中每个项目)
        if (项目的点在最后面)
	        if(这个项目的产生式不是0号产生式，也就是增广文法)
	            reduceCount++;              // 计数归约项目

        else (项目的点不再最后面)           // 点后是终结符
			if(点后面是终结符)
	            shiftExists = true;

    if (reduceCount > 1)
        return NOT_LR0;                 // 归约-归约冲突

    if (reduceCount == 1 && shiftExists)
        return NOT_LR0;                 // 移进-归约冲突

return IS_LR0;
```

### 6.3 手工判定示例

**例1**：`E' → E,  E → E + n | n`

```
I₁ = {E' → E·,  E → E·+n}
     ↑归约       ↑移进（点后+）

reduceCount=1, shiftExists=true → 移进-归约冲突 → 不是 LR(0)
```

**例2**：能不能造一个 LR(0) 的文法？

```
S' → S
S  → a S b | ε

I₀: S'→·S, S→·aSb, S→·    ← 有S→·归约，且有S→·aSb移进 → 冲突
→ 不是 LR(0)

几乎所有"有用"的文法都不是 LR(0)，因为 S→ε 这种空产生式
一出现就自带归约项目，同时其他项目含移进。
```

### 6.4 C++ 实现

```cpp
enum LRType { LR0, SLR1, LR1, LALR1, NOT_LR };

bool isLR0(vector<LR0State>& states, int startRule) {
    for (int i = 0; i < states.size(); i++) {
        int reduceCount = 0;
        bool hasShift = false;

        for (auto& item : states[i].items) {
            Rule& rule = Grammar[item.ruleNo];

            if (item.dotPos == rule.right.size()) {
                // 归约项目
                if (item.ruleNo != startRule)  // S'→S· 不算冲突
                    reduceCount++;
            } else {
                // 检查点后是否是终结符（移进项目）
                int next = rule.right[item.dotPos];
                if (isTerminal(next))
                    hasShift = true;
            }
        }

        if (reduceCount >= 2) return false;  // 归约-归约冲突
        if (reduceCount >= 1 && hasShift) return false;  // 移进-归约冲突
    }
    return true;
}
```

---

## 五、SLR(1) 文法判断

### 5.1 核心思想

LR(0) 判不了 → 用 FOLLOW 集给归约"瘦身"。

```
LR(0): 归约对所有符号 → 冲突多
SLR(1): 归约只对 FOLLOW(A) → 冲突少
如果瘦身后冲突没了 → 是 SLR(1)
```

### 5.2 伪代码

```
算法：判断是否是 SLR(1) 文法

输入：LR(0) DFA + FOLLOW 集
输出：是/否 SLR(1)

for (每个状态 I ∈ LR(0) DFA)
    // ━━━ 检查移进-归约冲突 ━━━
    for (I 中每个移进项目 A → α·aβ)
        for (I 中每个归约项目 B → γ·，B ≠ S')
            if (a ∈ FOLLOW(B))      // 如果移进项的移进符号属于归约项的FOLLOW集
                return NOT_SLR1;     // FOLLOW 救不了！

    // ━━━ 检查归约-归约冲突 ━━━
    for (I 中每对不同的归约项目 B → γ· 和 C → δ·)
        if (FOLLOW(B) ∩ FOLLOW(C) ≠ ∅)
            return NOT_SLR1;         // FOLLOW 有交集！

return IS_SLR1;
```

### 5.3 手工判定示例

**例1**：`E' → E,  E → E + n | n`，FOLLOW(E)={$,+}

```
I₁: E'→E· (acc) + E→E·+n (移进+)
  移进符号是 +
  E'→E· 是 S'→S·，特殊处理为 acc at $，不算冲突
  → 无冲突

I₂: E→n· (归约)
  FOLLOW(E)={$,+}
  只有+和$列有 r2，无移进项目 → 无冲突

I₄: E→E+n· (归约)
  FOLLOW(E)={$,+}
  → 无冲突

→ 是 SLR(1) ✓
```

**例2**：括号文法 `S' → S,  S → (S)S | ε`，FOLLOW(S)={$,)}

```
I₀: S→· (移进() + S→· (归约，FOLLOW={$,)})
  移进符号: (
  FOLLOW(S)={$,)}，不包含( → 无冲突 ✓

I₂: 同上分析，无冲突 ✓
I₄: 同上分析，无冲突 ✓

→ 是 SLR(1) ✓
```

**例3（经典反例）**：

```
S' → S
S  → L = R | R
L  → * R | id
R  → L

FOLLOW(L) = {=, $}
FOLLOW(R) = {=, $}

某状态有 L→id· 和 R→L·
  FOLLOW(L) ∩ FOLLOW(R) = {=,$} ≠ ∅
  → 不是 SLR(1)！
```

### 5.4 C++ 实现

```cpp
bool isSLR1(vector<LR0State>& states, int startRule,
            map<int, set<int>>& FOLLOW) {
    
    for (int i = 0; i < states.size(); i++) {
        vector<int> shifts;      // 该状态下所有移进符号
        vector<int> reduces;     // 该状态下所有归约产生式编号

        for (auto& item : states[i].items) {
            Rule& rule = Grammar[item.ruleNo];

            if (item.dotPos == rule.right.size()) {
                if (item.ruleNo != startRule)
                    reduces.push_back(item.ruleNo);
            } else {
                int next = rule.right[item.dotPos];
                if (isTerminal(next))
                    shifts.push_back(next);
            }
        }

        // 检查移进-归约冲突
        for (int a : shifts) {
            for (int r : reduces) {
                int B = Grammar[r].left;    // 归约的左部非终结符
                if (FOLLOW[B].count(a))     // a ∈ FOLLOW(B)?
                    return false;
            }
        }

        // 检查归约-归约冲突
        for (int j = 0; j < reduces.size(); j++) {
            for (int k = j + 1; k < reduces.size(); k++) {
                int B = Grammar[reduces[j]].left;
                int C = Grammar[reduces[k]].left;
                // FOLLOW(B) ∩ FOLLOW(C) ≠ ∅ ?
                for (int a : FOLLOW[B]) {
                    if (FOLLOW[C].count(a))
                        return false;
                }
            }
        }
    }
    return true;
}
```

---

## 六、LR(1) 文法判断

### 6.1 判定标准

```
输入：LR(1) DFA
输出：是/否 LR(1)

是 LR(1) ⇔ LR(1) DFA 的每个状态中，
对同一个前瞻符，最多只有一个动作。
```

### 6.2 伪代码

```
算法：判断是否是 LR(1) 文法

for (每个状态 I ∈ LR(1) DFA)
    // 收集每个输入符号上的动作
    for (每个项目 [A → α·aβ, b] ∈ I)
        记录：输入 a 上有移进到 Goto(I,a)
    
    for (每个项目 [A → α·, a] ∈ I，A ≠ S')
        记录：输入 a 上有归约 rⱼ
    
    // 检查冲突
    for (每个输入符号 a)
        if (既有移进又有归约) 或 (有两个不同归约)
            return NOT_LR1;

return IS_LR1;
```
### 6.3 手工判定示例

文法 `A' → A,  A → (A) | a` 的 LR(1) DFA：

```
I₀: 符号( → s2, 符号a → s3, 符号A → Goto=1
    无归约项目 → 无冲突 ✓

I₁: 符号$ → acc
    → 无冲突 ✓

I₂: 符号( → s2, 符号a → s5, 符号A → Goto=4
    无归约 → 无冲突 ✓

I₃: [A→a·, $] → 符号$ → r2
    无其他 → 无冲突 ✓

I₄: [A→(A·), $] → 符号) → s6
    无归约 → 无冲突 ✓

I₅: [A→a·, )] → 符号) → r2
    无其他 → 无冲突 ✓

I₆: [A→(A)·, $] → 符号$ → r1
    无其他 → 无冲突 ✓

→ 是 LR(1) ✓
```

### 6.4 C++ 实现

```cpp
bool isLR1(vector<LR1State>& lr1States, int startRule) {
    
    for (int i = 0; i < lr1States.size(); i++) {
        // actions[符号] = 动作集合
        map<int, set<string>> actions;

        lr1States[i].forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];

            if (dotPos < rule.right.size()) {
                int next = rule.right[dotPos];
                if (isTerminal(next)) {
                    // 移进
                    actions[next].insert("s");
                }
            } else {
                if (ruleNo == startRule) {
                    actions[la].insert("acc");
                } else {
                    // 归约
                    actions[la].insert("r" + to_string(ruleNo));
                }
            }
        });

        // 检查：对同一个符号，是否有多个动作
        for (auto& [sym, acts] : actions) {
            if (acts.size() > 1)
                return false;   // 冲突！
        }
    }
    return true;
}
```

---

## 七、LALR(1) 文法判断

### 7.1 判定标准

```
输入：LR(1) DFA
输出：是/否 LALR(1)

1. 先判断是否是 LR(1)（LR(1) 不是 → LALR(1) 肯定也不是）
2. 合并所有同心集
3. 检查合并后是否有新的归约-归约冲突
   （移进-归约冲突不会新出现，不用检查）
```

### 7.2 伪代码

```
算法：判断是否是 LALR(1) 文法

1. if (!isLR1(lr1States))  return NOT_LALR1;

2. 合并同心集 → lalrStates

3. // 只检查归约-归约冲突
   for (每个合并后的状态 I' ∈ lalrStates)
        for (每个输入符号 a)
            收集在 a 上触发的归约产生式
            if (有 ≥ 2 个不同的归约产生式)
                return NOT_LALR1;    // 合并引入了新冲突！

4. return IS_LALR1;
```

### 7.3 关键性质

```
性质1（好消息）：
  合并同心集不会引入新的移进-归约冲突。

  原因：移进只看"点后是终结符"，不看前瞻符。
  合并不改状态的核心项目集，所有移进项目原样保留。
  所以如果合并前移进和归约不相交，合并后也不会相交。

性质2（需警惕）：
  合并同心集可能引入新的归约-归约冲突。

  原因：同一个核心的两个归约项目，
  合并前前瞻符不相交 → 同一列无冲突
  合并后前瞻符取并集 → 可能相交 → 冲突！
```

### 7.4 手工判定示例

```
LR(1) 状态：
  Iₓ: [A → a·, $],  [B → a·, )]    ← 对$归约A，对)归约B，无冲突
  Iᵧ: [A → a·, )],  [B → a·, $]    ← 对)归约A，对$归约B，无冲突

合并后 Iₓᵧ: [A → a·, {$/)}],  [B → a·, {$/)}]
  → 对$：又有 r_A 又有 r_B → 冲突！
  → 不是 LALR(1)，但**是 LR(1)**
```

### 7.5 C++ 实现

```cpp
bool isLALR1(vector<LR1State>& lr1States, int startRule,
             map<int, map<int, int>>& lr1Goto) {
    
    // 第1步：先判断是不是 LR(1)
    if (!isLR1(lr1States, startRule))
        return false;
    
    // 第2步：合并同心集
    vector<LR1State> merged;
    map<int, int> oldToNew;
    mergeCores(lr1States, merged, oldToNew);
    
    // 第3步：只检查归约-归约冲突
    for (int i = 0; i < merged.size(); i++) {
        // 对每个输入符号，记录该符号上的归约动作
        map<int, set<int>> reduceActions;  // [符号] → {产生式编号}
        
        merged[i].forEachItem([&](int ruleNo, int dotPos, int la) {
            Rule& rule = Grammar[ruleNo];
            
            if (dotPos == rule.right.size() && ruleNo != startRule) {
                reduceActions[la].insert(ruleNo);
            }
        });
        
        // 检查
        for (auto& [sym, ruleSet] : reduceActions) {
            if (ruleSet.size() > 1)
                return false;   // 合并后引入了归约-归约冲突！
        }
    }
    
    return true;
}
```

---

## 八、判断流程图

```
给定文法 G
  │
  ├─ 构造 LR(0) DFA
  │     │
  │     ├─ 移进-归约冲突？ 归约-归约冲突？
  │     │       NO → LR(0) ✓
  │     │
  │     └─ YES → 计算 FOLLOW 集
  │           │
  │           ├─ a∈FOLLOW(B) 导致冲突？FOLLOW有交集？
  │           │       NO → SLR(1) ✓
  │           │
  │           └─ YES → 构造 LR(1) DFA
  │                 │
  │                 ├─ 有冲突？
  │                 │       YES → 不是任何 LR 文法
  │                 │
  │                 └─ NO → LR(1) ✓
  │                       │
  │                       └─ 合并同心集
  │                             │
  │                             ├─ 有新归约-归约冲突？
  │                             │       YES → 仅是 LR(1)，不是 LALR(1)
  │                             │
  │                             └─ NO → LALR(1) ✓
```

---

## 九、速查表

| 判断什么    | 看什么 DFA            | 关键的"如果"                         |
| ------- | ------------------ | ------------------------------- |
| LR(0)   | LR(0) DFA          | 状态中移进和归约共存？两个归约共存？              |
| SLR(1)  | LR(0) DFA + FOLLOW | 移进符号 ∈ FOLLOW(归约左部)？FOLLOW 有交集？ |
| LR(1)   | LR(1) DFA          | 同一前瞻符上多个动作？                     |
| LALR(1) | LR(1) → 合并         | 合并后新出现归约-归约冲突？                  |


---

## 附：简洁版数据结构与实现（实验代码风格）

### SLR(1) 判定 — 直接检查冲突

```cpp
struct SLRResult {
    bool ok;                // 是/否 SLR(1)
    std::string reason;     // 不是的话，原因是什么（考试可以直接用）
};

SLRResult checkSLR1(const Grammar& g, const DFA0& dfa, const SetMap& follow) {
    const auto& prods = dfa.augProds;

    for (int si = 0; si < (int)dfa.states.size(); si++) {
        const S0& state = dfa.states[si];

        // 收集该状态所有移进符号
        set<string> shiftSyms;
        for (auto& item : state) {
            const auto& rhs = prods[item.prod].rhs;
            if (item.dot < (int)rhs.size() && rhs[item.dot] != "#")
                shiftSyms.insert(rhs[item.dot]);
        }

        // 检查每个归约项目
        for (auto& item : state) {
            const auto& rhs = prods[item.prod].rhs;
            bool isEps = (rhs.size() == 1 && rhs[0] == "#");
            bool isReduce = (item.dot >= (int)rhs.size()) || isEps;
            if (!isReduce || item.prod == 0) continue;  // 跳过接受项目

            string A = prods[item.prod].lhs;      // 归约产生式的左部
            const SymSet& fol = follow.at(A);      // FOLLOW(A)

            // 移进-归约冲突：移进符号 ∈ FOLLOW(A)?
            for (auto& a : fol) {
                if (shiftSyms.count(a)) {
                    return {false,
                        "状态 " + to_string(si) + " 存在移进-规约冲突："
                        "符号 '" + a + "' 既可移进又可按 [" +
                        prodToString(prods[item.prod]) + "] 规约"};
                }
            }

            // 归约-归约冲突：和另一个归约项目的 FOLLOW 有交集？
            for (auto& item2 : state) {
                if (item2 == item) continue;
                const auto& rhs2 = prods[item2.prod].rhs;
                bool isEps2 = (rhs2.size() == 1 && rhs2[0] == "#");
                bool isReduce2 = (item2.dot >= (int)rhs2.size()) || isEps2;
                if (!isReduce2 || item2.prod == 0) continue;

                string B = prods[item2.prod].lhs;
                const SymSet& folB = follow.at(B);

                for (auto& a : fol) {
                    if (folB.count(a)) {
                        return {false,
                            "状态 " + to_string(si) + " 存在规约-规约冲突："
                            "符号 '" + a + "' 既可按 [" +
                            prodToString(prods[item.prod]) +
                            "] 规约，又可按 [" +
                            prodToString(prods[item2.prod]) + "] 规约"};
                    }
                }
            }
        }
    }
    return {true, ""};
}
```

### LR(1) 判定 — 检查同一前瞻符上是否多个动作

```cpp
bool isLR1(const DFA1& dfa1) {
    const auto& prods = dfa1.augProds;

    for (int si = 0; si < (int)dfa1.states.size(); si++) {
        // actionsInState[符号] = 该符号上的动作集合
        map<string, set<string>> actions;

        for (auto& item : dfa1.states[si]) {
            const auto& rhs = prods[item.prod].rhs;
            bool isEps = (rhs.size() == 1 && rhs[0] == "#");

            if (item.dot < (int)rhs.size() && !isEps) {
                // 移进
                actions[rhs[item.dot]].insert("s");
            } else if (item.dot >= (int)rhs.size() || isEps) {
                if (item.prod != 0) {
                    // 归约（仅在前瞻符 la 上）
                    actions[item.la].insert("r" + to_string(item.prod));
                }
            }
        }

        // 任一符号上有多个动作 → 冲突
        for (auto& [sym, acts] : actions)
            if (acts.size() > 1)
                return false;
    }
    return true;
}
```

### LALR(1) 判定 — 合并后检查归约-归约冲突

```cpp
bool isLALR1(const DFA1& dfa1, const DFAl& lalr) {
    // 不是 LR(1) → 不可能是 LALR(1)
    if (!isLR1(dfa1)) return false;

    // 检查合并后的每个状态
    const auto& prods = lalr.augProds;

    for (int si = 0; si < (int)lalr.states.size(); si++) {
        // reduceAt[符号] = 该符号上可归约的产生式集合
        map<string, set<int>> reduceAt;

        for (auto& item : lalr.states[si]) {
            const auto& rhs = prods[item.prod].rhs;
            bool isEps = (rhs.size() == 1 && rhs[0] == "#");
            bool isReduce = (item.dot >= (int)rhs.size()) || isEps;
            if (isReduce && item.prod != 0)
                reduceAt[item.la].insert(item.prod);
        }

        // 同一符号上有 2 个以上归约 → 合并引入了归约-归约冲突
        for (auto& [sym, prods] : reduceAt)
            if (prods.size() > 1)
                return false;
    }
    return true;
}
```

### 简洁版 vs 原版

|           | 原版（数值编码）                       | 简洁版（实验代码）                               |
| --------- | ------------------------------ | --------------------------------------- |
| 符号        | `int TERM_N = 2`               | `string "n"`                            |
| 空产生式判断    | `rhs是{}`                       | `rhs == {"#"}`                          |
| 冲突检查      | 多层 if 嵌套                       | 先收集 actions map，再查 `size()>1`           |
| 归约项目判定    | `dotPos == rule.length()`      | `dot >= rhs.size() \|\| (rhs == {"#"})` |
| FOLLOW 访问 | `FOLLOW[A]`（map<int,set<int>>） | `follow.at(A)`（map<string,set<string>>） |
| 错误报告      | 只返回 bool                       | 返回 `{false, "具体冲突原因"}` — 实验四需要！         |

