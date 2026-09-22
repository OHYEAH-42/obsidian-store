---
date: 2026-06-26
tags:
  - 算法
  - 编译原理
cssclasses:
  - "[[自底向上的语法分析]]"
aliases:
---
# 定义

**LR算法**（LR Parsing Algorithm）是一种[[自底向上的语法分析]]方法。它从左（L）到右扫描输入，并构造最右推导（R）的逆过程（即规范归约）。它是一种[[移进]]-[[归约]]（Shift-Reduce）解析器，具有强大的文法识别能力，能够处理几乎所有[[上下文无关文法]]。

# 动作 Action

| 操作     | 动作                                     | 触发条件                                      |
| :----- | :------------------------------------- | :---------------------------------------- |
| **移进** | 将当前输入符号（终结符）压入栈，并转移到下一个状态              | 当前栈顶状态 + 当前输入符号 在 Action 表中指示为 `s`（shift） |
| **归约** | 将栈顶的若干符号（句柄）弹出，用对应的非终结符替代，并根据该非终结符转移状态 | Action 表指示为 `r`（reduce），需要指定使用哪条产生式       |
| **接受** | 报告语法分析成功                               | 栈中仅剩起始符号 `S'`，且输入已读取完毕                    |
| **报错** | 报告语法错误                                 | 查表结果为空白或错误条目                              |

# LR分析表的结构

LR分析表由两部分组成，共同驱动分析过程：
- **ACTION 表**：行对应状态，列对应**终结符**（包括结束符 `$`）。指示当前动作（移进/归约/接受/报错）。
- **GOTO 表**：行对应状态，列对应**非终结符**。指示归约后转移到的下一个状态（类似 `goto` 操作）。

# 四种常见LR变体
| 变体                    | 构造复杂度         | 分析表大小            | 文法识别能力                                |
| :-------------------- | :------------ | :--------------- | :------------------------------------ |
| **[[LR(0)]]**         | 最简单           | 最小（无前瞻符）         | 最弱（几乎无法处理实际语言，冲突极多）                   |
| **[[SLR(1)]]**（简单LR）  | 较简单           | 较小               | 弱（通过 `FOLLOW` 集解决部分冲突）                |
| **[[LR(1)]]**（规范LR）   | **最复杂**（状态极多） | **极大**（状态数爆炸）    | **最强**（可处理所有确定性上下文无关文法）               |
| **[[LALR(1)]]**（前瞻LR） | 中等            | 与 SLR 同量级（合并同心项） | **接近 LR(1)**（**主流工具如 Yacc/Bison 使用**） |

# 算法实现

## 数据结构[[LR的数据结构]]

### Token
- 终结符类（string type），比如"id“,"+","int"
- 实际值

### TokenStream输入流（class类）
- Token数组（vector\<Token>Tokens）
- 当前指向Token（Token current()）
- 移动到下一个Token
- 判断是否为结尾


### 产生式（结构体）production
- **左（字符串或者整型）**
- **右产生式（string或int类型vector容器）**
- **右产生式长度**

### 文法规则（结构体）Grammer
- **产生式数组（vector\<production>）**
- 文法起始符号
- 终结符号个数（int）
- 非终结符号个数（int）
- 终结符号集合（set\<string>）
- 非终结符号集合 （set\<string>）
- 判断是否为非终结符号
看看需要什么就写上什么吧

### First和Follow集合

- 都是图  map<string, set\<string>> first;    
  
### 项目（结构体）Item

#### LR(0)和SLR(1)项   LR0Item   SLR1Item
- **产生式的序号（int，即文法规则中的第几条产生式）**
- **点的位置（int）**
- **项目小于判断函数**
- **项目相等判断函数（服务于状态（项集）set的构建）**

#### LR(1)项和LALR(1)项     LR1Item LALR1Item
- **产生式的序号（int，即文法规则中的第几条产生式）**
- **点的位置（int）**
- 前瞻符（set\<>）
- **项目小于判断函数**
- **项目相等判断函数（服务于状态（项集）set的构建）**

### 状态（set）  state

#### LR(0)状态和SLR(1)状态       
- 项目集合（set\<Item>）

#### LR(1)状态
- 项目集合（set）


### DFA

#### LR(0)和SLR(1)DFA
- 扩广文法  augProds（Grammer，第0个是 S' → S）
- 状态集合  states （set\<LR0state>）
- 转移表 trans  （ vector<map<string, int>>）
	vector下标表示状态，string表示输入的符号，int表示转移的状态

#### LR(1)DFA
- 扩广文法  augProds（Grammer，第0个是 S' → S）
- 状态集合  states （set\<LR1state>）
- 转移表 trans  （ vector<map<string, int>>）
	vector下标表示状态，string表示输入的符号，int表示转移的状态

#### LALR(1)DFA
- 扩广文法  augProds（Grammer，第0个是 S' → S）
- 状态集合  states （set\<LR1state>）
- 转移表 trans  （ vector<map<string, int>>）
	vector下标表示状态，string表示输入的符号，int表示转移的状态
- LR(1)状态映射表  LR1ToLALR1 (vector\<int>) 
	vector下标表示在LR(1)里的状态，int数据则表示LALR1里的状态，构建同心集、

### 分析表

- Action表 （vector\<map<string，string>>）
	下标为状态(行)，string为输入字符(列)，string为行为（s移进，r归约，acc接收）
- Goto表    （vector<map<string, int>>）
	下标为状态(行)，string为输入字符(列)，int为转移的状态

## 具体算法

### 功能性

#### Closure()[[项集的闭包]]
完善一个状态（即把·右边的非终结符号的产生式子都加进来）
这是LR(0)和SLR(1)的
```
Closure(状态state)
	状态temp=状态state
	bool状态temp发生变化=1
	
	while（状态temp发生变化）
		状态temp发生变化=0；
		for（。。。）遍历状态temp中的每一个项
			if     如果点后面为非终结符号
				for（遍历该非终结符号的所有产生式）
					每一条都加入到temp中
				状态temp发生变化=1
	
	return 状态temp

```

#### Closure1()
```
Closure(状态state)
	状态temp=状态state
	bool状态temp发生变化=1
	
	while（状态temp发生变化）
		状态temp发生变化=0；
		for（。。。）遍历状态temp中的每一个项
			if     如果点后面为非终结符号
				加上该非终结符号在左侧，点在最左侧的，以及对应的前瞻符，项到状态中
				状态temp发生变化=1
	
	return 状态temp
```

#### Goto()[[GOTO函数]]
返回指向的新状态
```
Goto(状态state I，string X)
	state temp
	
	for(I中的每个项目)
		if这个项目点后面是X
			temp+=该项目的点右移一位的版本
	
	return Closure(temp)
```


### [[LR系列DFA构建算法]]

首先先进行扩广文法，用closure来构建初始项目

然后广度优先遍历文法符号（终结符号和非终结符号）
寻找可以转移的项，并生成新状态（或指向这个状态）（Goto）
当不再有状态变化，则循环结束

```
buildDFA（Grammer g）

DFA result;

扩广文法
Item Item0
Item0.left = g[0].left+'       扩广文法就是第0项变成S‘->S 而已
Item0.right= g[0].left

result.augProds= Item0 + g     

构建初始项目,并写入DFA的状态集合
state I0 = {Item0}             创建初始项目
result.states={closure(I0)}    完善初始项目并写入状态集合中

广度优先创建DFA的其它状态
//可以利用队列循环
while（result.states发生变化）
	for(状态集states的每一个状态In)
		for（每一个文法符号X）
			state temp = Goto(In , X)  获得对应的新状态
			if(new不为空 && new不在result.states)   
				result.states[states.size+1]=temp      则把new加入到states中
			result.trans[n][X]= 状态的编号             记录转移表
```

感觉上面那个伪代码不好记，下面又写了一个

```
budildDFA(Grammer g)

	//初始化
	DFA result;创建DFA表

	初始化DFA表，把扩广文法的初始项放入DFA的状态0；
	闭包状态0，获得完全体状态0
	
	//广度优先遍历，创建DFA的其它状态
	whiel（DFA的状态集合发生变化）
		for（状态集的每一个状态）
			for(每一个文法符号)
				state temp=Goto()得到在这个状态遇到这个符号的时候，会前往的下一个状态temp
				if(temp不为空）
					if（DFA的状态集没有相同的状态)
						转正，加入DFA状态集
					记录到DFA的trans转移表格中
				
				//因为只要temp不为空，那就要记录转移表

```

### [[LR系列分析表构建算法]]

很简单，填好Action和Goto表就可以，一共4种情况：
Action 填入 s 移进
Action 填入 r 归约
Action 填入 acc 接受
Goto 填入 下一状态
其中，根据文法的不同，填入归约的判断条件也不一样
```
BuildTable（DFA dfa）

for(遍历dfa.states的每一个状态state In)
	for(遍历状态state In的每一个项目Item)
		if(Item不为ε表达式且点不在表达式最后面)
			Action[n][<点后面的符号X，s+dfa.trans[n][X]>]   移进的判断
		if(点在最后或者是ε表达式)
			if（这个项目的序号为0）
				Action[n][<"$"，acc>]                      接受
			else 
				LR(0)：   Action[n][<所有终结符+$，r+产生式序号>]        归约
				SLR(1):   Action[n][<Follow(产生式左部)，r+产生式序号>]
				LR(1):    Action[n][<前瞻符，r+产生式序号>]
				LALR(1):  与LR(1)相同

	for(遍历所有非终结符X)
		Goto[In][X]=dfa.trans[In][X]                         Goto填入下一状态 

```

### [[LR系列文法判断算法]]

#### 增加的函数：

##### 项目中：

**增加判断项目是移进项的函数**
```
if(如果点号不在产生式的最后&&点后面为终结符&&不为ε表达式)
则为移进项
```
增加判断项目是归约项的函数
```
if(如果点号在产生式最后||是ε表达式)
则为归约项
```
增加返回移进符号的函数
```
if (点不在末尾 && 不是 ε 产生式)
	return Grammar[prod].right[dot]
```

**状态中**

返回状态中所有的移进符号
```
vector<string> result

for(遍历状态中的项目)
	if(是移进项)
		添加到vector容器

返回vector容器
```

返回状态中归约项的序号

```
vector<<int,int>> result   （产生式序号，点的位置）

for(遍历状态中的项目)
	if(是归约项)
		添加项目信息到vector容器

返回vector容器
```
#### LR(0)判断

```
if(状态中有移进符号&&状态中归约序号容器不为空)
	则移进-归约冲突
if(状态中归约序号容器size>2)
	归约归约冲突
```

#### SLR(1)判断
```
bool isSLR1()

for(遍历所有状态)	
	
	收集该状态的所有移进符号

	//移进归约的判断
	for(遍历该状态的所有归约项目,产生式左部为A)
		if(是接受项)
			跳过
		
		for(遍历所有移进符号X)
			if(如果X属于FOLLOW(A))	
				则存在移进-归约冲突

	//归约归约的判断
	for(遍历该状态的所有归约项目,产生式左部为A)
		if(是接受项)
			跳过
		for(遍历该状态的所有归约项目,产生式左部为B)	
			if(是接受项|| 内外循环的归约项目相同)
				跳过
			for(遍历string a : FOLLOW(A))
				if(a 属于 FOLLOW(B))
					则存在归约-归约冲突
			
```

#### LR(1)的判断

```
bool isLR1(DFA1 dfa)
      for (每个状态 I ∈ dfa.states)
          // actions[符号] = 该符号上的动作集合
          map<符号, set<动作>> actions

          for (每个项目 [A→α·β, a] ∈ I)
              if (β ≠ ε 且 点不在末尾)            // 移进项目
                  X = β的第一个符号（点后面那个）
                  actions[X] += {"s"}
              else if (点是末尾 或 β=ε)            // 归约项目
                  if (A ≠ S')                      // 不是接受项
                      actions[a] += {"rⱼ"}         // 仅在前瞻符 a 上归约

          // 检查：任一符号上有多个动作 → 冲突
          for (每个符号 sym)
              if (actions[sym] 中动作数 > 1)
                  return false

      return true
```


#### LALR(1)的判断

因为合并同心集不会引入新的移进归约冲突，所以使用isLR1()判断一次即可
```
  bool isLALR1(DFA1 dfa1, DFAl lalr)
      // 不是 LR(1) 则不可能是 LALR(1)
	  // 这里检查了移进归约冲突
      if (!isLR1(dfa1))
          return false

      // 检查合并后的每个状态：只查归约-归约冲突
      for (每个合并后状态 I ∈ lalr.states)
          reduceAt[符号] = 该符号上可归约的产生式序号集合

          for (每个项目 [A→α·, a] ∈ I)
              if (A ≠ S')                    // 跳过接受项
                  reduceAt[a] += {产生式序号}

          for (每个符号 sym)
              if (reduceAt[sym] 中序号数 > 1)   // 同一符号有多个归约
                  return false

      return true
```
### [[LR系列分析器伪代码与实现]]

思路：
按照现有的分析表，一步一步执行即可，初始为状态0
双栈来存储输入的字符和状态
移进操作入栈，归约操作出栈

```
LRParser()

stackstate       //初始状态0 入栈
stackstr
vector input     // 记得在尾部加上结束符$
int ip            //指向input中的输入指针

//遍历输入字符串input(ip)
while(true)
	
	state=stackstate.top()     //获取当前状态
	
	if(Action[state][input[ip]]为空)
		报错
	
	str=Action[state][input[ip]]获得Action表对应的符号
	
	if(str[0]=s得到的是移进符号)
		把input[ip]入栈stackstr
		把str.substr(1)转移后的状态如栈stackstate
		ip++
		
	elif(str[0]=r是归约)
		从str.substr(1)得到产生式在Grammer语法中的序号
		获得右边式子的长度length
		获得产生式左边的非终结符
		
		//字符归约为非终结符
		从状态栈和字符栈中弹出等于length的元素个数
		再把产生式左部入栈
		
		//状态转移
		新状态=Goto[状态栈顶][字符栈顶(产生式左部在栈顶)]
		新状态入栈
		//ip不变哦
	
	elif(str=acc)
		分析成功
```

