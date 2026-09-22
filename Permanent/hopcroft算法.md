---
date: 2026-07-05
tags:
  - 编译原理
cssclasses:
  - "[[词法分析的代码实现]]"
aliases:
---
用以解决[[词法分析#DFA化简]]

# 代码实现

## 数据结构

```C++
struct Node{//DFA节点
        int id;
        bool flag;//标记终态 
};

struct Edge{//DFA边 
        int to;
        char c;
};

char zfj[101];//字符集合
int zfnum;
vector<Node> V;//DFA_Vertex集
vector<Edge> edge[101];//DFA边集
int v,e;//顶点数和边数
int stateNum = 2;//默认分为终态和非终态
vector<int> eq;//等价状态集合
int p[101]; //记录状态所属集合 
```

## 具体代码
```C++
void split(int x,char c)
{
        int s = eq[x];
        int a[101]={0};//吃字符达到的状态
        int b[101]={0};//吃字符前的状态 
        int i,j,k;
        for(i = 0;i < v;i++){
                if((s>>i)&1){//遍历集合中的状态
                        for(j = 0;j < edge[i].size();j++){
                                if(edge[i][j].c == c){
                                        int v = edge[i][j].to;
                                        a[p[v]] |= (1<<v);
                                        b[p[v]] |= (1<<i);
                                }
                        }
                } 
        }
        int ll = stateNum;
        for(i = 0;i < ll;i++){
                if(b[i]==eq[x]) break;
                if(a[i] && i!=x){
                        eq.push_back(b[i]);
                        for(k = 0;k < v;k++)
                                if((b[i]>>k)&1)
                                p[k] = stateNum;
                        eq[x]&=(~b[i]);
                        stateNum++;
                }
        }
}
```

```C++
void Hopcroft()
{ 
        int N = 0,T = 0;
        for(int i = 0;i < v;i++){//分成N和T两个集合 
                if(V[i].flag){
                        T |= (1<<V[i].s);
                        p[V[i].s] = 1;
                }
                else{
                        N |= (1 << V[i].s);
                        p[V[i].s] = 0;
                }
        }
        if(N == 0) return ; 
        eq.push_back(N);
        eq.push_back(T);
        int i,j;
        int l;
        while(1){
                for(i = 0;i < zfnum;i++){
                        l = stateNum;
                        for(j = 0;j < l;j++)
                                split(j,zfj[i]); 
                }
                if(l==t) break;//集合大小不变算法结束 
        }        
}
for(int i = 0;i < v;i++)//合并边集 
    for(int j = 0;j < edge[i].size();j++) 
        Ed.insert(Edge_dfa(p[i],p[edge[i][j].to],edge[i][j].c));
```