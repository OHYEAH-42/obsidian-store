---
date: 2026-06-25
tags:
  - 算法
cssclasses:
  - "[[贪心算法]]"
  - "[[最短路径算法]]"
aliases:
  - Dijkstra（迪杰斯特拉）
---
# 问题

**问题**：带权有向图 $G=\langle V,E,W\rangle$，边权非负，求从源点 s 到所有其他点的最短路径。

# Dijkstra算法（贪心法）

**贪心准则**：按从源点 s 到各点**最短路径长度由小到大**的顺序，依次构造。

**核心概念**：
- **S**：已确定最短路径的顶点集合（初始 S = {s}）
- **dist\[u]**：从 s 到 u、**仅经过 S 中顶点**的最短路径长度（$\geq$ 真正的最短路径 short\[u]）
- 当 u 被移入 S 时：dist\[u] = short\[u]

```
Dijkstra(G, s):
    S ← {s};  dist[s] ← 0
    for i ∈ V-{s}: dist[i] ← w(s,i)  // 无边的为∞
    while V-S ≠ ∅:
        取 j ∈ V-S 中 dist 值最小的点
        S ← S ∪ {j}
        for 每个 i ∈ V-S:
            if dist[j] + w(j,i) < dist[i]:
                dist[i] ← dist[j] + w(j,i)    // 松弛操作
```

**详细代码**;

```
//Dijkstra算法求最短距离
vector<int> Dijkstra(int start)
{
	//start到index的最短路径
	vector<int> dist(size, INF);
	//已经得到最短路径
	vector<bool>visited(size, 0);

	dist[start] = 0;

	for (int i = 0; i < size; i++)
	{
		//先找未访问点中距离最短的
		int index1 = -1;//index1存储距离最短的节点的索引
		int minDist = INF;//minDist存储目前找到的最短的距离
		for (int j = 0; j < size; j++)
		{
			if (!visited[j] && dist[j] < minDist)
			{
				minDist = dist[j];
				index1 = j;
			}
		}

		//index1没有变化，即不存在比INF更小的节点了，则退出循环
		if (index1 == -1)
		{
			break;
		}

		//标记为已访问
		visited[index1] = 1;

		//更新dist数组，更新每一个节点到已访问节点的最短距离
		for (int index2 = 0; index2 < size; index2++)
		{
			if (!visited[index2] && graph[index1][index2] < INF)
			{
				if (dist[index1] + graph[index1][index2] < dist[index2])
				{
					dist[index2] = dist[index1] + graph[index1][index2];
				}
			}
		}
	}

	return dist;
}
```
