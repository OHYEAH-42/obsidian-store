> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [csdiy.wiki](https://csdiy.wiki/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%B3%BB%E7%BB%9F%E5%9F%BA%E7%A1%80/CSAPP/)


> CS 自学指南

课程简介
----

*   所属大学：CMU
*   先修要求：CS61A, CS61B
*   编程语言：C
*   课程难度：🌟🌟🌟🌟🌟
*   预计学时：150 小时

CMU 大名鼎鼎的镇系神课，以其内容庞杂，Project 巨难而闻名遐迩。课程内容覆盖了汇编语言、体系结构、操作系统、编译链接、并行、网络等，作为系统入门课，兼具深度和广度，如果自学确实需要相当的毅力和代码功底。

这门课配合的教材由 CMU 计算机系主任 Bryant 教授执笔，也即所谓的 CSAPP。这也是我第一本认认真真一页一页读过去的计算机教材，虽然很难啃，但着实收获良多。

北大购买了这门课的版权并开设了 Introduction to Computer System 这门课，但其实 CSAPP 所有的课程资源和实验代码都能在它的官方主页上访问到（具体参见下方链接）。

这门课由于过于出名，全世界的码农争相学习，导致其 Project 的答案在网上几乎唾手可得。但如果你真的想锻炼自己的代码能力，希望你不要借鉴任何第三方代码。

认真学完这一门课，你对计算机系统的理解绝对会上升一个台阶。

课程资源
----

*   课程网站：[http://csapp.cs.cmu.edu/](http://csapp.cs.cmu.edu/)
*   课程视频：[https://www.bilibili.com/video/BV1iW411d7hd](https://www.bilibili.com/video/BV1iW411d7hd)
*   课程教材：Computer Systems: A Programmer's Perspective, 3/E[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf]]
*   课程作业：11 个 Project，[代码框架全部开源](http://csapp.cs.cmu.edu/3e/labs.html)

英语有困难的同学可以参考 B 站 UP 主[九曲阑干](https://space.bilibili.com/354767108/)对 CSAPP 的[中文讲解](https://www.bilibili.com/video/BV1cD4y1D7uR)（据说 CMU 的中国留学生也在 CMU 的课堂上看这个视频呢）。另外如果大家在看完 CSAPP 后对书中的第七章链接有一定的疑问，推荐阅读《程序员的自我修养》这本书，书的副标题是链接，装载与库。这本书能够帮助我们完善对程序链接的理解，相信你在看完这本书以后可以对程序的链接，ELF 文件，动态库都将有一个更加深入的理解。十分推荐在读完 CSAPP，对计算机系统有一定的了解以后作为补充资料来阅读。

有关 Lab 部分，同学们亦可参考 [Arthals](https://arthals.ink/about-me) 在北大计算机系统导论（ICS）课程中所做的详尽笔记：

*   [Data Lab](https://arthals.ink/posts/experience/data-lab)
*   [Bomb Lab](https://arthals.ink/posts/experience/bomb-lab)
*   [Attack Lab](https://arthals.ink/posts/experience/attack-lab)
*   [Arch Lab](https://arthals.ink/posts/experience/arch-lab)
*   [Cache Lab](https://arthals.ink/posts/experience/cache-lab)
*   [Tsh Lab](https://arthals.ink/posts/experience/tsh-lab)
*   [Malloc Lab](https://arthals.ink/posts/experience/malloc-lab)
*   [Proxy Lab](https://arthals.ink/posts/experience/proxy-lab)





本次课程以及书籍，配合视频[九曲阑干的个人空间-九曲阑干个人主页-哔哩哔哩视频](https://space.bilibili.com/354767108/lists/373847?type=season)的讲解食用

# 计算机系统漫游

## [[编译系统]]
[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=39&selection=104,1,112,1&color=定义|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.3]]
![[Pasted image 20260513121853.png|697]]

### 为什么要学习编译系统？

- Optimizing program performance 优化系统性能
- Understanding link-time errors 理解链接时出现错误
- Avoiding security holes  避免安全漏洞


## 系统硬件的构成
[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=41&selection=105,0,111,7|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.5]]
- [[总线]]
- [[IO设备]]
- [[主存]]
- [[处理器]]

![[Pasted image 20260513122930.png]]


具体运行hello程序的流程，可以在书中观看[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=43&selection=66,0,72,2|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.7]]


## [[高速缓存]]与存储系统层次结构 
![[Pasted image 20260513154029.png]]


![[Pasted image 20260513154114.png]]


## [[操作系统]]管理硬件

![[Pasted image 20260513154247.png]]
[^1]

[^1]: 这两张图具体的展现了操作系统的结构逻辑以及功能

**文件**是对[[IO设备]]的抽象


### [[进程]]

[[进程]]是对[[虚拟内存]]和[[处理器]]的抽象
### [[线程]]

一个[[进程]]由多个称为[[线程]]的执行单元组成，每个线程都运行在线程的[[上下文]]中，共享同样的代码和全局数据
### [[虚拟内存]]

[[虚拟内存]]是对[[主存]]和文件的抽象


![[Pasted image 20260513154948.png]]
Memory-mapped region for shared libraries 共享库的内存映射区域
User Stack 用户栈
Kernel Memory 内核虚拟内存（用户代码不可见部分）


### [[文件]]

每一个IO设备，包括磁盘，键盘，显示器，甚至是网络，都可以看成是文件

## 系统之间网路通信

利用网络，让远程主机运行“hello”程序
![[Pasted image 20260513222650.png]]


### [[Amdahl定律]]

$$
S = \frac{1}{(1 - α) + \frac{α}{k}}
$$

## 并发和并行

- **[[线程级并发]]**：指的是多个线程在单核或多核处理器上交替或同时执行，以提高程序的吞吐量和响应速度。
- **[[指令级并行]]**：指处理器在一个时钟周期内同时执行多条指令的能力。
- **[[单指令、多数据并行]]**：是一种并行计算模式，一条指令同时对多个数据执行相同操作。



![[Pasted image 20260513222650.png]]



![[Pasted image 20260513232410.png]]



---


# 信息的处理和表示






---



# [[程序]]的机器级表示



## 程序编码

假设一个 C 程序，有两个文件 pl.c 和 p2.c 。我们用 Unix 命令行编译这些代码：

linux> gcc -Og -op p1.c p2.c
[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=149&selection=4,0,4,3&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.113]]
	gcc即指gcc编译器
	 -Og是表示告诉编译器生成符合原始C语言代码整体结构的机器代码(实际中为了获得较高级别的优化，一      般使用的是-O1或者-O2)
	 -o p是表示生成的可执行文件的文件名为“p”

接下来，gcc就会调用一系列程序([[编译系统]]的流程)，将源代码转换为可执行代码.
可执行代买是我们要考虑的机器代码的第二种形式，也就是[[处理器]]执行的代码格式.


### 机器级代码

代码示例
左侧为原C代码[[高级语言]]
![[Pasted image 20260514191009.png]]
-S表示生成的是[[汇编语言]]代码文件

- pushq %rbx  将[[寄存器]]rbx的值压入程序栈进行保存   ([[调用者保存寄存器和被调用者保存寄存器]])，其中，q表示数据大小([[数据类型]])
- movq %rdx ,%rbx 将寄存器rdx的值复制到rbx中
- call mult2 调用函数(x保存在%rdi，y保存在%rsi，dest保存在%rdx)，且运算结果x\*y保存在%rax中
- movq %rax, (%rbx) 将rax的内容存放在内存中(内存的地址在rbx中)
- popq %rbx  从栈顶弹出一个 64 位的数据，并将其存入 rbx 寄存器中。
- ret 函数返回

![[Pasted image 20260514194430.png]]
-c表示生成的是[[机器代码]]
由于机器代码是二进制格式的所以无法直接查看，利用反汇编工具objdump即可

```
linux> objdump -d mstore.o
```

内容如图左
![[Pasted image 20260514194630.png]]


## 访问信息

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=155&selection=211,0,221,1|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.119]])
> 一个 x86-64 的中央处理单元 (CPU[[处理器]]) 包含一组 16 个存储 64 位值的通用目的[[寄存器]]。这些寄存器用来存储整数数据和指针。

![[Pasted image 20260514200905.png]]


## 指令

大多数[[指令]]包含两部分，[[操作码]](operation code)和[[操作数]](operands)

不同指令的[[操作数]]又大致可以分为三类，[[立即数]]，[[寄存器]]，[[内存引用]]

### 数据传送指令

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=158&selection=87,0,87,29&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.122]])
> 最频繁使用的指令是将数据从一个位置复制到另一个位置的指令。

[[数据传送指令]]


同步备份真的很重要啊！！！！！！！！！！！！！！！！！


## 算数和逻辑操作

### 加载有效地址

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=165&selection=176,0,189,5&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.129]])
> [[加栽有效地址指令]](load effective address) leaq 实际上是 movq 指令的变形。它的指令形式是从内存读数据到寄存器，但实际上它根本就没有引用内存。它的第一个操作数看上去是一个内存引用，但该指令并不是从指定的位置读入数据，而是将有效地址写人到目的操作数。

![[Pasted image 20260518161449.png]]



![[Pasted image 20260518161645.png]]


### 一元操作和二元操作
> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=166&selection=174,8,175,17&color=important|p.130]])
> 一元操作，只有一个操作数，既是源又是目的。这个操作数可以是一个寄存器，也可以是一个内存位置。

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=166&selection=191,4,196,27&color=important|p.130]])
> 二元操作，其中，第二个操作数既是源又是目的。这种语法让人想起 C 语言中的赋值运算符，例如 x-=y 。不过，要注意，源操作数是第一个，目的操作数是第二个，

要注意书中习题3.8中， 8(%rax)表示rax寄存器所指向的地址移位8


### 移位操作

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=167&selection=58,5,88,7&color=important|p.131]])
> 移位操作，先给出移位量，然后第二项给出的是要移位的数。可以进行算术和逻辑右移。移位量可以是一个立即数，或者放在单字节寄存器 % cl 中。（这些指令很特别，因为只允许以这个特定的寄存器作为操作数。）原则上来说， 1 个字节的移位量使得移位量的编码范围可以达到 2 8 — 1=255 。 x86 - 64 中，移位操作对 w 位长的数据值进行操作，移位最是由 % cl 寄存器的低 m 位决定的，这里 2'"=w 。高位会被忽略


![[Pasted image 20260518162001.png]]

四条移位指令，SAL和SHL都是左移补零，SAR和SHR不同，算数右移要填符号位，逻辑右移要补0

## 控制

### 条件码

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=171&selection=274,0,302,9&color=important|p.135]])
> 除了整数寄存器， CPU 还维护着一组单个位的条件码 (condition code) 寄存器，它们描述了最近的算术或逻辑操作的属性。可以检测这些寄存器来执行条件分支指令。
> 最常用的[[条件码]]有： 
> CF: 进位标志。最近的操作使最高位产生了进位。可用来检查无符号操作的溢出。 
> ZF: 零标志。最近的操作得出的结果为 0 。 
> SF: 符号标志。最近的操作得到的结果为负数。
> OF: 溢出标志。最近的操作导致一个补码溢出正溢出或负溢出。

![[Pasted image 20260518162703.png]]
除上述指令，还有cmp指令和test指令也会改变条件码，但他们只会改变条件码，不会更新目的寄存器

以下是比较大小中，cmp的用途
![[Pasted image 20260518162533.png]]
说明一下，comq指令会比较ab的差来改变ZF零标志，sete则把al寄存器的值设置为ZF的值

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=172&selection=199,0,210,5&color=important|p.136]])
> 条件码通常不会直接读取，常用的使用方法有三种： 1) 可以根据条件码的某种组合， 将一个字节设置为 0 或者 1, 2) 可以条件跳转到程序的某个其他的部分， 3) 可以有条件地传送数据。

### 跳转指令

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=174&selection=231,0,234,39&color=important|p.138]])
> 正常执行的情况下，指令按照它们出现的顺序一条一条地执行。[[跳转指令]](jump)会导致执行切换到程序中一个全新的位置。在汇编代码中，这些跳转的目的地通常用一个标号指明(label)

跳转指令以及相应的条件
![[Pasted image 20260518164657.png]]

例子
![[Pasted image 20260518164734.png]]

### 用条件传送来实现条件分支

![[Pasted image 20260518165314.png]]
- c是b产生的汇编代码

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=182&selection=31,0,49,17&color=important|p.146]])
> 当机器遇到条件跳转（也称为“分支")时，只有当分支条件求值完成之后，才能决定分支往哪边走。处理器采用非常精密的分支预测逻辑来猜测每条跳转指令是否会执行。只要它的猜测还比较可靠（现代微处理器设计试图达到 90% 以上的成功率），指令流水线中就会充满着指令。另一方面，错误预测一个跳转， 要求处理器丢掉它为该跳转指令后所有指令己做的工作，然后再开始用从正确位置处起始的指令去填充流水线。正如我们会看到的，这样一个错误预测会招致很严重的惩罚，浪费大约 15~30 个时钟周期，导致程序性能严重下降。

简单来说，在条件跳转时，处理器会先猜条件对不对，一般处理器都能猜准。但是如果不准，那就浪费了这一个猜的性能。
而cmovge([[条件传送指令]])，不像[[跳转指令]]，不会有预测这个步骤


### 循环

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=185&selection=186,0,194,25&color=important|p.149]])
> C 语言提供了多种循环结构，即 do-while 、 while 和 for 。汇编中没有相应的指令存在，可以用条件测试和跳转组合起来实现循环的效果。

## 过程

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=200&selection=7,0,27,16&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.164]])
> 过程是软件中一种很重要的抽象。它提供了一种封装代码的方式，用一组指定的参数和一个可选的返回值实现了某种功能。然后，可以在程序中不同的地方调用这个函数。设计良好的软件用过程作为抽象机制，隐藏某个行为的具体实现，同时又提供清晰简洁的接口定义，说明要计算的是哪些值，过程会对程序状态产生什么样的影响。不同编程语言中，过程的形式多样：函数 (function) 、方法 (method) 、子例程 (subroutine) 、处理函数 (handler) 等等，但是它们有一些共有的特性。

### 运行时栈

在不同编程语言中，过程的具体实现是多种多样的。例如c语言的函数，Java语言的方法。

[[栈]]为函数调用提供了后进先出的内存管理机制


在过程p调用过程q时，较早的过程被暂时挂起(暂停执行并等待)。而当Q运行时，它只需要为局部变量分配新的存储空间，或者设置到另一个过程的调用，在栈顶。
Q返回时，这些分配的存储空间都可以被释放。

％rsp是指向栈顶的指针，可以用pushq和popq指令将数据存储进栈中。

[[栈帧]]

三个大括号表示不同的帧
![[Pasted image 20260519201615.png]]
### 转移控制

将PC[[程序计数器]]的值指向Q的代码起始位置就可以实现函数P转移到函数Q。

但是当函数P调用函数Q(返回地址会压入栈中)，函数Q返回时，[[处理器]]必须记录它需要接着执行函数P的代码位置。这个返回地址的压栈操作不能简单地使用pushq和popq指令实现。而是由call来执行。

例如
![[Pasted image 20260519201817.png]]
![[Pasted image 20260519201753.png]]
- callq指令对应于multstore的调用。它不仅要把该过程的第一条指令的地址，写入指令寄存器％rip中，以此实现调用。同时将返回地址压入栈中，这条返回地址就是调用完multstore后，下一条指令的地址。
- 当multstore调用完毕，指令ret会从栈中将返回地址弹出，写入rip，以此继续执行下一条函数。


### 数据传递

如果一个函数的参数数量多于6，则多出来的部分需要使用栈来传递。＜6的参数由对应的寄存器传递。

**参数Argument对应的寄存器：**
![[Pasted image 20260519201837.png]]

通过栈来传递数据时，所有数据的大小都是向8的倍数看齐，如a4为char[[数据类型]]只占了一个字节，但任然为其分配8个字节的空间。
![[Pasted image 20260519201953.png]]

使用寄存器传递数据时，寄存器的使用是有特殊顺序的。
![[Pasted image 20260519202006.png]]

### 栈上的局部存储

当代码中对一个局部变量使用地址运算符时，此时我们要在栈上为该局部变量开闭局部空间

![[Pasted image 20260519202031.png]]
- subq表示将栈顶指针％rsp减去16，即在栈上分配16字节的空间
- movq表示把变量存储在函数的栈帧上
- 然后计算参数arg1和arg2的地址
- call调用swap函数
- addq在％rsp上加上16，以此释放栈帧


传递的参数需要8个字节对齐，而局部变量不需要对齐
![[Pasted image 20260519202052.png]]
### 寄存器中的局部存储空间

寄存器在函数调用中是共享资源，为了防止出现数据覆盖问题，[[处理器]]规定了[[寄存器]]的使用惯例，即[[调用者保存寄存器和被调用者保存寄存器]]:
![[Pasted image 20260519202425.png]]

例如：
![[Pasted image 20260519202533.png]]
- pushq 将寄存器rbq和rbx的原值压入栈中(假设为100)
- moveq 将参数值(42)写入rbx和rbq
- popq 将原值(100)放回rx和rbq

### 递归程

假设n=3
![[Pasted image 20260519202615.png]]
- pushq movq不再复述
- cmpq 
- jle 条件跳转(n=1)
- leaq 计算n-1
- call 再次调用该函数

知道n=1时，才递归结束。我们可以看到，递归调用一个函数本身，和调用其他函数是一样的，每次函数调用都有它私有的状态信息，栈分配与释放的规则与函数调用返回的顺序也是匹配的。
由此可见，当N非常大时，会导致栈的内存不够从而导致溢出

## 数组

以下是矩阵相乘的一个例子
![[Pasted image 20260521125056.png]]
![[Pasted image 20260521125018.png]]
- salq，addq，leaq这四行代码负责计算ai1，b1k，bnk的指针指向的地址
- movl 读取aptr指向元素的数据
- imull 将aptr指向的元素与bptr指向的元素相乘
- addl 将乘积结果累加，存放在edx中
- addq 移动指针指向下一个数组元素，$4是因为int类型占4字节。而$64是因为一行有16个元素，＋16\*4即可到同一列的下一位置

## 结构体

结构体中的数据，类似于数据传递时栈开辟的空间，都会让内存对齐，比如int和char都在结构体中，会给char数据类型分配4个字节的空间而非1个字节。
![[Pasted image 20260521125119.png]]
结构体中数据的存储按顺序，类似于数组

### 联合体

联合体类似于结构体，但不同的是，一个联合体只有一个数据类型。
如图的情况，该联合体对象内，char，int数组，double数据类型不会同时存在，有其一则没有其二。
且联合体的大小等于最大的那一个[[数据类型]]
![[Pasted image 20260521125139.png]]


## 缓冲区溢出

```
void vulnerable(char *input) {
    char buffer[10]; // 分配了10个字节的栈缓冲区
    strcpy(buffer, input); // 危险！没有检查input的长度
}

int main() {
    vulnerable(“AAAAAAAAAAAAAAAAAAAAAAAA”); // 传入远超10字节的数据
    return 0;
}
```
strcpy 函数不会检查目标缓冲区是否足够大，它只会一股脑地把 input 的所有内容复制到 buffer 中。
当复制的字节数超过10时，溢出的数据会**向上**（在栈的典型增长方向上）覆盖紧邻 buffer 的其他数据：
- 首先可能覆盖其他局部变量。    
- 然后覆盖**保存的栈基址指针（EBP/RBP）**。      
- 最后覆盖最关键的东西——**函数的返回地址**。

由此，有人利用缓冲区溢出这一问题，设计了许多攻击计算机的方式

---

# [[处理器]]体系结构

## Y86-64指令体系结合

由于X86过于复杂，书中自定义了Y86的指令来进行教学，便于理解，链接如下：
[[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=281&selection=228,0,229,8&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.245]]

在这里我只做通用的记录，来记录我对这一部分的理解

## 程序员的可见状态

> ([[深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk).pdf#page=281&selection=25,0,28,9&color=important|深入理解计算机系统 (Randal E. Bryant, David R. O’Hallaron) (z-library.sk, 1lib.sk, z-lib.sk), p.245]])
> Y86-64 程序中的每条指令都会读取或修改处理器状态的某些部分。这称为程序员可见状态，这里的＂程序员”既可以是用汇编代码写程序的人，也可以是产生机器级代码的编译器。

- [[寄存器]]
- [[内存]]
- 状态码 Stat ，表面程序的总体状态，会指示是正常运行，还是出现了某种异常


## 逻辑设计和硬件控制语言(HCL)

[[逻辑门]]

HDL是[[硬件描述语言]]（Hardware Description Language）的缩写，用这种语言来描述不同处理器设计的控制逻辑。