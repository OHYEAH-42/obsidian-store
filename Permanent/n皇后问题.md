---
date: 2026-06-26
tags:
  - 算法
cssclasses:
  - "[[回溯算法]]"
---
# 问题

根据国际象棋的规则，皇后可以攻击与同处一行、一列或一条斜线上的棋子。给定𝑛个皇后和一个
$n*n$大小的棋盘，寻找使得所有皇后之间无法相互攻击的摆放方案。

![[Pasted image 20260628215643.png]]

比如这个4\*4的棋盘，就有以上两个解法

## 回溯算法

### 问题分析

![[Pasted image 20260628215748.png]]

图中展示了本题的三个约束条件：**多个皇后不能在同一行，同一列，同一条对角线上**

很容易得出一个结论：**每一行只能放置一个皇后**

## 逐行放置

![[Pasted image 20260628220124.png]]

逐行放置策略起到了剪枝的作用，在代码上也容易实现。

### 列与对角线剪枝

如何实现剪枝？我们可以设定坐标（x，y），当有两个皇后的x坐标或者y坐标相等，则不满足。触发剪枝

那对角线呢？对角线可以利用x+y和x-y的值判断，如果两个皇后x+y或x-y的值相等，则说明它们在对角线上，触发剪枝


| 0,0 | 0,1 | 0,2 | 0,3 |
| --- | --- | --- | --- |
| 1,0 | 1,1 | 1,2 | 1,3 |
| 2,0 | 2,1 | 2,2 | 2,3 |
| 3,0 | 3,1 | 3,2 | 3,3 |

计算每一个坐标的x+y，可以见到在同一方向的对角线，x+y的值相等

| 0   | 1   | 2   | 3   |
| --- | --- | --- | --- |
| 1   | 2   | 3   | 4   |
| 2   | 3   | 4   | 5   |
| 3   | 4   | 5   | 6   |
计算x-y的值，另一方向的对角线满足相等

| 0   | -1  | -2  | -3  |
| --- | --- | --- | --- |
| 1   | 0   | -1  | -2  |
| 2   | 1   | 0   | -2  |
| 3   | 2   | 1   | 0   |

由此，我们可以利用一个二维数组存储x，y的信息，利用4个数组，记录哪个x坐标，y坐标，主对角线，次对角线上存在皇后


## 代码

```
/* 回溯算法：n 皇后 */
↪
void backtrack(int row, int n, vector<vector<string>> &state, vector<vector<vector<string>>> &res,
vector<bool> &cols,
vector<bool> &diags1, vector<bool> &diags2) {
	// 当放置完所有行时，记录解
	if (row == n) {
		res.push_back(state);
		return;
	}
	// 遍历所有列
	for (int col = 0; col < n; col++) {
		// 计算该格子对应的主对角线和次对角线
		int diag1 = row- col + n- 1;
		int diag2 = row + col;
		// 剪枝：不允许该格子所在列、主对角线、次对角线上存在皇后
		if (!cols[col] && !diags1[diag1] && !diags2[diag2]) {
			// 尝试：将皇后放置在该格子
			state[row][col] = "Q";
			cols[col] = diags1[diag1] = diags2[diag2] = true;
			// 放置下一行
			backtrack(row + 1, n, state, res, cols, diags1, diags2);
			// 回退：将该格子恢复为空位
			state[row][col] = "#";
			cols[col] = diags1[diag1] = diags2[diag2] = false;
		}
	}
}

/* 求解 n 皇后 */
vector<vector<vector<string>>> nQueens(int n) {
	// 初始化 n*n 大小的棋盘，其中 'Q' 代表皇后，'#' 代表空位
	vector<vector<string>> state(n, vector<string>(n, "#"));
	vector<bool> cols(n, false);
	// 记录列是否有皇后
	vector<bool> diags1(2 * n- 1, false); // 记录主对角线上是否有皇后
	vector<bool> diags2(2 * n- 1, false); // 记录次对角线上是否有皇后
	vector<vector<vector<string>>> res;
	backtrack(0, n, state, res, cols, diags1, diags2);
	return res;
}
```