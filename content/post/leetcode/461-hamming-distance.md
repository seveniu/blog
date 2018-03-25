---
title: "LeetCode -- 461-hamming-distance"
date: 2018-03-23T21:03:31+08:00
tags: []
categories: ["leetcode"]
toc: true
---

### 题目信息

leetcode 地址 ：[https://leetcode.com/problems/hamming-distance/](https://leetcode.com/problems/hamming-distance/)

The [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) between two integers is the number of positions at which the corresponding bits are different.

Given two integers `x` and `y`, calculate the Hamming distance.

**Note:**
0 ≤ `x`, `y` < 231.

**Example:**

```
Input: x = 1, y = 4

Output: 2

Explanation:
1   (0 0 0 1)
4   (0 1 0 0)
       ↑   ↑

The above arrows point to positions where the corresponding bits are different.
```

### 汉明距离

在[信息论](https://zh.wikipedia.org/wiki/%E4%BF%A1%E6%81%AF%E8%AE%BA)中，两个等长[字符串](https://zh.wikipedia.org/wiki/%E5%AD%97%E7%AC%A6%E4%B8%B2)之间的**汉明距离**（英语：Hamming distance）是两个字符串对应位置的不同字符的个数。换句话说，它就是将一个字符串变换成另外一个字符串所需要*替换*的字符个数。

还有一个概念：**汉明重量**是字符串相对于同样长度的零字符串的汉明距离，也就是说，它是字符串中非零的元素个数：对于[二进制](https://zh.wikipedia.org/wiki/%E4%BA%8C%E8%BF%9B%E5%88%B6)[字符串](https://zh.wikipedia.org/wiki/%E5%AD%97%E7%AC%A6%E4%B8%B2)来说，就是1的个数，所以11101的汉明重量是4。

### 解题

对于本题来说，求是两个 int 值的汉明距离，其实就是求 俩个 int 值在`二进制`形式下，对应位置的不同字符的个数。

#### 首先复习一下 二进制 

java 中 int 二进制是 32 位，其中第一位 是 `符号位` ，0 表示正数，1表示负数

二进制操作：

    ~   按位取反
    &   按位与
    ^   按位异或
    |   按位或
    >>  右移位
    <<  左移位
    >>> 无符号右移运算符

#### 通过以上的知识，我们可以得出以下的思路

1. 通过 `^` 按位异或可以得到 相同位为 1 ，不同的位为 0 的二进制结果。
2. 根据上一步得到的结果，我们需要将 1 的个数计算出来。题目中数字的范围为正数，所以我们可以考虑用 `<<` 左移操作，遍历一下结果，出现负数的个数就是 1 的个数。

#### 代码

```java
    public static int hammingDistance(int x, int y) {
        int a = x ^ y;
        int count = 0;
        for (int i = 0; i < 32; i++) {
            a = a << 1;
            if (a < 0) {
                count++;
            }
        }
        return count;
    }
```


