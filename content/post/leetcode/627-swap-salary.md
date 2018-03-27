---
title: "LeetCode — 627-swap-salary"
date: 2018-03-26T23:19:17+08:00
tags: []
categories: ["leetcode"]
toc: true
---

leetcode 地址 ：[https://leetcode.com/problems/hamming-distance/](https://leetcode.com/problems/hamming-distance/)

### 题目信息

Given a table salary, such as the one below, that has m=male and f=female values. Swap all f and m values (i.e., change all f values to m and vice versa) with a single update query and no intermediate temp table.
For example:
| id | name | sex | salary |
|----|------|-----|--------|
| 1  | A    | m   | 2500   |
| 2  | B    | f   | 1500   |
| 3  | C    | m   | 5500   |
| 4  | D    | f   | 500    |
After running your query, the above salary table should have the following rows:
| id | name | sex | salary |
|----|------|-----|--------|
| 1  | A    | f   | 2500   |
| 2  | B    | m   | 1500   |
| 3  | C    | f   | 5500   |
| 4  | D    | m   | 500    |

### 解题思路

需要用到 MySQL 的 CASE 语法 https://dev.mysql.com/doc/refman/5.7/en/case.html

### 解法

​	update salary set sex = ( CASE sex WHEN 'm' THEN 'f' ELSE 'm' END )

### 算法应用

可以对数据进行预处理