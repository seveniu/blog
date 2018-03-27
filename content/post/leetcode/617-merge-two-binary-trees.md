---
title: "LeetCode — 617-merge-two-binary-trees"
date: 2018-03-27T23:21:00+08:00
tags: []
categories: ["leetcode"]
toc: true
---

leetcode 地址 ：[https://leetcode.com/problems/merge-two-binary-trees/description/](https://leetcode.com/problems/merge-two-binary-trees/description/)

### 题目信息

Given two binary trees and imagine that when you put one of them to cover the other, some nodes of the two trees are overlapped while the others are not.

You need to merge them into a new binary tree. The merge rule is that if two nodes overlap, then sum node values up as the new value of the merged node. Otherwise, the NOT null node will be used as the node of new tree.

**Example 1:**

```
Input: 
	Tree 1                     Tree 2                  
          1                         2                             
         / \                       / \                            
        3   2                     1   3                        
       /                           \   \                      
      5                             4   7                  
Output: 
Merged tree:
	     3
	    / \
	   4   5
	  / \   \ 
	 5   4   7
```

**Note:** The merging process must start from the root nodes of both trees.

合并两个树，重叠的节点，将值相加后为新的节点，不重叠的节点不变

### 解题思路

二叉树遍历，使用中序遍历。

同时遍历两棵树，重叠相加，不重叠返回一个值。都为空则返回。

### 解法

```java
public TreeNode mergeTrees(TreeNode t1, TreeNode t2) {
    if (t1 == null && t2 == null) {
        return null;
    }
    int val = 0;
    TreeNode t1l = null;
    TreeNode t1r = null;
    TreeNode t2l = null;
    TreeNode t2r = null;
    if (t1 != null ) {
        val += t1.val;
        t1l = t1.left;
        t1r = t1.right;
    }
    if (t2 != null ) {
        val += t2.val;
        t2l = t2.left;
        t2r = t2.right;
    }
    TreeNode root = new TreeNode(val);
    root.left = mergeTrees(t1l, t2l);
    root.right = mergeTrees(t1r, t2r);
    return root;
}
```

上面的这个方法，对新生成的树上的节点都是 new 出来的新的对象。如果要复用原来的节点，可以用下面的解法：

```java
public TreeNode mergeTrees(TreeNode t1, TreeNode t2) {
    if (t1 == null && t2 != null) {
        return t2;
    }
    if (t1 != null && t2 == null) {
        return t1;
    }
    if (t1 != null && t2 != null) {
        TreeNode root = new TreeNode(t1.val + t2.val);
        root.left = mergeTrees(t1.left, t2.left);
        root.right = mergeTrees(t1.right, t2.right);
        return root;
    }
    
    return null;
}
```



### 算法应用



### 知识点扩展

二叉树的深度优先搜索算法：前序遍历，中序遍历，后序遍历。根据根节点遍历的位置区分。

wiki: [https://zh.wikipedia.org/wiki/树的遍历#广度优先遍历](https://zh.wikipedia.org/wiki/%E6%A0%91%E7%9A%84%E9%81%8D%E5%8E%86#%E5%B9%BF%E5%BA%A6%E4%BC%98%E5%85%88%E9%81%8D%E5%8E%86)