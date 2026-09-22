---
date: 2026-07-06
tags:
  - 操作系统
  - 并发
  - 同步
cssclasses:
  - "[[进程互斥与同步]]"
aliases:
  - Mutex
  - 互斥锁
  - 互斥量
---

# 互斥锁（Mutex）

## 概述

**互斥锁（Mutex，全称 Mutual Exclusion）** 是一种用于保护[[临界区]]的同步原语，确保**同一时刻最多只有一个线程**能访问被保护的共享资源。

与二值[[信号量]]不同，互斥锁引入了 **所有权（Ownership）** 概念——谁加锁，谁解锁，这种约束使得互斥锁在功能和行为上与信号量有本质差异。

---

## 核心特性

| 特性 | 说明 |
|------|------|
| **所有权** | 加锁的线程必须由同一线程解锁 |
| **互斥性** | 任何时刻最多一个线程持有锁 |
| **可重入性** | 可选特性，允许同一线程重复加锁（递归锁） |
| **优先级继承** | 解决优先级反转问题的可选机制 |

---

## 类型

### 1. 普通互斥锁（Normal / Fast Mutex）

- 同一线程重复加锁会导致**死锁**（或未定义行为）
- 开销最小，适用于绝大多数场景

### 2. 递归互斥锁（Recursive / Reentrant Mutex）

- 允许同一线程多次加锁，需释放相同次数
- 适用于递归函数或嵌套调用中的临界区

```c
pthread_mutex_t lock = PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP;

void foo() {
    pthread_mutex_lock(&lock);
    // 递归调用自身不会死锁
    foo();
    pthread_mutex_unlock(&lock);
}
```

> ⚠ **设计上应尽量回避递归锁**，它通常是设计不良的信号——说明临界区边界不够清晰。

### 3. 检错互斥锁（Error-Checking Mutex）

- 同一线程重复加锁会**返回错误**（而非死锁）
- 用于调试阶段发现锁使用问题

### 4. 自适应互斥锁（Adaptive Mutex）

- 混合自旋锁 + 睡眠锁策略
- 短临界区先自旋，长等待再睡眠
- 用于操作系统内核（如 Linux 内核的 `mutex`）

---

## 互斥锁 vs 二值信号量

这是最常见的混淆点。两者都可以初始化为 1 且都提供互斥功能，但**本质不同**：

| 对比维度 | 互斥锁（Mutex） | 二值信号量（Binary Semaphore） |
|---------|---------------|------------------------------|
| **所有权** | ✅ 有（谁加锁谁解锁） | ❌ 无（任何线程都可执行 V 操作） |
| **用途** | 互斥访问共享资源 | 同步 + 互斥 |
| **释放限制** | 只能由加锁线程释放 | 可由任意线程/进程释放 |
| **递归加锁** | 可选支持（recursive mutex） | 不可（重复 P 会阻塞） |
| **优先级继承** | 通常支持 | 通常不支持 |
| **典型初始值** | 1（表示锁可用） | 0 或 1（取决于用途） |
| **内核实现** | 通常基于 futex（Linux） | 基于内核信号量机制 |
| **语义** | 保护资源 | 通知事件 / 管理资源数量 |

### 关键区别示例

```c
// ❌ 错误用法：二值信号量可被"错误"的线程释放
sem_t sem;
sem_init(&sem, 0, 1);

// Thread A
sem_wait(&sem);       // 加锁

// Thread B (不同线程)
sem_post(&sem);        // ✅ 合法！但这是错误的——B 释放了 A 持有的"锁"

// ✅ Mutex 强制所有权
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// Thread A
pthread_mutex_lock(&mutex);

// Thread B
pthread_mutex_unlock(&mutex);  // ❌ 未定义行为！不是锁的持有者
```

> [!tip] 记忆方法
> Mutex 像一把**钥匙**——谁拿走谁归还；信号量像**发号牌**——任何人拿都可以由另一个人归还。

---

## 使用模式

### 基本模式

```c
pthread_mutex_lock(&mutex);
// 临界区：访问共享资源
pthread_mutex_unlock(&mutex);
```

### RAII 封装（C++）

```cpp
// C++11 std::lock_guard：构造加锁，析构解锁
{
    std::lock_guard<std::mutex> lock(mtx);
    // 临界区
}  // 自动解锁
```

### 双重检查锁定（Double-Checked Locking）

```c
if (instance == NULL) {          // 第一次检查（无需锁）
    pthread_mutex_lock(&lock);
    if (instance == NULL) {      // 第二次检查（需锁）
        instance = malloc(...);
    }
    pthread_mutex_unlock(&lock);
}
```

> 需要配合内存屏障（`volatile` / `atomic`）使用，否则编译器优化可能导致指令重排。

---

## 死锁与预防

### 死锁四条件（Coffman 条件）

| 条件 | 说明 | 破解方法 |
|------|------|---------|
| **互斥** | 资源不可共享 | 有时不可破 |
| **持有并等待** | 持有锁的同时等待其他锁 | 一次性申请所有锁 |
| **不可抢占** | 不能强行拿走锁 | 使用 `trylock` 超时重试 |
| **循环等待** | 形成等待环路 | **固定加锁顺序** |

### 加锁顺序约定

```c
// ❌ 危险：两个锁顺序不一致
// Thread A: lock(A) → lock(B)
// Thread B: lock(B) → lock(A)  ← 可能死锁

// ✅ 安全：全局固定顺序
// Thread A: lock(A) → lock(B)
// Thread B: lock(A) → lock(B)  ← 顺序一致
```

> 更多死锁相关内容见 [[死锁]]

---

## 实现原理

### 用户态 + 内核态（futex — Linux）

现代操作系统将互斥锁实现为**两阶段**操作，避免每次加锁都陷入内核：

```c
// 伪代码：基于 futex 的互斥锁
void lock(mutex *m) {
    // 阶段 1：用户态快速路径（原子操作，不陷入内核）
    if (atomic_compare_exchange(&m->val, 0, 1))
        return;  // 成功获取锁

    // 阶段 2：内核态慢速路径（线程阻塞）
    futex_wait(&m->val, 1);  // 系统调用
}

void unlock(mutex *m) {
    // 用户态解锁
    if (atomic_exchange(&m->val, 0) != 1)
        futex_wake(&m->val);  // 如果有等待者，唤醒
}
```

**关键优化**：锁未发生竞争时，整个过程在用户态完成，零系统调用开销。

### 自旋锁（Spinlock）

适用于**短临界区**，线程通过忙等待轮询，不睡眠：

```c
void spin_lock(atomic_flag *lock) {
    while (atomic_flag_test_and_set(lock))  // TAS 指令
        ;  // 自旋等待
}
void spin_unlock(atomic_flag *lock) {
    atomic_flag_clear(lock);
}
```

| 特性 | Mutex（睡眠锁） | Spinlock |
|------|---------------|----------|
| 临界区大小 | 任意 | 极短（纳秒级） |
| 等待开销 | 上下文切换 | CPU 空转 |
| 适用场景 | 用户态通用 | 内核、实时系统 |

---

## 常见陷阱

### 1. 忘记解锁（资源泄漏）

```c
// ❌ 错误：if 分支中提前返回导致未解锁
pthread_mutex_lock(&lock);
if (error) {
    return -1;  // ⚠ 没有解锁！
}
pthread_mutex_unlock(&lock);

// ✅ 正确：RAII 或 goto cleanup 模式
```

### 2. 锁的粒度不匹配

```c
// ❌ 粒度太粗：整个大循环加锁，并发度为 0
for (int i = 0; i < N; i++) {
    lock(mutex);
    // 大量计算...
    unlock(mutex);
}

// ✅ 粒度更细：仅保护共享数据的访问
lock(mutex);
shared_var++;
unlock(mutex);
// 耗时计算在外面做...
```

### 3. 锁的顺序不一致（见死锁部分）

### 4. 遗漏 volatile / 内存屏障

```c
// ❌ 错误：编译器可能将 flag 缓存在寄存器中
int flag = 0;
// Thread 1:  flag = 1;
// Thread 2:  while (!flag);  // 可能永远看不到修改

// ✅ 正确：使用原子类型
atomic_int flag = 0;
```

---

## 关联笔记

- [[PV操作]] — P/V 原语实现互斥与同步
- [[信号量]] — 信号量机制，含与互斥锁对比表
- [[临界区]] — 需要保护的程序段
- [[进程互斥与同步]] — 互斥与同步基本概念
- [[死锁]] — 死锁的产生条件与预防
- [[生产者-消费者问题]] — 经典同步问题中的 mutex 应用
- [[读者-写者问题]] — 读写锁与 mutex 的组合使用
