---
date: 2026-06-15
tags:
  - 算法
cssclasses:
  - "[[贪心算法]]"
  - "[[最小生成树]]"
aliases:
---
# 问题

**问题**：无向带权连通图 $G=\langle V,E,W\rangle$，求一棵包含所有顶点的生成树，使边权之和最小。

**应用**：$n$ 个城市的通讯网络建设，求最小总代价。

# Prim算法

[图-最小生成树-Prim(普里姆)算法和Kruskal(克鲁斯卡尔)算法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1wG411z79G/?spm_id_from=333.337.search-card.all.click&vd_source=c227331cf783fe00078b3fe3d8d0b19c)

**贪心准则**：每次选中一条连接"已选顶点集X"和"未选顶点集Y"的**权值最小**的边。

```
Prim(G):
    X ← {1};   T ← ∅
    while V - X ≠ ∅:
        选 j ∈ V-X 使得 j 到 X 中某点的边 e 权值最小
        X ← X ∪ {j};   T ← T ∪ {e}
```

```
//Prim算法
void Prim()
{
	//存放索引值点到已生成树节点的最短距离
	vector<int>key(size, INF);
	//存放索引值点是否在生成树内
	vector<bool>inTree(size, 0);
	//存放生成树中索引值点连接的上一个点
	vector<int>parent(size, -1);

	//设置0号节点的key值为0，则每次都会先从0号节点开始
	key[0] = 0;

	//循环size次存放节点
	for (int i = 0; i < size; i++)
	{
		//标记本次遍历得到的节点
		int u = -1;
		//标记本次遍历得到的最小key
		int minKey = INF;

		//每次循环，寻找到树最短的节点，存放入Tree中
		for (int v = 0; v < size; v++)
		{
			if (!inTree[v] && key[v] < minKey)
			{
				minKey = key[v];
				u = v;
			}
		}

		inTree[u] = 1;

		//接入新节点后，遍历新节点相邻的节点，更新key值
		for (int v = 0; v < size; v++)
		{
			//如果u到v的距离比之前记录v到树的距离短，则更新
			if (adjMat[u][v] != 0 && !inTree[v] && adjMat[u][v] < key[v])
			{
				key[v] = adjMat[u][v];
				parent[v] = u;
			}
		}
	}
}
```

**实例**：
![[Pasted image 20260625152116.png]]
![[Pasted image 20260625152413.png]]
Prim算法从a开始，依次选最小横切边：
```
初始: X={a}, Y={b,c,d,e,f}
选 (a,c) 权1 → X={a,c}
选 (c,f) 权4 → X={a,c,f}
选 (f,d) 权2 → X={a,c,f,d}
选 (c,b) 权5 → X={a,c,f,d,b}
选 (b,e) 权3 → X={a,c,f,d,b,e}
总权 = 1+4+2+5+3= 15
```

**时间复杂度**：$\Theta(n^2)$

**正确性证明**：对 T 的大小归纳，(X, T) 始终保持是最小生成树的子树。