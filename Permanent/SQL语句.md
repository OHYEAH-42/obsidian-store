# SQL 语句 — 考试重点笔记

## 考试用数据库表结构

```
S(SNO, SNAME, STATUS, CITY)        -- 供应商表
P(PNO, PNAME, COLOR, WEIGHT, CITY) -- 零件表
J(JNO, JNAME, CITY)                -- 工程表
SPJ(SNO, PNO, JNO, QTY)            -- 供应关系表
```

---

## 一、数据定义（DDL）

### 1. CREATE TABLE — 建表

```sql
CREATE TABLE S (
    SNO    CHAR(5)      PRIMARY KEY,     -- 主键
    SNAME  VARCHAR(20)  NOT NULL,         -- 非空
    STATUS INT          DEFAULT 10,       -- 默认值
    CITY   VARCHAR(10)
);

CREATE TABLE P (
    PNO    CHAR(5)      PRIMARY KEY,
    PNAME  VARCHAR(20)  NOT NULL,
    COLOR  VARCHAR(10),
    WEIGHT INT,
    CITY   VARCHAR(10)
);

CREATE TABLE J (
    JNO    CHAR(5)      PRIMARY KEY,
    JNAME  VARCHAR(20)  NOT NULL,
    CITY   VARCHAR(10)
);

CREATE TABLE SPJ (
    SNO    CHAR(5),
    PNO    CHAR(5),
    JNO    CHAR(5),
    QTY    INT,
    PRIMARY KEY (SNO, PNO, JNO),              -- 联合主键
    FOREIGN KEY (SNO) REFERENCES S(SNO),       -- 外键
    FOREIGN KEY (PNO) REFERENCES P(PNO),
    FOREIGN KEY (JNO) REFERENCES J(JNO)
);
```

> ⚠ **考试重点**：
> - `PRIMARY KEY` — 主键约束（唯一 + 非空）
> - `FOREIGN KEY ... REFERENCES` — 外键约束（参照完整性）
> - `NOT NULL` / `DEFAULT` / `UNIQUE` / `CHECK` — 其他常见约束
> - 联合主键定义在表级：`PRIMARY KEY (列1, 列2)`

#### 约束（Constraints）汇总

| 约束 | 作用 | 示例 |
|------|------|------|
| `PRIMARY KEY` | 主键，唯一标识一行 | `SNO CHAR(5) PRIMARY KEY` |
| `FOREIGN KEY` | 外键，引用另一张表 | `FOREIGN KEY (SNO) REFERENCES S(SNO)` |
| `NOT NULL` | 不允许为空 | `SNAME VARCHAR(20) NOT NULL` |
| `UNIQUE` | 值唯一（允许一个 NULL） | `CARD_ID CHAR(18) UNIQUE` |
| `DEFAULT` | 设置默认值 | `STATUS INT DEFAULT 10` |
| `CHECK` | 值满足条件 | `QTY INT CHECK (QTY > 0)` |

#### 表级 vs 列级约束

```sql
-- 列级（简写，单个列）
CREATE TABLE T (ID CHAR(5) PRIMARY KEY);

-- 表级（复合主键、多列约束）
CREATE TABLE T (
    A CHAR(5),
    B CHAR(5),
    PRIMARY KEY (A, B),
    FOREIGN KEY (A) REFERENCES S(SNO)
);
```

### 2. ALTER TABLE — 修改表结构

```sql
-- 添加列
ALTER TABLE S ADD TEL VARCHAR(15);

-- 修改列类型
ALTER TABLE S MODIFY SNAME VARCHAR(30);     -- Oracle / MySQL
ALTER TABLE S ALTER COLUMN SNAME VARCHAR(30); -- SQL Server

-- 添加约束
ALTER TABLE S ADD PRIMARY KEY (SNO);
ALTER TABLE SPJ ADD FOREIGN KEY (SNO) REFERENCES S(SNO);

-- 删除列
ALTER TABLE S DROP COLUMN TEL;
```

### 3. DROP TABLE — 删表

```sql
DROP TABLE S;           -- 删除表（结构+数据全删）
DROP TABLE S CASCADE;   -- 级联删除（关联对象一并删）
```

### 4. CREATE VIEW — 建视图（虚表）

视图是**保存的 SELECT 语句**，不存数据，只存定义。

```sql
-- 创建视图
CREATE VIEW 北京供应商 AS
SELECT SNO, SNAME, STATUS
FROM S
WHERE CITY = '北京';

-- 创建带列别名的视图
CREATE VIEW 供应统计(JNO, 零件总数) AS
SELECT JNO, SUM(QTY)
FROM SPJ
GROUP BY JNO;

-- 视图查询（与表一样使用）
SELECT * FROM 北京供应商 WHERE STATUS > 20;

-- 删除视图
DROP VIEW 北京供应商;
```

> ⚠ **考试重点**：
> - 视图是**虚表**，不占存储空间
> - 视图的数据随基表变化自动更新
> - 对视图中数据的修改（INSERT/UPDATE/DELETE）会反映到基表（有**限制**：视图必须基于单表、不含聚合函数、不含 DISTINCT 等）
> - 视图的作用：简化查询、安全控制、逻辑独立性

---

## 二、数据查询 — SELECT（绝对重点）

### 1. 基本 SELECT 结构

```sql
SELECT [DISTINCT] 列名 | 表达式 | 聚合函数
FROM 表名 [别名]
[WHERE 行条件]
[GROUP BY 分组列]
[HAVING 组条件]
[ORDER BY 排序列 [ASC|DESC]];
```

> ⚠ **执行顺序**（考试常考）：
> `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`

### 2. WHERE 行条件过滤

| 运算符 | 说明 | 示例 |
|--------|------|------|
| `=` / `!=` (`<>`) | 等于 / 不等于 | `WHERE CITY = '北京'` |
| `>` / `<` / `>=` / `<=` | 比较 | `WHERE QTY > 100` |
| `AND` / `OR` | 且 / 或 | `WHERE CITY='北京' AND STATUS>10` |
| `IN` / `NOT IN` | 属于集合 | `WHERE CITY IN ('北京','上海')` |
| `BETWEEN a AND b` | 在区间内（含边界） | `WHERE QTY BETWEEN 100 AND 500` |
| `LIKE` | 模式匹配 | `WHERE SNAME LIKE '%厂'` |
| `IS NULL` / `IS NOT NULL` | 判空 | `WHERE STATUS IS NULL` |

**LIKE 通配符**：
- `%` — 任意长度任意字符（含 0 个）
- `_` — 单个任意字符

```sql
-- 名字以"厂"结尾
WHERE SNAME LIKE '%厂';
-- 名字第二个字是"力"
WHERE SNAME LIKE '_力%';
```

### 3. DISTINCT — 去重

```sql
SELECT DISTINCT CITY FROM S;
```

### 4. ORDER BY — 排序

```sql
SELECT SNO, SNAME, STATUS FROM S
ORDER BY STATUS DESC;          -- 降序

SELECT * FROM SPJ
ORDER BY JNO ASC, QTY DESC;    -- 先按 JNO 升序，再按 QTY 降序
```

### 5. 聚合函数 + GROUP BY + HAVING

#### 聚合函数

| 函数 | 作用 |
|------|------|
| `COUNT(*)` | 统计行数（含 NULL） |
| `COUNT(列)` | 统计该列非空值个数 |
| `COUNT(DISTINCT 列)` | 统计该列非空不重复值个数 |
| `SUM(列)` | 求和（忽略 NULL） |
| `AVG(列)` | 求平均（忽略 NULL） |
| `MAX(列)` | 最大值 |
| `MIN(列)` | 最小值 |

#### GROUP BY — 分组

```sql
-- 每个工程的总用量
SELECT JNO, SUM(QTY) AS 总用量
FROM SPJ
GROUP BY JNO;

-- 每个城市供应商的数量
SELECT CITY, COUNT(*) AS 供应商数
FROM S
GROUP BY CITY;
```

> ⚠ **规则**：SELECT 子句中出现的非聚合列**必须**在 GROUP BY 中

```sql
-- ❌ 错误
SELECT SNAME, CITY, COUNT(*) FROM S GROUP BY CITY;

-- ✅ 正确
SELECT CITY, COUNT(*) FROM S GROUP BY CITY;
```

#### HAVING — 组条件过滤

`WHERE` 过滤行，`HAVING` 过滤组。

```sql
-- 总用量大于 1000 的工程
SELECT JNO, SUM(QTY) AS 总用量
FROM SPJ
GROUP BY JNO
HAVING SUM(QTY) > 1000;

-- 供应商数大于 2 的城市
SELECT CITY, COUNT(*) AS 供应商数
FROM S
GROUP BY CITY
HAVING COUNT(*) > 2;
```

### 6. 多表连接查询

#### 连接分类

| 连接类型 | 说明 |
|----------|------|
| `INNER JOIN` / `JOIN` | 内连接，只返回匹配的行 |
| `LEFT JOIN` / `LEFT OUTER JOIN` | 左外连接，保留左表全部行 |
| `RIGHT JOIN` / `RIGHT OUTER JOIN` | 右外连接，保留右表全部行 |
| `FULL JOIN` / `FULL OUTER JOIN` | 全外连接，保留两表全部行 |
| `CROSS JOIN` | 叉积（笛卡尔积） |

#### 内连接

```sql
-- 隐式连接（逗号连接）
SELECT S.SNAME, P.PNAME, SPJ.QTY
FROM S, P, SPJ
WHERE S.SNO = SPJ.SNO AND P.PNO = SPJ.PNO;

-- 显式 JOIN（推荐）
SELECT S.SNAME, P.PNAME, SPJ.QTY
FROM SPJ
JOIN S ON SPJ.SNO = S.SNO
JOIN P ON SPJ.PNO = P.PNO;
```

#### 外连接

```sql
-- 左外连接：返回所有供应商，即使他没有供货记录
SELECT S.SNAME, SPJ.JNO, SPJ.QTY
FROM S
LEFT JOIN SPJ ON S.SNO = SPJ.SNO;
```

### 7. 子查询

子查询是**嵌套在另一个 SQL 语句内部的 SELECT 语句**，分三类：

#### 标量子查询（返回单个值）

```sql
-- 查询状态高于平均状态的供应商
SELECT SNO, SNAME, STATUS
FROM S
WHERE STATUS > (SELECT AVG(STATUS) FROM S);
```

#### 行子查询（返回一列多行）

```sql
-- IN：属于
SELECT SNAME FROM S
WHERE SNO IN (
    SELECT SNO FROM SPJ WHERE JNO = 'J1'
);

-- ANY / ALL
SELECT SNO, SNAME, STATUS
FROM S
WHERE STATUS > ANY (SELECT STATUS FROM S WHERE CITY = '北京');
-- > ANY 相当于大于最小值

SELECT SNO, SNAME, STATUS
FROM S
WHERE STATUS > ALL (SELECT STATUS FROM S WHERE CITY = '北京');
-- > ALL 相当于大于最大值
```

#### 表子查询（FROM 子句中）

```sql
SELECT T.JNO, T.总用量
FROM (
    SELECT JNO, SUM(QTY) AS 总用量
    FROM SPJ
    GROUP BY JNO
) T
WHERE T.总用量 > 500;
```

#### EXISTS / NOT EXISTS — 存在判断

```sql
-- 查询有供货记录的供应商
SELECT SNO, SNAME FROM S
WHERE EXISTS (
    SELECT * FROM SPJ WHERE SPJ.SNO = S.SNO
);

-- 查询没供货记录的供应商
SELECT SNO, SNAME FROM S
WHERE NOT EXISTS (
    SELECT * FROM SPJ WHERE SPJ.SNO = S.SNO
);
```

> ⚠ **EXISTS 特点**：只关心子查询是否返回行（不关心具体内容），`SELECT *` 或 `SELECT 1` 都可以。

---

## 三、数据操纵（DML）

### 1. INSERT INTO — 插入数据

```sql
-- 插入一行（按顺序给值）
INSERT INTO S VALUES ('S1', '精益厂', 20, '天津');

-- 指定列插入（未指定列取 DEFAULT 或 NULL）
INSERT INTO S (SNO, SNAME, CITY) VALUES ('S2', '盛锡厂', '上海');

-- 插入子查询结果（批量插入）
INSERT INTO 北京供应商 (SNO, SNAME, STATUS)
SELECT SNO, SNAME, STATUS FROM S WHERE CITY = '北京';
```

### 2. UPDATE — 修改数据

```sql
-- 修改所有行
UPDATE S SET STATUS = 10;

-- 带条件修改
UPDATE S SET STATUS = 30 WHERE CITY = '北京';

-- 修改多列
UPDATE S
SET STATUS = STATUS + 10, CITY = '天津'
WHERE SNO = 'S1';

-- 带子查询的修改
UPDATE SPJ
SET QTY = QTY + 100
WHERE SNO = (
    SELECT SNO FROM S WHERE SNAME = '精益厂'
);
```

> ⚠ **注意**：不加 `WHERE` 会**修改全部行**！

### 3. DELETE — 删除数据

```sql
-- 删除所有行（表还在）
DELETE FROM S;

-- 带条件删除
DELETE FROM S WHERE CITY = '天津';

-- 带子查询的删除
DELETE FROM SPJ
WHERE SNO IN (
    SELECT SNO FROM S WHERE CITY = '天津'
);
```

> ⚠ `DELETE` 与 `DROP TABLE` 的区别：
> - `DELETE FROM 表` — 只删数据，表结构还在
> - `DROP TABLE 表` — 表和数据一起删除

### 4. TRUNCATE TABLE — 快速清表

```sql
TRUNCATE TABLE S;  -- 清空表，比 DELETE 快，不可回滚
```

---

## 四、集合操作（UNION / INTERSECT / EXCEPT）

```sql
-- 并集（自动去重）
SELECT CITY FROM S
UNION
SELECT CITY FROM P;

-- 并集（不去重）
SELECT CITY FROM S
UNION ALL
SELECT CITY FROM P;

-- 交集（部分数据库支持）
SELECT CITY FROM S
INTERSECT
SELECT CITY FROM P;

-- 差集
SELECT CITY FROM S
EXCEPT
SELECT CITY FROM P;
```

> ⚠ 集合操作要求：各 SELECT 的**列数相同**，对应列数据类型**兼容**。

---

## 五、四道例题详解

### （1）求供应工程 J1 零件的供应商号码 SNO

**题意**：哪些供应商给工程 J1 供过货？

```sql
-- 解法一：简单过滤
SELECT DISTINCT SNO FROM SPJ WHERE JNO = 'J1';

-- 解法二：子查询
SELECT SNO FROM S
WHERE SNO IN (SELECT SNO FROM SPJ WHERE JNO = 'J1');
```

> **知识点**：单表查询，`DISTINCT` 去重

---

### （2）求供应工程 J1 零件 P1 的供应商号码 SNO

**题意**：给工程 J1 供应过零件 P1 的供应商有哪些？

```sql
SELECT DISTINCT SNO FROM SPJ
WHERE JNO = 'J1' AND PNO = 'P1';
```

> **知识点**：多条件 `AND` 连接

---

### （3）求供应工程 J1 红色零件的供应商号码 SNO

**题意**：给工程 J1 供应过红色零件的供应商。颜色在 P 表中，需连接。

```sql
-- 解法一：隐式连接（考试常用）
SELECT DISTINCT SPJ.SNO
FROM SPJ, P
WHERE SPJ.PNO = P.PNO
  AND SPJ.JNO = 'J1'
  AND P.COLOR = '红色';

-- 解法二：显式 JOIN
SELECT DISTINCT SPJ.SNO
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
WHERE SPJ.JNO = 'J1' AND P.COLOR = '红色';

-- 解法三：子查询
SELECT DISTINCT SNO FROM SPJ
WHERE JNO = 'J1'
  AND PNO IN (SELECT PNO FROM P WHERE COLOR = '红色');
```

> **知识点**：两表连接、子查询与连接互换

---

### （4）求没有使用天津供应商生产的红色零件的工程号 JNO

**题意**：找出哪些工程**没用过**天津供应商的红色零件。

> **思路**：先查出"用过的"工程 → 再从全部工程中排除

```sql
-- 解法一：NOT IN（最直观）
SELECT JNO FROM J
WHERE JNO NOT IN (
    SELECT DISTINCT SPJ.JNO
    FROM SPJ, S, P
    WHERE SPJ.SNO = S.SNO
      AND SPJ.PNO = P.PNO
      AND S.CITY = '天津'
      AND P.COLOR = '红色'
);

-- 解法二：NOT EXISTS（更安全）
SELECT JNO FROM J
WHERE NOT EXISTS (
    SELECT *
    FROM SPJ, S, P
    WHERE SPJ.SNO = S.SNO
      AND SPJ.PNO = P.PNO
      AND SPJ.JNO = J.JNO
      AND S.CITY = '天津'
      AND P.COLOR = '红色'
);
```

> **知识点**：
> - 三表连接 + 取反
> - `NOT IN` vs `NOT EXISTS`：
>   - `NOT IN` 子查询结果含 NULL 时整条查询返回空，有**陷阱**
>   - `NOT EXISTS` 不受 NULL 影响，更健壮
> - 解这类题的核心套路：**"找有的 → 从全集排除"**

---

## 六、考试易错点清单

| 易错点 | 说明 |
|--------|------|
| `WHERE` 中不能用聚合函数 | 聚合函数只能在 `HAVING` 或 `SELECT` 中使用 |
| `GROUP BY` 与 `SELECT` 的对应关系 | `SELECT` 中的非聚合列必须出现在 `GROUP BY` 中 |
| `DISTINCT` 作用于后面所有列 | `SELECT DISTINCT A, B` 是对 A、B 组合去重 |
| `NULL` 的判断 | 不能用 `= NULL`，必须用 `IS NULL` |
| `NOT IN` 与 NULL 的陷阱 | 子查询结果若含 NULL，`NOT IN` 返回空 |
| `DELETE` 与 `DROP` 的区别 | DELETE 删数据，DROP 删表 |
| `UPDATE` 不加 WHERE | 会更新表中全部行 |
| 字符串和日期要加引号 | `WHERE CITY = '北京'`（单引号） |
| 外键约束的影响 | 插入/删除时需注意参照完整性，不能先删被引用的主表记录 |

---

## 七、考前速记口诀

```
SELECT 查询 FROM 表，
WHERE 行过滤不能忘，
GROUP BY 分组算，
HAVING 组后再过滤，
ORDER BY 最后排，
DISTINCT 去重要提前。
```

---

## 八、学生-课程-选课 数据库综合例题

### 表结构

```
S(Sno, Sname, Ssex, Sage, Dno)    -- 学生表（学号，姓名，性别，年龄，系编号）
C(Cno, Cname, Cpno, Ccredit)      -- 课程表（课程号，课程名，先修课号，学分）
SC(Sno, Cno, Grade)               -- 选课表（学号，课程号，成绩）
DEPT(Dno, Dname)                  -- 系表（系编号，系名称）
```

---

### （1）查询没有选修数据库课程的学生姓名

**题意**：找出所有没选过"数据库"这门课的学生。

> **思路**：先找出选修了数据库的学生 → 再从全部学生中排除

```sql
-- 解法一：NOT IN（最直观）
SELECT Sname FROM S
WHERE Sno NOT IN (
    SELECT Sno FROM SC
    WHERE Cno IN (SELECT Cno FROM C WHERE Cname = '数据库')
);

-- 解法二：NOT EXISTS
SELECT Sname FROM S
WHERE NOT EXISTS (
    SELECT * FROM SC, C
    WHERE SC.Sno = S.Sno
      AND SC.Cno = C.Cno
      AND C.Cname = '数据库'
);
```

> **知识点**：`NOT IN` / `NOT EXISTS` 取反、三层嵌套子查询（S → SC → C）

---

### （2）查询计算机系没有选修数据库课程的学生姓名

**题意**：在（1）的基础上加系别限制，只查计算机系的学生。

```sql
-- 解法一：隐式连接 + NOT IN
SELECT S.Sname
FROM S, DEPT
WHERE S.Dno = DEPT.Dno
  AND DEPT.Dname = '计算机系'
  AND S.Sno NOT IN (
      SELECT Sno FROM SC
      WHERE Cno IN (SELECT Cno FROM C WHERE Cname = '数据库')
  );

-- 解法二：显式 JOIN + NOT EXISTS
SELECT S.Sname
FROM S
JOIN DEPT ON S.Dno = DEPT.Dno
WHERE DEPT.Dname = '计算机系'
  AND NOT EXISTS (
      SELECT * FROM SC, C
      WHERE SC.Sno = S.Sno
        AND SC.Cno = C.Cno
        AND C.Cname = '数据库'
  );
```

> **知识点**：多表连接 + 取反查询组合

---

### （3）查询有一门课程成绩比王红同学高的学生姓名

**题意**：找出至少有一门课的成绩高于王红（在同一门课上）的学生。

> **关键**：需要**同一门课**比较 → 自连接（SC 自连接）

```sql
-- 解法一：隐式自连接
SELECT DISTINCT S2.Sname
FROM S S1, SC SC1, SC SC2, S S2
WHERE S1.Sname = '王红'          -- 王红
  AND S1.Sno = SC1.Sno          -- 王红的选课记录
  AND SC1.Cno = SC2.Cno         -- 同一门课
  AND SC2.Sno = S2.Sno          -- 其他学生
  AND SC2.Grade > SC1.Grade     -- 成绩比王红高
  AND S2.Sname <> '王红';       -- 排除王红自己

-- 解法二：显式 JOIN
SELECT DISTINCT S2.Sname
FROM S S1
JOIN SC SC1 ON S1.Sno = SC1.Sno
JOIN SC SC2 ON SC1.Cno = SC2.Cno
JOIN S S2 ON SC2.Sno = S2.Sno
WHERE S1.Sname = '王红'
  AND SC2.Grade > SC1.Grade
  AND S2.Sname <> '王红';
```

> ⚠ **考试重点**：**自连接**（同一张表起两个别名）
> - SC 取两个别名 SC1 和 SC2，分别代表"王红的选课"和"其他人的选课"
> - 连接条件 `SC1.Cno = SC2.Cno` 保证比较的是同一门课
> - 最后用 `S2.Sname <> '王红'` 排除自己

---

### （4）求数学成绩比王红同学高的学生姓名

**题意**：在数学这门课上，成绩比王红高的学生有哪些？

> **思路**：在（3）的基础上增加课程名 = '数学' 的限制

```sql
-- 解法一：隐式连接
SELECT S2.Sname
FROM S S1, SC SC1, C, SC SC2, S S2
WHERE S1.Sname = '王红'
  AND S1.Sno = SC1.Sno
  AND SC1.Cno = C.Cno
  AND C.Cname = '数学'        -- 限定数学课
  AND C.Cno = SC2.Cno
  AND SC2.Sno = S2.Sno
  AND SC2.Grade > SC1.Grade
  AND S2.Sname <> '王红';

-- 解法二：显式 JOIN
SELECT S2.Sname
FROM S S1
JOIN SC SC1 ON S1.Sno = SC1.Sno
JOIN C ON SC1.Cno = C.Cno AND C.Cname = '数学'
JOIN SC SC2 ON SC2.Cno = C.Cno
JOIN S S2 ON SC2.Sno = S2.Sno
WHERE S1.Sname = '王红'
  AND SC2.Grade > SC1.Grade
  AND S2.Sname <> '王红';
```

> **知识点**：（3）的进阶版，增加 C 表过滤课程名 = '数学'

---

### （5）找出平均成绩最高的学生学号

**题意**：所有人的平均成绩中，找出最高的那个人的学号。

```sql
-- 解法一：ALL 谓词
SELECT Sno
FROM SC
GROUP BY Sno
HAVING AVG(Grade) >= ALL (
    SELECT AVG(Grade) FROM SC GROUP BY Sno
);

-- 解法二：排序取第一（MySQL / PostgreSQL）
SELECT Sno
FROM SC
GROUP BY Sno
ORDER BY AVG(Grade) DESC
LIMIT 1;

-- 解法三：子查询 + TOP（SQL Server）
SELECT TOP 1 Sno
FROM SC
GROUP BY Sno
ORDER BY AVG(Grade) DESC;

-- 解法四：子查询嵌套
SELECT Sno
FROM SC
GROUP BY Sno
HAVING AVG(Grade) = (
    SELECT MAX(avg_g) FROM (
        SELECT AVG(Grade) AS avg_g FROM SC GROUP BY Sno
    ) AS T
);
```

> ⚠ **考试重点**：
> - 聚合函数不能嵌套在 `WHERE` 中 → 必须用 `HAVING`
> - `>= ALL` 等价于「大于等于最大值」
> - `GROUP BY Sno` 按学号分组后计算每人平均分

---

### （6）将数据库成绩大于等于 90 的改成 100，大于等于 60 小于 90 的加 10%，小于 60 的改为 60

**题意**：分段更新数据库课程的成绩。

> **关键**：`UPDATE` + `CASE WHEN` 实现分段处理

```sql
UPDATE SC
SET Grade = CASE
    WHEN Grade >= 90 THEN 100
    WHEN Grade >= 60 THEN Grade * 1.1   -- 加 10%
    WHEN Grade < 60 THEN 60
    -- 也可以不写 WHEN Grade < 60，直接用 ELSE 60
END
WHERE Cno IN (SELECT Cno FROM C WHERE Cname = '数据库');
```

> ⚠ **考试重点**：
> - `CASE WHEN ... THEN ... ELSE ... END` 实现多分支更新
> - 子查询定位目标课程：`Cno IN (SELECT Cno FROM C WHERE Cname = '数据库')`
> - 注意 `Grade * 1.1` 后的数据类型（可能产生小数）

---

### （7）给出计算机系所有课程都及格的学生的姓名及平均成绩，并按成绩由高到低排列

**题意**：
- 限：计算机系学生
- 条件：该生**所有**选修课程都及格（Grade >= 60）
- 输出：姓名 + 平均成绩
- 排序：平均成绩降序

> **思路**：先排除"有不及格记录"的学生 → 剩下的就是"所有课程都及格"的

```sql
SELECT S.Sname, AVG(SC.Grade) AS 平均成绩
FROM S, DEPT, SC
WHERE S.Dno = DEPT.Dno
  AND DEPT.Dname = '计算机系'
  AND S.Sno = SC.Sno
  AND S.Sno NOT IN (          -- 排除有不及格课程的学生
      SELECT Sno FROM SC WHERE Grade < 60
  )
GROUP BY S.Sno, S.Sname
ORDER BY 平均成绩 DESC;
```

对应 JOIN 写法：

```sql
SELECT S.Sname, AVG(SC.Grade) AS 平均成绩
FROM S
JOIN DEPT ON S.Dno = DEPT.Dno
JOIN SC ON S.Sno = SC.Sno
WHERE DEPT.Dname = '计算机系'
  AND S.Sno NOT IN (
      SELECT Sno FROM SC WHERE Grade < 60
  )
GROUP BY S.Sno, S.Sname
ORDER BY 平均成绩 DESC;
```

> ⚠ **考试重点**：
> - "所有都及格" ⇔ "不存在不及格的" ⇔ `NOT IN (SELECT Sno FROM SC WHERE Grade < 60)`
> - `ORDER BY 平均成绩 DESC` — **降序**排列
> - `GROUP BY S.Sno, S.Sname` — `SELECT` 中的非聚合列 Sname 必须在 GROUP BY 中
> - `AVG(SC.Grade)` 计算平均成绩（忽略 NULL）

---

### 七道题考察知识点汇总

| 题号 | 核心考察点 | 难度 |
|------|-----------|:----:|
| (1) | `NOT IN` / `NOT EXISTS` 取反 + 子查询 | ⭐⭐ |
| (2) | 多表连接 + 取反组合 | ⭐⭐ |
| (3) | 自连接（同一张表取两个别名） | ⭐⭐⭐ |
| (4) | 自连接 + 多表连接进阶 | ⭐⭐⭐ |
| (5) | `GROUP BY` + `HAVING` + `>= ALL` 比最大值 | ⭐⭐ |
| (6) | `UPDATE` + `CASE WHEN` 分段更新 | ⭐⭐ |
| (7) | 综合：多表连接 + 取反 + 分组 + 排序 | ⭐⭐⭐ |
