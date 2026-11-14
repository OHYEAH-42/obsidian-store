---
date: 2026-10-25
tags:
  - 神经网络
cssclasses:
aliases:
  - KV Cache
  - Key-Value Cache
  - 键值缓存
---
# 什么是KV缓存

**KV 缓存**（Key-Value Cache）是在基于 [[Transformer]] 的[[自回归模型|自回归]]推理中，保存各注意力层已处理词元的键（K）和值（V），供后续解码步骤复用的机制。在参数与已有前缀固定的因果自注意力中，后续词元不会改变先前位置的表示，因此可以复用这些键值，避免反复计算整个前缀。

在逐词元、保留完整前缀的解码中，每层的逻辑更新可写为：

$$
K_{\le t}=\operatorname{Concat}_{\mathrm{seq}}(K_{<t},k_t),
\qquad
V_{\le t}=\operatorname{Concat}_{\mathrm{seq}}(V_{<t},v_t).
$$

其中 $t$ 为当前处理位置，$K_{<t},V_{<t}$ 为该层已有缓存，$k_t,v_t$ 为当前位置新计算的键和值；Concat 沿序列维拼接，表示逻辑上的追加，不要求实现中每步重新复制缓存。当前查询与更新后的键值计算注意力，以预测后续词元；历史查询通常不需要缓存，因为之后的注意力计算不再使用它们。

若所有层配置相同，缓存 $B$ 个等长为 $T$ 的序列，共 $L$ 层，每层有 $H_{kv}$ 个键值头，键、值维度分别为 $d_k,d_v$，每个数值占 $s$ 字节，则键值数据本身占用：

$$
M_{\mathrm{KV}}=LBT H_{kv}(d_k+d_v)s.
$$

该式只计算实际保存的键值数值，不包含额外预分配空间、管理信息或并行副本；当 $d_k=d_v=d_h$ 时，简化为 $2LBTH_{kv}d_hs$。因此，[[多查询注意力|MQA]]和[[分组查询注意力|GQA]]减少键值头数时，也会减少这部分缓存数据。

KV 缓存保存的是中间键值表示，不是模型参数，也不是固定的注意力权重；不同步骤的查询仍需重新与历史键匹配。

参考：[Hugging Face Transformers：How caching works](https://huggingface.co/docs/transformers/main/cache_explanation)。
