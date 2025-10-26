#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/hydra:0.6.1": hydra

#show: codly-init.with()
#codly(languages: codly-languages)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it
#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1.1)")
#set page(paper: "a4", margin: (y: 4em), numbering: "1", header: context {
  align(right, emph(hydra(2)))
  line(length: 100%)
})

= Raft 理论
Raft 是一种分布式一致性算法，用于解决分布式系统中的数据一致性问题。该算法由Stanford University的Diego Ongaro和John Ousterhout于2013年提出，是分布式系统领域的重要成果之一。由于算法设计简单，易于理解，且性能优越，被广泛应用于分布式系统的一致性场景中。#footnote("In Search of an Understandable Consensus Algorithm_ (Diego Ongaro, John Ousterhout, 2013)")

== 基本概念
Raft算法将分布式一致性问题分解为三个子问题：
- 领导选举（Leader Election）：选举一个领导者，负责处理客户端请求。
- 日志复制（Log Replication）：领导者将客户端请求转换为日志，并将其复制到其他节点。
- 安全性（Safety）：确保只有领导者可以提交日志，并且日志的提交顺序是正确的。

这里涉及到三个角色：
- 领导者（Leader）：负责处理客户端请求，将请求转换为日志条目，并将日志复制到其他节点。同时定期向所有Follower发送心跳消息以维持领导地位。
- 追随者（Follower）：被动接收并复制领导者发送的日志条目和心跳消息。当在选举超时时间内没有收到Leader的心跳时，会转变为Candidate。
- 候选人（Candidate）：当Follower超时未收到Leader心跳时，会转变为Candidate并发起选举，请求其他节点投票。如果获得多数票则成为Leader。


== 任期（Term）
Raft算法将时间划分为任意长度的任期（Term），任期用连续的整数标记。每个任期开始于一次选举：
- 每个任期最多只有一个Leader
- 某些任期可能没有Leader（选举失败）
- 任期单调递增，是Raft算法中的逻辑时钟
- 节点在通信时会交换当前任期号，如果发现自己的任期号较小，会立即更新并转为Follower状态

== 领导选举流程
=== 选举触发条件
当Follower在选举超时时间（election timeout）内没有收到Leader的心跳消息时，会发起选举：
1. Follower将自己的任期号加1
2. 转变为Candidate状态
3. 为自己投票
4. 向所有其他节点发送RequestVote RPC请求投票

=== 选举结果
Candidate可能遇到三种情况：
- *赢得选举*：获得超过半数节点的投票，成为Leader，并开始发送心跳
- *其他节点成为Leader*：收到合法Leader的心跳消息（任期号不小于自己），转为Follower
- *选举超时*：没有任何节点赢得选举，增加任期号并重新发起选举

=== 投票规则
每个节点在一个任期内只能投票给一个Candidate，遵循先到先得原则。同时，只有满足以下条件才会投票：
- Candidate的任期号不小于自己的任期号
- Candidate的日志至少和自己一样新（日志完整性检查）

== 日志复制流程
=== 正常流程
1. Leader接收客户端请求
2. Leader将请求封装为日志条目，追加到自己的日志中
3. Leader并行地向所有Follower发送AppendEntries RPC
4. Follower接收日志条目并写入本地日志
5. 当日志条目被超过半数节点复制后，Leader提交该日志条目
6. Leader将已提交的日志条目应用到状态机，并返回结果给客户端
7. Leader在后续的AppendEntries RPC中通知Follower提交日志

=== 日志一致性
Raft维护以下日志属性：
- 如果两个日志条目有相同的索引和任期号，则它们存储相同的命令
- 如果两个日志条目有相同的索引和任期号，则它们之前的所有条目都相同

Leader通过强制Follower复制自己的日志来处理不一致：
- Leader为每个Follower维护一个nextIndex
- 如果Follower的日志与Leader不一致，Leader会递减nextIndex并重试
- 最终找到双方日志一致的点，从该点开始覆盖Follower的日志

== 安全性保证
=== Leader完整性
只有包含所有已提交日志条目的Candidate才能被选举为Leader。通过以下机制保证：
- 投票时进行日志完整性检查
- 比较最后一条日志的任期号和索引，选择日志更新的Candidate

=== 状态机安全性
如果某个节点已经将某个日志条目应用到状态机，则其他节点不会在相同索引位置应用不同的日志条目。

=== Leader只追加原则
Leader永远不会覆盖或删除自己的日志条目，只会追加新条目。

== 成员变更
Raft使用两阶段方法进行集群成员变更，避免在配置变更期间出现多个Leader：
1. 先切换到过渡配置（joint consensus）
2. 再切换到新配置

在过渡期间，任何决策都需要在新旧配置中都获得多数同意。

== 日志压缩
为了防止日志无限增长，Raft使用快照（Snapshot）机制：
- 当日志达到一定大小时，将当前状态机状态保存为快照
- 删除快照之前的所有日志条目
- Leader通过InstallSnapshot RPC向落后的Follower发送快照

== Raft的关键特性
=== 强领导者（Strong Leader）
- 日志条目只从Leader流向其他节点
- 简化了日志复制的管理逻辑

=== 领导选举
- 使用随机选举超时来避免选举冲突
- 通常情况下能快速选出Leader

=== 成员变更
- 使用联合共识机制实现安全的配置变更
- 在变更期间集群仍可继续服务

== 与Paxos的对比
相比于Paxos算法，Raft的主要优势：
- *易理解*：通过问题分解（选举、日志复制、安全性）降低复杂度
- *易实现*：状态空间更小，边界条件更少
- *强Leader*：简化了系统设计和调试
- *日志完整性*：通过限制谁可以成为Leader来保证安全性

== 实际应用
Raft算法被广泛应用于各种分布式系统中，包括：
- *etcd*：Kubernetes的配置存储
- *Consul*：服务发现和配置管理
- *TiKV*：分布式键值存储
- *CockroachDB*：分布式SQL数据库

== 参考资料
- 原始论文：_In Search of an Understandable Consensus Algorithm_ (Diego Ongaro, John Ousterhout, 2013)
- 交互式可视化：https://raft.github.io/
- Raft论文官方网站：https://raft.github.io/


  