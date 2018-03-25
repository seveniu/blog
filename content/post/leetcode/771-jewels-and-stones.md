---
title: "LeetCode -- 771 : Jewels and Stones"
date: 2018-03-22T22:07:51+08:00
tags: []
categories: ["leetcode"]
toc: true
---

## 771. Jewels and Stones

leetcode 地址 ：[https://leetcode.com/problems/jewels-and-stones/description/](https://leetcode.com/problems/jewels-and-stones/description/)

题目：

    You're given strings `J` representing the types of stones that are jewels, and `S` representing the stones you have.  Each character in `S`is a type of stone you have.  You want to know how many of the stones you have are also jewels.
    
    The letters in `J` are guaranteed distinct, and all characters in `J` and `S` are letters. Letters are case sensitive, so `"a"` is considered a different type of stone from `"A"`.
    
    **Example 1:**
    
    ​```
    Input: J = "aA", S = "aAAbbbb"
    Output: 3
    ​```
    
    **Example 2:**
    
    ​```
    Input: J = "z", S = "ZZ"
    Output: 0
    ​```
    
    **Note:**
    
    - `S` and `J` will consist of letters and have length at most 50.
    - The characters in `J` are distinct.

#### 解法1：

关键词：遍历

特点：没特点

时间复杂度：O(MN)

```java
char[] JChars = J.toCharArray();
char[] SChars = S.toCharArray();
int count = 0;
for (char jChar : JChars) {
    for (char sChar : SChars) {
        if (sChar == jChar) {
            count++;
        }
    }
}
return count;
```

#### 解法2：

关键词：Set

特点：复杂度低

时间复杂度：O(M+N)

```java
Set<Character> jSet = new HashSet<>();
for (char c : J.toCharArray()) {
    jSet.add(c);
}
int count = 0;
for (char c : S.toCharArray()) {
    if (jSet.contains(c)) {
        count++;
    }
}
return count;
```

Java8 实现:

```java
Set<Integer> collect = J.chars().boxed().collect(Collectors.toSet());
return (int) S.chars().boxed().filter(collect::contains).count();
```

#### 解法3：

关键词：indexOf

特点：速度最快

```java
int jewelTot = 0;
for(char stone : S.toCharArray()){
    if(J.indexOf(stone) != -1) jewelTot++;
}
return jewelTot;
```

#### 解法4：

关键词：ASCII

特点：应该是优化最好的算法，空间复杂度为 O(1)

时间复杂度：O(M+N) 

```java
int[] chars = new int[52];
int length = J.length();
for (int i = 0; i < length; i++) {
    char c = J.charAt(i);
    if (c <= 'Z' && c >= 'A') {
        chars[c - 'A' + 26]++;
    } else {
        chars[c - 'a']++;
    }
}

int count = 0;
for (int i = 0, len = S.length(); i < len; i++) {
    char c = S.charAt(i);
    if (c <= 'Z' && c >= 'A' && chars[c - 'A' + 26] > 0) {
        count++;
    } else if (c <= 'z' && c >= 'a' && chars[c - 'a'] > 0) {
        count++;
    }
}
return count;
```

