---
date: 2026-07-04
tags:
  - 操作系统
cssclasses:
  - "[[进程互斥与同步]]"
---

# PV 操作

## 概述

PV 操作是 **荷兰计算机科学家 Dijkstra** 提出的用于解决[[进程互斥与同步]]问题的低级通信原语。PV 操作由两个原子操作组成，作用于**信号量（Semaphore）** 之上。

### [[信号量]]（Semaphore）

信号量是一个整型变量，代表系统中某种资源的数量。信号量只能通过 **P 操作** 和 **V 操作** 来改变。

- **S > 0**：表示有 S 个资源可用
- **S = 0**：表示无资源可用
- **S < 0**：表示有 |S| 个进程在等待该资源

### 命名来源

| 操作    | 荷兰语              | 含义           |
| ----- | ---------------- | ------------ |
| **P** | **Proberen**（测试） | 减少信号量，尝试获取资源 |
| **V** | **Verhogen**（增加） | 增加信号量，释放资源   |

> [!tip] 记忆技巧
> P 像是一个 **P**ark（停车）操作——停车占用车位（资源减少）；V 像是 **V**acate（空出）——开车离开释放车位（资源增加）。

---

## 操作定义

### P 操作（Wait / Down / Acquire）

```
procedure P(S:Semaphore)：
	begin
		S:=S-1;
		if S<0 then W(S)；
	end;
```

- 申请一个资源
- 若资源不足，进程进入阻塞状态W(S)

**主要操作**：
1. S-1
2. 若S-1后仍大于或等于0，则进程继续执行
3. 若S-1后小于0，则该进程被阻塞后放入等待该信号量的等待队列中，然后转进程调度。
![[Pasted image 20260704220620.png]]
### V 操作（Signal / Up / Release）

```
procedure V(S:Semaphore)
	begin
		S:=S+1;
		if S<=0 then R(S);
	end;
```

- 释放一个资源
- 若有进程在等待，唤醒其中一个R(S)

**主要操作**：
1. S+1
2. 若S+1后仍大于0，则进程继续执行
3. 若S+1后小于等于0，则该进程被阻塞后放入等待该信号量的等待队列中，然后转进程调度。
![[Pasted image 20260704220721.png]]

> [!important] 原子性
> P 和 V 操作各自都是一个**不可中断的原子操作**，在执行期间不会被其他进程打断。这是通过**关中断**或**硬件指令**（如 Test-And-Set）来实现的。

---

## 信号量分类

### 1. 整型信号量

只能进行 P、V 操作，不区分资源数量，仅用于互斥：

```
P(S) {
  while (S <= 0) ;  // 忙等待（busy waiting）
  S--;
}
V(S) {
  S++;
}
```

**缺点**：存在**忙等待**问题（CPU 空转），违背"让权等待"原则。

### 2. 记录型信号量

引入阻塞队列，避免忙等待：

```
typedef struct {
  int value;                  // 资源数量
  struct process *list;       // 阻塞队列
} semaphore;
```

### 3. 二值信号量（Binary Semaphore）

信号量值只能取 0 或 1，用于**互斥访问**。

### 4. 计数信号量（Counting Semaphore）

信号量可取任意非负整数值，用于**资源管理**。

---

## PV 操作解决互斥

**互斥模型**（同类资源互斥访问）：

```
semaphore mutex = 1;  // 互斥信号量

// 进程 P1                      // 进程 P2
P(mutex);                       P(mutex);
  临界区（Critical Section）       临界区（Critical Section）
V(mutex);                       V(mutex);
```

- `mutex = 1`：初始资源可用
- `P(mutex)`：进入区，申请进入临界区
- `V(mutex)`：退出区，释放临界区

---

## 经典同步问题

### 1. [[生产者-消费者问题]]

有界缓冲区，生产者放数据，消费者取数据。

```
semaphore mutex = 1;      // 互斥信号量，保护缓冲区，为1表示资源可用
semaphore empty = n;      // 空闲缓冲区数量
semaphore full = 0;       // 已满缓冲区数量

// 生产者
Producer() {
  while (true) {
    produce_item();       // 生产一个数据项
    P(empty);             // 申请一个空闲缓冲区
    P(mutex);             // 进入临界区
      put_item();        // 将数据放入缓冲区
    V(mutex);             // 退出临界区
    V(full);              // 增加满缓冲区数量
  }
}

// 消费者
Consumer() {
  while (true) {
    P(full);              // 申请一个满缓冲区
    P(mutex);             // 进入临界区
      get_item();        // 从缓冲区取出数据
    V(mutex);             // 退出临界区
    V(empty);             // 增加空闲缓冲区数量
    consume_item();       // 消费数据
  }
}
```

> [!warning] 注意
> P 操作的顺序**不能交换**。若 `P(mutex)` 在前 `P(empty)` 在后，当缓冲区满时生产者会持有 mutex 并阻塞在 empty 上，消费者无法进入临界区消费，导致**死锁**。在多生产者-多消费者场景下，这个问题更加复杂，还可能引发**饥饿**问题。

### 2. [[读者-写者问题]]

多进程共享数据文件，读者只读不修改，写者可以读写。

**读者优先策略**：

```
semaphore rw_mutex = 1;   // 写者互斥信号量
semaphore mutex = 1;      // 保护 read_count
int read_count = 0;       // 当前读者数量

// 写者
Writer() {
  P(rw_mutex);            // 申请写权限
    write();             // 写入数据
  V(rw_mutex);            // 释放写权限
}

// 读者
Reader() {
  P(mutex);
    read_count++;
    if (read_count == 1)  // 第一个读者
      P(rw_mutex);        // 阻止写者
  V(mutex);
    read();              // 读取数据
  P(mutex);
    read_count--;
    if (read_count == 0)  // 最后一个读者
      V(rw_mutex);        // 允许写者
  V(mutex);
}
```

**写者优先策略**（解决读者饥饿）：

```
semaphore rw_mutex = 1;   // 写者互斥信号量
semaphore mutex = 1;      // 保护 read_count
semaphore write_mutex = 1; // 写者等待队列
int read_count = 0;

// 写者
Writer() {
  P(write_mutex);          // 写者排队
    P(rw_mutex);
    write();
    V(rw_mutex);
  V(write_mutex);
}

// 读者
Reader() {
  P(write_mutex);          // 检查是否有写者在等待
    P(mutex);
      read_count++;
      if (read_count == 1)
        P(rw_mutex);
    V(mutex);
  V(write_mutex);
    read();
  P(mutex);
    read_count--;
    if (read_count == 0)
      V(rw_mutex);
  V(mutex);
}
```

---

### 3. 哲学家就餐问题

5 个哲学家坐在圆桌旁，每两人之间有一根筷子，哲学家需要两根筷子才能吃饭。

```
#define N 5
semaphore chopstick[N] = {1, 1, 1, 1, 1};

// 第 i 个哲学家（可能导致死锁的版本）
Philosopher(int i) {
  while (true) {
    P(chopstick[i]);            // 拿左边筷子
    P(chopstick[(i + 1) % N]); // 拿右边筷子
      eat();                   // 吃饭
    V(chopstick[i]);            // 放左边筷子
    V(chopstick[(i + 1) % N]); // 放右边筷子
      think();                 // 思考
  }
}
```

**解决方法**（避免死锁）：

| 方案 | 描述 |
|------|------|
| **最多允许 4 人同时吃饭** | 增加信号量 `count = 4`，限制并发 |
| **奇数先左后右，偶数先右后左** | 破坏循环等待条件 |
| **仅当两根筷子都可用时才拿** | 用互斥信号量保护取筷子过程 |

---

### 4. 吸烟者问题

三个吸烟者分别持有烟草、纸、胶水中的一种材料，桌上由代理商随机放置两种材料，持有第三类材料的吸烟者取走并使用。

```
semaphore agent = 1;     // 代理商信号量
semaphore tobacco = 0;   // 烟草就绪
semaphore paper = 0;     // 纸就绪
semaphore glue = 0;      // 胶水就绪

// 代理商
Agent() {
  while (true) {
    P(agent);
    int r = random() % 3;
    switch (r) {
      case 0: V(tobacco); V(paper); break;  // 提供烟草和纸
      case 1: V(paper); V(glue); break;     // 提供纸和胶水
      case 2: V(tobacco); V(glue); break;   // 提供烟草和胶水
    }
  }
}

// 持有胶水的吸烟者
SmokerWithGlue() {
  while (true) {
    P(tobacco);   // 等待烟草
    P(paper);     // 等待纸
    make_cigarette_and_smoke();
    V(agent);     // 通知代理商继续提供
  }
}
// 其他吸烟者类似...
```

---

## 常见题型与解题思路

### 解题步骤

| 步骤 | 内容 |
|------|------|
| **1. 分析关系** | 找出进程间的**同步**关系和**互斥**关系 |
| **2. 确定信号量** | 为每类资源或同步条件定义信号量并初始化 |
| **3. 画前驱图** | 画出进程间的前驱关系图（可选但推荐） |
| **4. 编写代码** | 在关键位置插入 P/V 操作 |
| **5. 检查死锁** | 验证不会产生死锁和饥饿 |

### 解题口诀

> **同步 P 在前，互斥 P 在后**
> 同步 V 在资源产生后，互斥 V 在资源使用后

- 同步信号量的 P 操作（等待资源就绪）要放在互斥信号量的 P 操作之前
- V 操作顺序通常没有严格要求

