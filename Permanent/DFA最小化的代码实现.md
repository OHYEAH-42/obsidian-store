---
date: 2026-07-05
tags:
  - 编译原理
cssclasses:
  - "[[编译原理]]"
  - "[[词法分析]]"
aliases:
---
# 拆分方法

[[hopcroft算法]]的实现

## 具体思路：
### 1. 初始划分

先把所有状态分成两拨：**终态** 一组，**非终态** 一组。

为什么？因为终态接受字符串、非终态不接受，这俩性质完全不同，肯定可区分。

### 2. 迭代细化

对每一组，检查**组内的状态在同一个字符下会不会跑到不同的组**：

- 全部跑到同一个组 → 这轮通过，留着
- 跑到不同的组 → **裂开**，按目标分组拆成更小的组

### 3. 重复直到稳定

每轮用所有字符都检查一遍，直到所有组都**不能再拆**为止。每一组就是一个"等价类"。

### 4. 生成最小化 DFA

每组等价类 → 一个 MDFA 结点，转移关系照搬。


## 代码实现

### 数据结构

#### MDFA结点

- 状态编号`state`
- 是否终结结点`isEnd`，由所持有的DFA结点决定
- 所持有的DFA结点集合`dfaNodes`
- 当前状态下的转移关系`transfers`

```C++
struct MDfaNode {
	// 结点的定义都类似
    int state;
    bool isEnd;
    set<DfaNode*> dfaNodes; // 持有的DFA结点
    map<char, int> transfer;
	
	// 绑定DFA结点，看看自己是不是终态
    void bindDfaNodes(set<DfaNode*> dfaNodes) {
        this->dfaNodes = dfaNodes;
        for (DfaNode* node : dfaNodes) {
            if (node->isEnd) {
                isEnd = true;
                break;
            }
        }
    }

    MDfaNode(int state) : state(state), isEnd(false) {}
	
    bool operator== (const MDfaNode& node) { // 根据所持有的DFA结点，比较二者是否等价
        if (node.dfaNodes.size() != dfaNodes.size()) return false;
        for (DfaNode* dfaNode : node.dfaNodes)
            if (!dfaNodes.count(dfaNode)) return false;
        return true;
    }
};
```

#### MDFA图

```
vector <MDfaNode> MDfaGraph
```

### 实现代码

#### 移进

从一个`set<DfaNode*>`，根据某Symbol移进的状态集合，用于根据MDFA生成转移关系

```C++
set<int> forward(set<DfaNode*> source, char symbol) {
    set<int> result;
    for (DfaNode* node : source) {
        if (!node->transfers.count(symbol)) continue; // 当前DFA结点上不存在该转移关系
        result.insert(node->transfers[symbol]);
    }
    return result;
}
```

#### DFA最小化

- 已拆分列表
- 待拆分列表
- 暂存某状态集合中每个状态转移目的地的map（用于拆分）
- 顶层循环是**Symbol**，每一次进入循环，都以上一次的已拆分结果作为本次的待拆分目标。

```C++
// set<char> symbols
void minimize() { // 最小化
    set<DfaNode*> left, right; // 两个拆分
    vector<set<DfaNode*>> completed; // 已完成拆分
    vector<set<DfaNode*>> prepared; // 待拆分
    map<int, set<DfaNode*>> destination; // 转移目的地，做暂存使用
    
    // 根据是否终结节点初始化
    for (DfaNode* node : dfa.getNodes()) {
        if (node->isEnd) right.insert(node);
        else left.insert(node);
    }
    // 非终态的结点，放在completed的左组中
    completed.push_back(left);
    // 终态的结点，放在completed的右组中
    completed.push_back(right);
    
    // 对每一个输入字符做一轮划分
    for (const char symbol : symbols) {
        prepared = completed; // 将上一次的拆分结果作为这一次的待拆分队列
        completed.clear(); // 清空拆分结果
        
        while (prepared.size()) {
            if (prepared.empty()) break;
            destination.clear();
            
            // 取出一个待拆分的分组cur
            set<DfaNode*> cur = prepared.front();// 也就是prepared[0]
            
            if (cur.empty()) {
                prepared.erase(prepared.begin(), prepared.begin() + 1); // 把cur出队
                continue; // 空集合
            }
            if (cur.size() == 1) {
                completed.push_back(cur); // 长度为1，无需拆分
                prepared.erase(prepared.begin(), prepared.begin() + 1);
                continue;
            }
            
            // 对cur中的每一个状态，看它在symbol上跳到哪个分组
            // 记录到destination中
            // destniation[key]=跳到同一分组的状态合集
            for (DfaNode* node : cur) {
                if (!node->transfers.count(symbol)) { // 不存在该转移
                    destination[-1].insert(node);
                    continue;
                }
                // 不存在转移，则放在不能转移的组
                
                // 可以跳转，则看看会跳转到哪个组
                int target = node->transfers[symbol]; // 下一个DFA状态
                
                // 在prepared组里面查，看看会到哪个组
                for (int i = 0; i < prepared.size(); ++i) {
                    bool matched = false;
                    //取出prepared中的第i个分组
                    for (DfaNode* state : prepared[i]) {
	                    // 该分组存在目标状态
                        if (state->state == target) { // 移进的目标是这个集合
                            matched = true;
                            // 把当前node记录到第i组下
                            destination[i].insert(node);
                            break;
                        }
                    }
                    //赵傲确切分组就跳出，防止无用功
                    if (matched) break;
                }
                
                // 同理，对completed组也来找会跳转到哪个组
                for (int i = 0; i < completed.size(); ++i) {
                    bool matched = false;
                    for (DfaNode* state : completed[i]) {
                        if (state->state == target) { // 移进的目标是这个集合
                            matched = true;
                            destination[prepared.size() + i].insert(node);
                            break;
                        }
                    }
                    if (matched) break;
                }
            }
            
            
            prepared.erase(prepared.begin(), prepared.begin() + 1); // 把cur出队
            // 找内奸
            if (destination.size() > 1) { // 有内奸
				// 按转移目标拆成多个子分组，放回 prepared 继续拆
                for (auto& p : destination)
                    prepared.push_back(p.second);
                continue;
            }
            // 没有内奸
            completed.push_back(cur);
        }
    }
    
    // 根据划分结果生成MDFA结点
    MDfaNode* startNode = new MDfaNode(0);
    set<DfaNode*> divideOfStartNode;
    for (set<DfaNode*> divide : completed) {
        for (DfaNode* node : divide) {
            if (node->state == 0) {
                divideOfStartNode = divide;
                break;
            }
        }
        if (divideOfStartNode.size()) break; // 已经找到起始划分
    }
    startNode->bindDfaNodes(divideOfStartNode); // 绑定划分
    nodes.push_back(startNode);
    for (int i = 0; i < nodes.size(); ++i) { // 生成MDFA结点
        MDfaNode* cur = nodes[i];
        for (const char symbol : symbols) {
            set<int> next = forward(cur->dfaNodes, symbol); // 获取转移目标
            if (next.empty()) continue;
            for (set<DfaNode*> divide : completed) { // 寻找和目标等价的划分
                bool matched = false;
                for (DfaNode* node : divide) {
                    if (next.count(node->state)) {
                        matched = true;
                        break;
                    }
                }
                if (!matched) continue; // 不匹配
                MDfaNode* instance = new MDfaNode(nodes.size());
                instance->bindDfaNodes(divide);
                for (MDfaNode* exist : nodes) { // 寻找是否已经存在该结点
                    if (*exist == *instance) {
                        instance = exist;
                        break;
                    }
                }
                if (instance->state == nodes.size()) // 不存在的结点
                    nodes.push_back(instance);
                cur->transfer[symbol] = instance->state;
                break;
            }
        }
    }
}
```