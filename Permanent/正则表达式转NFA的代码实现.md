---
date: 2026-07-04
tags:
  - 编译原理
cssclasses:
  - "[[词法分析的代码实现]]"
aliases:
---
# 数据结构

## NFA的结点：
- 状态编号state，默认为0
- 是否为终结结点，默认为false
- 当前结点的转移关系transfers

**代码实现：**

```C++
struct NfaNode {
    int state = 0;
    bool isEnd = false;
    map<char, vector<NfaNode*>> transfers;
    
    NfaNode() : state(0) {}
    NfaNode(int state) : state(state) {}
    NfaNode(const NfaNode& node) : state(node.state), isEnd(node.isEnd), transfers(node.transfers) {}
};
```
因为一个NFA可以有多个转移关系，所以用map存储

## NFA图

一个[[NFA子图]]**只需保管其开始结点和终结检点**，后续的连结、或、闭包操作等都是基于一个或两个NFA子图来操作的，无非是对某NFA子图的start结点或end结点进行新增transfers操作。

同时，由于可能根据NFA子图生成新的NFA子图，参照[[Thompson算法]]，所以还需要再生成新子图时更新旧子图持有的NFA结点的state，也就是更新编号

```C++
struct NfaGraph {
    NfaNode* start;
    NfaNode* end;

    NfaGraph(NfaNode* start = 0, NfaNode* end = 0) : start(start), end(end) {}
    NfaGraph(const NfaGraph& graph) : start(graph.start), end(graph.end) {}

    // 更新节点状态
    //offset是上一个子图的end.state+1
    void updateState(int offset) {
        map<int, int> visited; // 已访问
        stack<NfaNode*> prepared; // 待遍历的栈
        vector<NfaNode*> ready; // 已遍历的结点
        prepared.push(start); // 加入起始结点
        while (prepared.size()) {
            NfaNode* cur = prepared.top();
            prepared.pop();
            visited[cur->state] = 1; // 标记已访问
            ready.push_back(cur);
            for (auto& p : cur->transfers)
                for (NfaNode* next : p.second)// 查看所有转移状态
                    if (!visited[next->state])
                        prepared.push(next); // 将未访问过的结点加入待遍历栈
        }
        // 执行更新
        for (NfaNode* node : ready)
            node->state += offset;
    }
};
```
updateState算法思路：
其目的是将子图2接到子图1后面，需要改变子图2的所有结点的state，传入的就是子图1的end.state+1，也就是子图1的结点总数（假设子图的start=0）。
1. 深度\广度优先搜索，遍历子图2的所有结点
2. 再把这所有结点的状态数字，加上子图1的总结点数

# 代码实现

## 从Symbol生成NFA子图

![[Pasted image 20260704160133.png]]

```C++
NfaGraph fromSymbol(char symbol) { // 根据Symbol生成Nfa子图
    NfaGraph graph(new NfaNode, new NfaNode(1));
    graph.end->isEnd = true;
    graph.start->transfers[symbol].push_back(graph.end);
    return graph;
}
```
没啥好说的最基本的
## 执行连续操作

![[Pasted image 20260704160250.png]]

```C++
NfaGraph setConcat(NfaGraph& t1, NfaGraph& t2) { // 连接Nfa子图
    NfaGraph graph;
    graph.start = t1.start;
    graph.end = t2.end;
    t1.end->isEnd = false;
    // 更新t2子图的结点编号
    t2.updateState(t1.end->state + 1);
    // 加入EPSILON转移
    t1.end->transfers[EPSILON].push_back(t2.start);
    return graph;
}
```
中间连结起来就行，改一改子图1的end的transfers
## 执行或`|`操作

![[Pasted image 20260704160345.png]]


```C++
NfaGraph setUnions(NfaGraph& t1, NfaGraph& t2) { // Nfa子图 或运算
    NfaGraph graph(new NfaNode, new NfaNode);
    graph.end->isEnd = true;
    // 更新子图t1、t2的结点编号
    t1.updateState(1); // t1编号整体+1（多了一个初始节点）
    t2.updateState(t1.end->state + 1); // t2编号整体+t1更新后的end编号+1
    graph.end->state = t2.end->state + 1;
    // 取消原有的终结结点
    t1.end->isEnd = false;
    t2.end->isEnd = false;
    // 加入EPSILON转移
    graph.start->transfers[EPSILON].push_back(t1.start);
    graph.start->transfers[EPSILON].push_back(t2.start);
    t1.end->transfers[EPSILON].push_back(graph.end);
    t2.end->transfers[EPSILON].push_back(graph.end);
    return graph;
}
```

## 执行闭包操作

![[Pasted image 20260704162418.png]]
```C++
NfaGraph setClosure(NfaGraph& target) { // Nfa子图闭包
    NfaGraph graph(new NfaNode, new NfaNode);
    graph.end->isEnd = true;
    // 更新子图target的结点编号
    target.updateState(1);
    graph.end->state = target.end->state + 1;
    // 取消原有终结结点
    target.end->isEnd = false;
    // 加入EPSILON转移
    graph.start->transfers[EPSILON].push_back(target.start);
    graph.start->transfers[EPSILON].push_back(graph.end);
    target.end->transfers[EPSILON].push_back(target.start);
    target.end->transfers[EPSILON].push_back(graph.end);
    return graph;
}
```

## 根据不同的OP，对子图执行不同的操作

- 闭包：单目运算
- 其他：双目运算
接收参数`op`和当前已有的子图栈`subgraphs`，从栈里pop出相应个数的子图，对其施加相应OP的操作，再将结果push回子图栈。

```C++
void setAction(char op, stack<NfaGraph>& subgraphs) {
    NfaGraph result; // 执行结果
    if (op == CLOSURE) {
        // 单目运算
        NfaGraph& target = subgraphs.top();
        subgraphs.pop();
        result = setClosure(target);
    }
    else {
        // 双目运算符
        // 就是连接操作或者 | 操作
        NfaGraph& t2 = subgraphs.top();
        subgraphs.pop();
        NfaGraph& t1 = subgraphs.top();
        subgraphs.pop();
        if (op == CONCAT) result = setConcat(t1, t2);
        else result = setUnion(t1, t2);
    }
    // 压入结果栈
    subgraphs.push(result);
}
```

## 生成顶层NFA图

其实就是一个扫描输入字符，然后逐一新增NFA子图，根据OP对子图栈里的子图不断操作直到栈中只剩下一个NFA子图的过程。（类似于算术表达式的算法）

归纳为几个点：
1. 初始化两个栈：**操作符栈**和**子图栈**
2. 对输入的字符串预处理，**加入显式的连接符**。（比如`ab`转化为`a.b`）
3. 对于预处理后的每一个字符：
    1. 左括号：压入操作符栈，扫描下一个字符；
    2. 右括号：将操作符栈的上一个左括号前的所有操作都清空，扫描下一个字符；
    3. 操作符：将操作符栈中已有的且**优先级比当前扫描到的操作符高**的操作符清空，遇到优先级比自己低的才停下，然后将自己压入操作符栈，扫描下一个字符；
    4. 普通符号：根据这个Symbol**生成NFA子图**，**压入子图栈**中，同时加入Symbols的统计中（这样才能统计出所有转移字符）
4. 扫描完预处理字符串后，清空符号栈
5. 获取到子图栈中的唯一子图，就是所生成的最终的NFA图

这里符号栈的“**清空**”操作意味着：从符号栈里弹出，调用`setAction`方法完成对NFA子图的操作。

```C++
// 生成顶层NFA图
void generate(string input) {
    string prepared = ""; // 预处理后的输入字符串
    stack<char> ops; // 操作符号栈
    stack<NfaGraph> subgraphs; // 子图栈
    
    for (int i = 0; i < input.size(); ++i) { // 预处理输入字符串（加入CONCAT字符）
        char id = input[i];
        if (skip(id)) continue; // 跳过无意义字符
        prepared.push_back(id);
        
        // 判断是否需要插入连接符
        if (i + 1 < input.size()) {
	        char next = input[i + 1];
	        // id 是操作数/右括号/闭包 且 next 是操作数/左括号 → 需要连接
	        if ((isalnum(id) || id == ')' || id == '*' || id == '+') &&
              (isalnum(next) || next == '(')) {
              prepared.push_back(CONCAT);
          }
      }
    }
    
    //开始生成NFA
    for (int i = 0; i < prepared.size(); ++i) {
        char id = prepared[i]; // 当前Identifier
		
		// 匹配左括号入栈
        if (id == LBRACKET) { // 左括号
            ops.push(id); // 入符号栈
            continue;
        }
        
        // 匹配右括号，符号栈出栈，直到匹配到左括号
        if (id == RBRACKET) { // 右括号
            while (ops.size()) { // 清空和其最近匹配的左括号内的所有操作
                char op = ops.top();
                ops.pop();
                if (op == LBRACKET) break; // 匹配到左括号，退出
                setAction(op, subgraphs); // 执行操作
            }
            continue;
        }
        
        // 匹配其它运算符
        if (reservedSymbol(id)) { // 保留字符（运算符）
            while (ops.size()) { // 清空符号栈里优先级比当前高的运算
                char op = ops.top();
                if (privilege(id) > privilege(op)) break; // 优先级没当前读取的操作符高
                ops.pop(); // 优先级较高，出栈并执行
                setAction(op, subgraphs); // 执行操作
            }
            ops.push(id); // 将当前OP压入栈
            continue;
        }
        
        // 普通Symbol，生成子图
        NfaGraph subgraph = fromSymbol(id);
        subgraphs.push(subgraph);
        symbols.insert(id); // 加入Symbol统计中
    }
    
    // 清空符号栈
    while (ops.size()) {
        char op = ops.top();
        ops.pop();
        setAction(op, subgraphs);
    }
    this->graph = subgraphs.top(); // 栈顶就是顶层NFA图
}
```

### 伪代码

```
void 生成NFA图（输入的字符串）
	string prepared = “”  预处理后的字符串
	创建符号栈
	创建子图栈
	// -------------第一步，预处理字符串，也就是加上链接
	for（遍历输入的字符串）
		if（当前字符为空）
			continue；跳过
		把当前字符放进预处理后的字符串
		if（当前字符是操作数/右括号/闭包符号*）且（下一个字符是操作数/左括号）
			把CONCAT连接符号加到预处理后的字符串
	// -------------第二步，开始处理预处理的字符串
	for（遍历预处理字符串）
		if（当前符号是左括号）
			入符号栈
			continue；
		if（当前符号是右括号）
			while（符号栈大小）
				出栈
				if（出的是左括号）
					break；
				调用setAction（当前符号，子图栈）
			continue
		if（其它运算符）
			while（符号栈大小）
				if（栈顶符号优先级低）
					break；
				else（栈顶符号优先级高）
					出栈，调用setAction（）
			把当前op入栈
			continue
		//普通Symbol
		生成子图
		放入栈
	// -------------第三步，清空符号栈，直到子图栈只剩下一个图
	while（符号栈大小）
		出栈，调用setAction
		
	循环结束，栈顶就是NFA图
```

可以注意到这里对正则表达式的分析，是基于正则表达式为 E=a | b 这种，一个符号一个含义。
但对于digit= 0 | 1 | .... | 9 这种就无能无力了。

## 非单字符的符号NFA生成

### 问题分析

当前的 `generate()` 是**字符级**扫描，遇到 `digit` 会拆成 `d·i·g·i·t` 五个符号处理，无法将其视为一个整体。

解决思路：在预处理前加一层**词法分析（tokenize）**，先把输入拆成 token 序列，再在 token 级别做 NFA 构建。

### 1. 定义命名符号

```C++
// 命名符号 -> 字符集
// 可根据需要自由扩展
map<string, set<char>> initNamedSymbols() {
    map<string, set<char>> symbols;

    set<char> digits;
    for (char c = '0'; c <= '9'; ++c) digits.insert(c);
    symbols["digit"] = digits;

    set<char> hexDigits;
    for (char c = '0'; c <= '9'; ++c) hexDigits.insert(c);
    for (char c = 'a'; c <= 'f'; ++c) hexDigits.insert(c);
    for (char c = 'A'; c <= 'F'; ++c) hexDigits.insert(c);
    symbols["hex"] = hexDigits;

    set<char> alpha;
    for (char c = 'a'; c <= 'z'; ++c) alpha.insert(c);
    for (char c = 'A'; c <= 'Z'; ++c) alpha.insert(c);
    symbols["alpha"] = alpha;

    return symbols;
}

static map<string, set<char>> namedSymbols = initNamedSymbols();
```

### 2. 从字符集生成 NFA 子图

```C++
// 直接生成扁平 NFA：start 有 n 条转移边分别指向 end
// 例如 digit →  start --'0'--> end, start --'1'--> end, ..., start --'9'--> end
// 相比用 setUnion 逐个合并，这种方法产生的 NFA 层级更浅、更高效
NfaGraph fromCharClass(const set<char>& charset) {
    NfaGraph graph(new NfaNode, new NfaNode(1));
    graph.end->isEnd = true;
    for (char c : charset) {
        graph.start->transfers[c].push_back(graph.end);
    }
    return graph;
}
```

如果 charset 为空，则返回一个无转移边的 NFA（只匹配空串的结点）。

### 3. 词法分析器

```C++
// 将输入字符串拆分为 token 序列
// 每条规则：
//   1. 跳过无意义字符
//   2. 尝试匹配最长的命名符号（如 digit）
//   3. 否则按单字符处理
vector<string> tokenize(const string& input) {
    vector<string> tokens;
    int i = 0;
    while (i < input.size()) {
        if (skip(input[i])) { ++i; continue; }

        // 尝试匹配命名符号（最长匹配）
        bool found = false;
        for (auto& [name, _] : namedSymbols) {
            if (i + name.size() <= input.size() &&
                input.substr(i, name.size()) == name) {
                tokens.push_back(name);
                i += name.size();
                found = true;
                break;
            }
        }
        if (found) continue;

        // 普通单字符
        tokens.push_back(string(1, input[i]));
        ++i;
    }
    return tokens;
}
```

### 4. 集成到 generate 流程

将原有的 `generate` 改造为 token 级别处理：

```C++
void generate(string input) {
    // ====== 第一步：词法分析 ======
    vector<string> tokens = tokenize(input);

    // ====== 第二步：预处理，在 token 间插入 CONCAT ======
    vector<string> prepared;
    for (int i = 0; i < tokens.size(); ++i) {
        prepared.push_back(tokens[i]);

        if (i + 1 >= tokens.size()) continue;
        string& cur = tokens[i];
        string& next = tokens[i + 1];

        // 判断当前 token 是否属于"操作数类"
        bool curIsOperand = cur == ")"
                         || (cur.size() == 1 && (cur[0] == '*' || cur[0] == '+'))
                         || (cur.size() == 1 && isalnum(cur[0]))
                         || namedSymbols.count(cur) > 0;

        // 判断下一个 token 是否属于"操作数类"
        bool nextIsOperand = next == "("
                          || (next.size() == 1 && isalnum(next[0]))
                          || namedSymbols.count(next) > 0;

        if (curIsOperand && nextIsOperand) {
            prepared.push_back(string(1, CONCAT));
        }
    }

    // ====== 第三步：NFA 构建 ======
    stack<char> ops;           // 操作符栈
    stack<NfaGraph> subgraphs; // 子图栈

    for (int i = 0; i < prepared.size(); ++i) {
        string& token = prepared[i];

        // 单字符 token —— 可能是运算符或括号
        if (token.size() == 1) {
            char c = token[0];

            if (c == LBRACKET) {           // 左括号
                ops.push(c);
                continue;
            }
            if (c == RBRACKET) {           // 右括号
                while (ops.size()) {
                    char op = ops.top();
                    ops.pop();
                    if (op == LBRACKET) break;
                    setAction(op, subgraphs);
                }
                continue;
            }
            if (reservedSymbol(c)) {       // 运算符
                while (ops.size()) {
                    char op = ops.top();
                    if (privilege(c) > privilege(op)) break;
                    ops.pop();
                    setAction(op, subgraphs);
                }
                ops.push(c);
                continue;
            }
        }

        // ---------- 到这里，token 一定是普通符号 ----------
        NfaGraph subgraph;

        if (token.size() == 1 && isalnum(token[0])) {
            // 单字符符号（原有逻辑）
            subgraph = fromSymbol(token[0]);
            symbols.insert(token[0]);
        }
        else if (namedSymbols.count(token)) {
            // 命名符号（新增）
            subgraph = fromCharClass(namedSymbols[token]);
            // 将命名符号展开后的所有字符加入符号统计
            for (char c : namedSymbols[token]) {
                symbols.insert(c);
            }
        }

        subgraphs.push(subgraph);
    }

    // ====== 第四步：清空操作符栈 ======
    while (ops.size()) {
        char op = ops.top();
        ops.pop();
        setAction(op, subgraphs);
    }

    this->graph = subgraphs.top(); // 栈顶即为最终的 NFA 图
}
```

### 效果对比

| 输入 | 改造前 | 改造后 |
|------|--------|--------|
| `digit` | 拆成 `d·i·g·i·t` 五个 NFA 串联 | 一个 NFA，`start` 有 10 条转移边指向 `end` |
| `digit\|ab` | `d·i·g·i·t\|a·b` | 正确识别为 `(0\|1\|...\|9)\|a·b` |
| `digit*` | `d·i·g·i·t*`（`*` 只作用于 `t`） | `(0\|1\|...\|9)*` |

### 扩展方式

想添加新的命名符号，只需在 `initNamedSymbols()` 中追加：

```C++
set<char> vowels;
vowels.insert('a'); vowels.insert('e');
vowels.insert('i'); vowels.insert('o'); vowels.insert('u');
symbols["vowel"] = vowels;
```

然后 `vowel*`、`vowel|digit` 等就能正确识别。

