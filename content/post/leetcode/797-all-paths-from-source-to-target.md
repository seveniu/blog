---
title: "LeetCode -- 797-all-paths-from-source-to-target"
date: 2018-03-24T23:01:37+08:00
tags: []
categories: ["leetcode"]
toc: true
---

leetcode 地址 ：[https://leetcode.com/problems/hamming-distance/](https://leetcode.com/problems/hamming-distance/)

### 题目信息

Given a directed, acyclic graph of `N` nodes.  Find all possible paths from node `0` to node `N-1`, and return them in any order.

The graph is given as follows:  the nodes are 0, 1, ..., graph.length - 1.  graph[i] is a list of all nodes j for which the edge (i, j) exists.

```
Example:
Input: [[1,2], [3], [3], []] 
Output: [[0,1,3],[0,2,3]] 
Explanation: The graph looks like this:
0--->1
|    |
v    v
2--->3
There are two paths: 0 -> 1 -> 3 and 0 -> 2 -> 3.
```

**Note:**

- The number of nodes in the graph will be in the range `[2, 15]`.
- You can print different paths in any order, but you should keep the order of nodes inside one path.

### 题目解释

有一个有向无环的图，有 N 个节点，找到从第一个节点到最后一个节点，所有可能的路径。

已知每个节点每个节点可以到达的下一个节点，用二维数组表示 节点 i 可以到达节点 [j, k]

### 结题思路

以 `[[1,2], [3], [3], []]`  为例。

1. 0 节点 可以到达 1， 2 节点，那么就继续看 1，2 节点
2. 1 节点可以到达 3 。3 是最后一个节点，得到 0 -> 1 -> 3 路径
3. 继续看 2 节点， 2 节点可以到达 3 节点。3 是最后一个节点，得到 0 -> 2 -> 3 路径

上面的示例比较简单，仔细分析一下过程：

1. 从 0 节点开始，设置 0 节点为 x 节点
2. 查看 x 节点的可到达节点，如果其中一个可达节点是 `N-1` 节点，那么找到一条路径，记录下来，继续查看其他节点，将其他节点依次设为 x 节点，重复步骤 2 。

可以看出是一个深度优先搜索。

### 解法

在这里使用 递归的解法：

```java
public static List<List<Integer>> allPathsSourceTarget(int[][] graph) {
    List<List<Integer>> result = new ArrayList<>();
    List<Integer> first = new ArrayList<>();
    first.add(0);
    result.add(first);
    dfs(result, graph, first);
    return result;
}

public static void dfs(List<List<Integer>> result, int[][] graph, List<Integer> path) {
    int index = path.get(path.size() - 1);
    int[] cur = graph[index];
    if (cur.length == 0) {
        return;
    }
    for (int i = 1; i < cur.length; i++) {
        List<Integer> list = new ArrayList<>(path);
        result.add(list);
        int nextIndex = cur[i];
        list.add(nextIndex);
        dfs(result, graph, list);
    }
    path.add(cur[0]);
    dfs(result, graph, path);
}
```

### 算法应用

如果节点之间再加上距离参数，就可以把问题改成求两个点最短路径的问题。

### 扩展话题

#### jvm 栈大小

[Java HotSpot VM Options](https://link.zhihu.com/?target=http%3A//www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)

Thread Stack Size (in Kbytes). (0 means use default stack size) [Sparc: 512; Solaris x86: 320 (was 256 prior in 5.0 and earlier); Sparc 64 bit: 1024; Linux amd64: 1024 (was 0 in 5.0 and earlier); all others 0.]

#### java 尾递归

TODO...