> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [csdiy.wiki](https://csdiy.wiki/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F/NJUOS/)

> CS 自学指南

课程简介
----

*   所属大学：南京大学
*   先修要求：体系结构 + 扎实的 C 语言功底
*   编程语言：C 语言
*   课程难度：🌟🌟🌟🌟
*   预计学时：150 小时

之前一直听说南大的蒋炎岩老师开设的操作系统课程讲得很好，久闻不如一见，这学期有幸在 B 站观看了蒋老师的课程视频，确实收获良多。蒋老师作为非常年轻的老师，有着丰富的一线代码的经验，因此课程讲授有着满满的 Hacker 风格，课上经常 “一言不合” 就在命令行里开始写代码，很多重要知识点也都配有生动直白的代码示例。让我印象最为深刻的就是老师为了让学生更好地理解动态链接库的设计思想，甚至专门实现了一个迷你的可执行文件与一系列的二进制工具，让很多困扰我多年的问题都得到了解答。

这门课的讲授思路也非常有趣，蒋老师先从 “程序就是状态机” 这一视角入手，为 “万恶之源” 并发程序建立了状态机的转化模型，并在此基础上讲授了并发控制的常见手段以及并发 bug 的应对方法。接着蒋老师将操作系统看作一系列对象（进程 / 线程、地址空间、文件、设备等等）以及操作它们的 API （系统调用）并结合丰富的实际例子介绍了操作系统是如何利用这系列对象虚拟化硬件资源并给应用软件提供各类服务的。最后的可持久化部分，蒋老师从 1-bit 的存储介质讲起，一步步构建起各类存储设备，并通过设备驱动抽象出一组接口来方便地设计与实现文件系统。我之前虽然上过许多门操作系统的课程，但这种讲法确实独此一家，让我收获了很多独到的视角来看待系统软件。

这门课除了在理论知识的讲授部分很有新意外，注重实践也是蒋老师的一大特点。在课堂和编程作业里，蒋老师会有意无意地培养大家阅读源码、查阅手册的能力，这也是计算机从业者必备的技能。在完成第五个 MiniLab 期间，我第一次仔仔细细阅读了微软的 FAT 文件系统手册，收获了一次非常有价值的经历。

编程作业共由 5 个 MiniLab 和 4 个 OSLab 组成。美中不足的是作业的评测机是不对校外开放的，不过在邮件 “骚扰” 后蒋老师还是非常慷慨地让我成功蹭课。由于课余时间有限我只完成了 5 个 MiniLab，总体体验非常棒。尤其是第二个协程实验让我印象最为深刻，在不到百行的小实验里深刻体验了上下文切换的美妙与 “可怕”。另外其实几个 MiniLab 都能非常方便地进行本地测试，就算没有评测机也不影响自学，因此希望大家不要聚众“骚扰” 老师以图蹭课。

最后再次感谢蒋老师设计并开放了这样一门非常棒的操作系统课程，这也是本书收录的第一门国内高校自主开设的计算机课程。正是有蒋老师这些年轻的新生代教师在繁重的 Tenure 考核之余的用爱发电，才让无数学子收获了难忘的本科生涯。也期待国内能有更多这样的良心好课，我也会第一时间收录进本书中让更多人受益。

课程资源
----

*   课程网站：[https://jyywiki.cn/OS/2022/index.html](https://jyywiki.cn/OS/2022/index.html)
*   课程视频：[https://space.bilibili.com/202224425/channel/collectiondetail?sid=192498](https://space.bilibili.com/202224425/channel/collectiondetail?sid=192498)
*   课程教材：[http://pages.cs.wisc.edu/~remzi/OSTEP/](http://pages.cs.wisc.edu/~remzi/OSTEP/)
*   课程作业：[https://jyywiki.cn/OS/2022/index.html](https://jyywiki.cn/OS/2022/index.html)

资源汇总
----

按蒋老师的要求，我的作业实现没有开源。




# 什么是[[操作系统]]

Operating System: A body of software, in fact, that is responsible for _making it easy to run programs_ (even allowing you to seemingly run many at the same time), allowing programs to share memory, enabling programs to interact with devices, and other fun stuff like that. (OSTEP)
操作系统：实际上，它是一个软件体系，负责让程序能够轻松运行（甚至让你看似可以同时运行多个程序），允许程序共享内存，使程序能够与设备交互，以及实现诸如此类的其他有趣功能。（选自《操作系统导论》）操作系统：实际上，它是一个软件体系，负责让程序能够轻松运行（甚至让你看似可以同时运行多个程序），允许程序共享内存，使程序能够与设备交互，以及实现诸如此类的其他有趣功能。（选自《操作系统导论》）

## 理解操作系统：三个根本问题

### 操作系统服务与谁？
- 程序=状态机
- 课程设计:多线程Linux应用程序

### (设计/应用视角) 操作系统为程序提供什么服务？

- 操作系统 = 对象 + API
- 课程涉及：POSIX + 部分 Linux 特性

### (实现/硬件视角) 如何实现操作系统提供的服务？

- 操作系统 = C 程序
	- 完成初始化后就成为 interrupt/trap/fault handler
- 课程涉及：xv6, 自制迷你操作系统



---


# 操作系统上的[[程序]]


## **什么是[[状态机]]？**

### 数字逻辑电路

- 状态 = 寄存器保存的值 (flip-flop)
- 初始状态 = RESET (implementation dependent)
- 迁移 = 组合逻辑电路计算寄存器下一周期的值

### 源代码视角下的程序

程序就是状态机 (你在 gdb 里看到的)

- 试试程序吧 [hanoi-r.c](https://jyywiki.cn/pages/OS/2022/demos/hanoi-r.c)

C 程序的状态机模型 (语义，semantics)

- 状态 = 堆 + 栈
- 初始状态 = `main` 的第一条语句
- 迁移 = 执行一条简单语句
    - 任何 C 程序都可以改写成 “非复合语句” 的 C 代码
    - [真的有这种工具](https://cil-project.github.io/cil/) (C Intermediate Language) 和[解释器](https://gitlab.com/zsaleeba/picoc)


C 程序的状态机模型 (语义，semantics)

- 状态 = stack frame 的列表 (每个 frame 有 PC) + 全局变量
- 初始状态 = main(argc, argv), 全局变量初始化
- 迁移 = 执行 top stack frame PC 的语句; PC++
    - 函数调用 = push frame (frame.PC = 入口)
    - 函数返回 = pop frame

应用：将任何递归程序就地转为非递归

- 汉诺塔难不倒你 [hanoi-nr.c](https://jyywiki.cn/pages/OS/2022/demos/hanoi-nr.c)
- A → B, B → A 的也难不倒你
    - 还是一样的 `call()`，但放入不同的 `Frame`

### 二进制代码下的程序

还是状态机

- 状态 = 内存 MM + 寄存器 RR
- 初始状态 = (稍后回答)
- 迁移 = 执行一条指令
    - 我们花了一整个《计算机系统基础》解释这件事
    - gdb 同样可以观察状态和执行

操作系统上的程序

- 所有的指令都只能计算
    - deterministic: mov, add, sub, call, ...
    - non-deterministic: rdrand, ...
    - 但这些指令甚至都无法使程序停下来 (NEMU: 加条 `trap` 指令)

---

## 如何在程序的两个视角之间切换？

“状态机” 顺便解决了一个非常重要的基本问题：

> 什么是[[编译器]]？？？

编译器：源代码 SS (状态机) → 二进制代码 CC (状态机)C=compile(S)C=compile(S)

编译 (优化) 的正确性 (Soundness):

- SS 与 CC 的可观测行为严格一致
    - system calls; volatile variable loads/stores; termination
- Trivially 正确 (但低效) 的实现
    - 解释执行/直接翻译 SS 的语义
## 操作系统中的一般程序

操作系统收编了所有的硬件/软件资源

- 只能用操作系统允许的方式访问操作系统中的对象
    - 从而实现操作系统的 “霸主” 地位
    - 例子：[tryopen.c](https://jyywiki.cn/pages/OS/2022/demos/tryopen.c)
- 这是为 “管理多个状态机” 所必须的
    - 不能打架，谁有权限就给他

## 总结

本次课回答的问题

- **Q**: 到底什么是 “程序”？

Take-away message

- 程序 = 状态机
    - 源代码 SS: 状态迁移 = 执行语句
    - 二进制代码 CC: 状态迁移 = 执行指令
    - 编译器 C=compile(S)C=compile(S)
- 应用视角的操作系统
    - 就是一条 syscall 指令
- 计算机系统不存在玄学；一切都建立在确定的机制上
    - 理解操作系统的重要工具：gcc, binutils, gdb, strace


---



# 并发

本节课课件：[多处理器编程：从入门到放弃](https://jyywiki.cn/OS/2022/slides/3.slides.html#/2/4)

[[并发]]的概念

## 原子性：

原子性：一段代码执行 (例如 `pay()`) 独占整个计算机系统

- 单处理器多线程
    - 线程在运行时可能被中断，切换到另一个线程执行
- 多处理器多线程
    - 线程根本就是并行执行的

```
#define N 100000000
long sum = 0;

void Tsum() { for (int i = 0; i < N; i++) sum++; }

int main() {
  create(Tsum);
  create(Tsum);
  join();
  printf("sum = %ld\n", sum);
}
```
当再多处理器多线程情况下并发执行时，你会发现求和求不出准确数值。(sum 是全局变量，是共享的)

| 线程A      | 线程B      | 内存中的sum |
| -------- | -------- | ------- |
| 读取sum=0  |          | 0       |
|          | 读取sum=o  | 0       |
| 寄存器0+1=1 |          | 0       |
|          | 寄存器0+1=1 | 0       |
| 写回sum=1  |          | 1       |
|          | 写回sum=1  | 1       |
以上表格是一次并发执行时，可能出现的交错，在大尺度下，这种交错会非常多。
故sum++不是一次原子操作，导致错误

## 顺序

我们好像忘记给 sum.c 添加编译优化了？

-O1: 100000000 😱😱
-O2: 200000000 😱😱😱

运行上述指令，优化方式不同时，结果依然不同

在代码中插入 “优化不能穿越” 的 barrier

- `asm volatile ("" ::: "memory");`
    - Barrier 的含义是 “可以读写任何内存”
- 使用 `volatile` 变量
    - 保持 C 语义和汇编语义一致

此时编译器优化时不会强行优化