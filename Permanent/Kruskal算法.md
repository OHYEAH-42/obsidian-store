---
date: 2026-06-25
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


# Kruskal算法

[图-最小生成树-Prim(普里姆)算法和Kruskal(克鲁斯卡尔)算法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1wG411z79G/?spm_id_from=333.337.search-card.all.click&vd_source=c227331cf783fe00078b3fe3d8d0b19c)

**贪心准则**：每次从**所有边**中选权值最小的边，且加入后**不构成回路**。

**伪代码**：

```
Kruskal(G):
    将 E 中边按权从小到大排序
    T ← ∅
    repeat:
        取最短边 e
        if e 的两端点不在同一连通分支:
            T ← T ∪ {e}
    until |T| = n-1
```

**详细算法**：

```
//Kruskal算法
void Kruskal()
{
	//遍历图，创建edges数组
	vector<Edge>edges;
	for (int i = 0; i < size; i++)
	{
		//无向图，每个边遍历一次计科
		for (int j = i+1; j < size; j++)
		{
			if (adjMat[i][j] != 0)
			{
				edges.push_back({ i,j,adjMat[i][j] });
			}
		}
	}

	//从小到大排序edges数组
	sort(edges.begin(), edges.end(), compare);

	//生成树的邻接表
	vector<vector<int>> tree(size);
	int cnt = 0;//记录已存入的边的数量

	//遍历edges数组，存放进树中
	for (Edge& e : edges)
	{
		//访问容器
		vector<bool>visited(size, 0);

		//如果成环，则跳过该条边
		if (dfs(e.point1, e.point2, tree, visited))
		{
			continue;
		}

		//不成环，则将这条边加入树中
		tree[e.point1].push_back(e.point2);
		tree[e.point2].push_back(e.point1);

		cout << "(" << e.point1 << "," << e.point2 << "," << e.value << ") ";

		//边为点的数量减1
		if (++cnt == size - 1)
		{
			break;
		}
	}
	cout << endl;
}
```


```
//Kruskal算法中成环的判断(dfs)
//u为当前生成树的节点，v为检索的节点
bool dfs(int u, int v, vector<vector<int>>& tree, vector<bool>& visited)
{
	//成环条件，在已有的生成树中能达到节点v；
	if (u == v)
	{
		return 1;
	}
	//已访问
	visited[u] = 1;

	//访问a节点
	for (int a : tree[u])
	{
		//没有访问过，则访问a节点相邻的节点
		if (!visited[a])
		{
			//如果符合成环条件，则一直返回true
			if (dfs(a, v, tree, visited))
			{
				return true;
			}
		}
	}
	return false;
}
```
**实例**：
![[Pasted image 20260625152116.png]]
![[Pasted image 20260625152413.png]]
**数据结构**：FIND 数组，FIND[i] 表示顶点 i 的连通分支标记。
- 初始：FIND[i] = i
- 合并：将较小分支的 FIND 值更新为较大分支的标记
- 每次 FIND 更新最多 O(log n)

**时间复杂度**：O(m log m)（边排序）+ O(n log n)（FIND维护）= **O(m log n)**