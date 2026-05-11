---
date: 2026-03-12
tags:
  - 资源
  - Python
---
# 课程简介



- 所属大学：UC Berkeley
- 先修要求：无
- 编程语言：Python, Scheme, SQL
- 课程难度：🌟🌟🌟
- 预计学时：50 小时

伯克利 CS61 系列的第一门课程，也是我的 Python 入门课。jj
CS61 系列是伯克利 CS 专业的入门课，其中：

- CS61A: 强调抽象，让学生掌握用程序来解决实际问题，而不关注底层的硬件细节。
- CS61B: 注重法与数据结构以及大规模程序的构建，学生会用 Java 语言结合算法与数据结构的知识来构建千行代码级别的大型项目（一个简易的谷歌地图，一个二维版的 Minecraft）。
- CS61C: 关注计jj算机体系结构，让学生理解高级语言（例如 C）是如何一步步转换为机器可以理解的 01 串并在 CPU 执行的，学生将会学习 RISC-V 架构并自己用 Logisim 实现一个 CPU。

CS61B 和 CS61 在本书中均有收录。

回到 CS61A，注意这不仅仅是一门编程语言课，而是会深入到程序构造与运行的原理。最后你将在第 4 个 Project 中用 Python 实现一个 Scheme 的解释器。此外，抽象将是这门课的一大主题，你将学习到函数式编程、数据抽象、面向对象等等知识来让你的代码更易读，更模块化。当然，学习编程语言也是这门课的一大内容，你将会掌握 Python、Scheme 和 SQL 这三种编程语言，在它们的学习和比较中，相信你会拥有快速掌握一门新的编程语言的能力。

注意：如果此前完全没有编程基础，直接上手 CS61A 需要一定的学习能力和自律要求。为避免课程难度过高而导致的信心挫折，可以选择一个更为友好的入门编程课程。例如伯克利的 [CS10](https://cs10.org/sp22/) 或者哈佛大学的 [CS50](https://csdiy.wiki/%E7%BC%96%E7%A8%8B%E5%85%A5%E9%97%A8/C/CS50/)。


# 课程资源

- [课程网站](https://cs61a.org/)
- 课程网站 (页面备份): [fall2024](https://insideempire.github.io/CS61A-Website-Archive/), [spring2022](https://cs61a.vercel.app/), [fall2022](https://web.archive.org/web/20220913035803/http://cs61a.org/), [fall2020](https://web.archive.org/web/20201219202644/https://cs61a.org/)
- 课程视频: [spring2024](https://www.bilibili.com/video/BV1sy411z7nA/), [fall2022](https://www.bilibili.com/video/BV1GK411Q7qp/), [fall2020](https://www.bilibili.com/video/BV1s3411G7yM/)
- [课程教材](https://www.composingprograms.com/)
- [课程教材电子书](https://github.com/CC-bit/UCB-CS61A-Textbook/)
- [课程教材中文翻译](https://composingprograms.netlify.app/)
- 课程作业: [fall2024](https://github.com/InsideEmpire/CS61A-Assignments)

# 资源汇总

@PKUFlyingPig 在学习这门课中用到的所有资源和作业实现都汇总在 [PKUFlyingPig/CS61A - GitHub](https://github.com/PKUFlyingPig/CS61A) 中。

@InsideEmpire 在学习这门课中用到的所有资源和作业实现都汇总在 [InsideEmpire/CS61A - GitHub](https://github.com/InsideEmpire/CS61A-PathwayToSuccess/)



# 课程学习笔记


python中，函数可以作为另外一个函数的参数

```
def add(a,b)
	return a+b
	
def add_three(a,b,c,add)
	return add(a,b)+c
```

这种函数被称为Higher-Order Functions



## 函数调用框架


### 例题一

```
from operator import add, mul

def square(x):
    return mul(x, x)      # 返回 x * x

def pirate(arggg):
    print("matey")        # 每次调用 pirate 都会打印
    def plunder(arggg):   # 内层函数，参数名与外层相同
        return arggg      # 返回自己的参数
    return plunder

# 执行表达式
add(pirate(3)(square)(4), 1)
```

| 步骤  | 表达式                  | 函数调用                                            | 中间结果       |
| --- | -------------------- | ----------------------------------------------- | ---------- |
| 1   | pirate(3)            | 打印`matey`，返回函数`plunder`                         | 输出matey    |
| 2   | pirate(3)(square)    | 调用 `plunder(square)`，`plunder` 返回自己的参数 `square` | 得到函数square |
| 3   | pirate(3)(square)(4) | 调用 `square(4)`，`square` 返回 `mul(4, 4) = 16`     | 得到16       |
| 4   | add(16,1)            | 加法运算                                            | 得到17       |
最终输出：
```
matey
17
```



### 例题二

```
def horse(mask):
    horse = mask               # 局部变量 horse 指向参数 mask
    def mask(horse):           # 局部函数 mask，参数名 horn horse(mask)         # 调用局部变量 horse（即原始参数 mask），传入局部函数 mask

mask = lambda horse: horse(2)  # 全局 lambda

horse(mask)                    # 调用全局函数 horse
```


| 步骤  | 表达式                  | 当前帧的关键变量                         | 中间结果       |
| --- | -------------------- | -------------------------------- | ---------- |
| 1   | 调用`horse(work)`      | 全局`mask`=lambda                  | 进入horse函数  |
| 2   | `horse=mask`         | 全局`horse`=全局lambda               | -          |
| 3   | 定义局部函数`mask`         | 局部`mask`=函数`def mask(horse):...` | -          |
| 4   | `return horse(mask)` | 调用局部`horse`(即全局lambda)，参数为`mask` | 进入lambda   |
| 5   | lambda执行`horse(2)`   | lambda的参数`horse`=局部`mask`(函数)    | 调用局部`mask` |
| 6   | 局部`mask(2)`执行        | 参数`horse`=`2`,返回`horse`          | 返回`2`      |
| 7   | 逐层返回                 | -                                | 最终输出`2`    |
名称遮蔽情况：

全局帧:
  horse -> 函数 horse
  mask  -> lambda

进入 horse(mask) 帧 f1:
  参数 mask -> 全局 lambda
  局部变量 horse = 全局 lambda
  局部函数 mask(horse): return horse

return horse(mask):
  horse 是局部变量 = 全局 lambda
  mask  是局部函数

调用全局 lambda(mask):
  进入 f2:
    参数 horse = 局部函数 mask
    return horse(2) → 调用局部 mask(2)

调用局部 mask(2):
  进入 f3:
    参数 horse = 2
    return horse → 返回 2


这两道例题的视频位置： [Lecture 8 Function Examples-en_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1sy411z7nA?spm_id_from=333.788.videopod.sections&vd_source=c227331cf783fe00078b3fe3d8d0b19c&p=8)


---



