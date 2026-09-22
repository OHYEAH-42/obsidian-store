---
date: 2026-07-05
cssclasses:
  - "[[词法分析]]"
tags:
  - 编译原理
---
# 数据结构

## NFA结点

NFA部分与[[正则表达式转NFA的代码实现]]类似

```C++
struct NfaNode {
    int state;
    bool isEnd;
    map<char, vector<NfaNode*>> transfers;
};
```

## NFA子图

```C++
struct NfaGraph {
    NfaNode* start;
    NfaNode* end;
};
```

## 符号集

```C++
set<char> symbols
```

## DFA结点

```C++
struct DfaNode {
	// 类似于NFA结点的定义
    int state;
    bool isEnd = false;
    map<char, int> transfers; // 转移
    
    set<NfaNode*> nfaNodes;     //NFA结点集合表示DFA结点
    
    DfaNode() : state(0) {}
    DfaNode(int state) : state(state) {}
    DfaNode(const DfaNode& node) : state(node.state), transfers(node.transfers), nfaNodes(node.nfaNodes) {}

    void bindNfaNodes(set<NfaNode*> nodes) { // 将NFA集合绑定进该DFA结点，同时更新isEnd的值
        nfaNodes = nodes;
        for (NfaNode* node : nodes) {
            if (node->isEnd) {
                isEnd = true;
                return;
            }
        }
    }

    bool operator== (const DfaNode& node) { // 通过比较持有的NFA结点集合，判断两个DFA状态是否等价
        if (nfaNodes.size() != node.nfaNodes.size()) return false;
        for (NfaNode* nfaNode : nfaNodes) {
            if (!node.nfaNodes.count(nfaNode)) return false;
        }
        return true;
    }
};
```

## DFA图

```
vector <DfaNode> DfaGraph
```

# 代码实现

  子集构造法，有以下几个关键点：

- 初始状态是NFA初始节点的EPSILON闭包
- 对于所有的Symbols，对已确定的DFA结点进行转移（转移到一个`set<NfaNode*>`），判断该转移到的目标是否已经存在于已确定的DFA结点中，没有的话就新增一个DFA状态。对于该转移目标，记录进当前DFA状态的转移表中。
- 对于转移：在某**NFA**结点上，先根据某Symbol进行**一次移进，同时移进结果求EPSILON闭包。

  那么代码由三部分构成：EPSILON闭包`epsilonClosure`、移进`forward`、生成DFA`generate`

## EPSILON闭包

处理ε移动

```C++
 set<NfaNode*> epsilonClosure(NfaNode* source) { // NFA节点的EPSILON闭包
    set<NfaNode*> closure;    // 存放所有可以通过epsilon到达的结点
    stack<NfaNode*> prepared; // DFS栈：待处理结点
    map<int, int> visited;    // 已访问结点
    prepared.push(source);    //从开始结点开始遍历
    
    while (prepared.size()) {
        NfaNode* cur = prepared.top();
        prepared.pop();
        if (visited[cur->state]) continue;  //已访问则跳过
        closure.insert(cur);                //没访问则加入
        visited[cur->state] = 1;            //标记已访问
        for (NfaNode* next : cur->transfers[EPSILON])//遍历可ε到达的结点，入DFS栈
            prepared.push(next);
    }
    return closure;
}
```

## 移进

根据某Symbol进行一次移进，并对结果求EPSILON闭包

```C++
set<NfaNode*> forward(NfaNode* source, char symbol) { // 以symbol步进
    set<NfaNode*> result;
    
    // 从 NFA 结点 `source` 出发，读入字符 `symbol`，返回所有可能到达的 NFA 结点的集合
    for (NfaNode* next : source->transfers[symbol]) {
        result.insert(next);
        // 对每个加入的NFA结点求其EPSILON闭包
        set<NfaNode*> closureOfNext = epsilonClosure(next);
        result.insert(closureOfNext.begin(), closureOfNext.end());
    }
    return result;
}
```

# DFA生成

```C++
// NfaGraph nfaGraph
// set<char> symbols
void generate() { // 生成DFA图
	// 创建DFA的初始状态，即加入初始DFA结点
    DfaNode* start = new DfaNode();
    start->bindNfaNodes(epsilonClosure(nfaGraph.start)); // 将NFA节点列表绑定进DFA状态中
    nodes.push_back(start); // 加入初始节点
    
    // 主循环，遍历每个DFA结点（nodes会在循环中不断扩大）
    for (int i = 0; i < nodes.size(); ++i) {
        DfaNode* cur = nodes[i];
        // 对每个符号计算移进
        for (char symbol : symbols) {
            set<NfaNode*> nfaNodesOfSymbol;  // 读入symbol后，所有可能的NFA状态合集
            // 遍历当前DFA状态持有的每个NFA结点
            for (NfaNode* next : cur->nfaNodes) {
	            // 对每个NFA结点调用移进
                set<NfaNode*> nfaNodesOfNext = forward(next, symbol);
                // 所有结果合并到 nfaNodesOfSymbol，也就是转移后目标DFA状态的NFA状态合集
                nfaNodesOfSymbol.insert(nfaNodesOfNext.begin(), nfaNodesOfNext.end());
            }
            // 为空，则符号上没有转移，跳过
            if (nfaNodesOfSymbol.empty()) continue;
            
            // 判断是否新增
            DfaNode* instance = new DfaNode(nodes.size());
            instance->bindNfaNodes(nfaNodesOfSymbol);
            // 子集构造法
            // 遍历已有的DFA结点，通过operator==，比较是否已经存在过
            for (DfaNode* exist : nodes) {
	            //如果存在，则指向已有结点，不新增
	            //如果不存在，instance不变，仍指向新建的结点
                if (*exist == *instance) {
                    instance = exist;
                    break;
                }
            }
            
            //如果相等了，则说明没有匹配到已有结点，则加入DFA图
            
            if (instance->state == nodes.size()) { // 需要新增节点
                nodes.push_back(instance);
            }
            // 加入转移关系
            cur->transfers[symbol] = instance->state;
        }
    }
}
```


## 伪代码

```
void 生成DFA（）
	创捷Dfa结点数组
	创建初始Dfa结点
	将nfa结点的起始结点求ε闭包，绑定到初始Dfa结点
	将初始Dfa结点放入Dfa结点数组
	
	for（遍历Dfa结点数组）
		for（遍历所有符号）
			创建临时nfa结点集，用于存放那些读入当前符号转移到的nfa结点
			for（遍历当前Dfa结点的所有Nfa结点）
				对当前Nfa结点调用移进forward（）
				将生成的Nfa集中的nfa结点加入到临时nfa结点集
			if（临时nfa结点集为空）
				continue
			
			创建临时Dfa结点绑定临时nfa结点集，其状态==Dfa结点数组的大小
			for（遍历Dfa结点数组）
				if（临时Dfa结点与其中的一个相等了）
					那就把临时Dfa结点=这个结点
					break；循环结束
				
			if（临时结点的状态==Dfa结点数组的大小）//说明前面的循环没有找到相等的
				就把临时结点加入Dfa结点最后
			
			加入当前外循环的Dfa结点的转移关系
				
	
```