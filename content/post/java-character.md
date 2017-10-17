---
title: "Java String Structure"
date: 2017-09-07T11:52:38+08:00
tags: ["string","encode"]
categories: ["jvm"]
toc: true
---



### Java 中字符如何存储

Java 中的字符信息是基于  Unicode 的  java 8 中对应的 Unicode 版本是 6.2.0，用 utf-16 编码的 16bit 的码元(code unit) 序列表示的。

<!--more-->

#### 为什么是 utf-16

java 中的 char 类型是基于原始的 Unicode 标准，那时的 Unicode 字符是固定长度的 16bit。这时 java 可以用 char 表示Unicode 中的所有字符。编码是用的 USC2。
后来 Unicode 允许字符长度超过 16 bit，扩展了辅助字符平面，单个 char 就无法表示所有的字符。 java 从 java se 5.0 开始支持辅助字符平面，并规定一个 char 表示 一个 utf-16 的码元(code unit)，并且增加了新的 api，用于访问 code point

[具体参考](http://www.oracle.com/us/technologies/java/supplementary-142654.html)



#### 怎么存 utf-16

和 utf-16 的规定一样。BMP 范围内，用一个 char 表示，值与 Unicode 的值一样；辅助字符平面用，用两个（一对）char 表示



### Java 语言中一个字符占几个字节？

看完上面的分析，这个问题应该就可以很容易的答上来了：一个字符占用 16 bit 或者 32 bit。

然而这个回答还是不准确的。

1. 在 java 6 的时候，有一个 `压缩字符串（-XX:+UseCompressedString）` 的 功能。

      > 当整个字符串所有字符都在ASCII编码范围内时，就使用byte[]（ASCII序列）来存储，否则用 char[]

      这个功能只在 sun jdk 6 中提供，没有包含在OpenJDK6、Oracle JDK7/OpenJDK7里

    * 实现不够理想，实现太复杂而效果未如预期的好
    * 这部分实现没有开源

2. 即将出来的 java 9 ，带来了新的特性 [compact strings](http://openjdk.java.net/jeps/254)

    > String 以及相关的类（AbstractStringBuilder，StringBuilder，StringBuffer）中用 bype array + encode-flag 替换 char array 

### 需要的知识储备

* [Unicode](https://zh.wikipedia.org/wiki/Unicode)
  * [字符平面](https://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84)
    * 基本字符平面(Basic Multilingual Plane (BMP) ，又称为`0号平面`)
      * 范围U+0000 ~ U+FFFF
    * 辅助字符平面​
      * 共有16个辅助平面
      * 范围U+10000 ~ U+10FFFF 
* [Utf-16](https://zh.wikipedia.org/wiki/UTF-16#UTF-16.E8.88.87UCS-2.E7.9A.84.E9.97.9C.E4.BF.82)
  * ​utf-16 是 unicode的实现方式，码元 为 16位整数
  * 实现方式
     * 0号平面内，用  16byte （单个码元 code unit） 表示 对应的 Unicode 码点（code point）
     * 辅助平面，用 一对16比特长的码元 表示 对应的 Unicode 码点（code point）
  * self-synchronizing 特性

------

参考：

[https://docs.oracle.com/javase/8/docs/api/java/lang/Character.html](https://docs.oracle.com/javase/8/docs/api/java/lang/Character.html)

[http://www.oracle.com/us/technologies/java/supplementary-142654.html](http://www.oracle.com/us/technologies/java/supplementary-142654.html)

[http://docs.oracle.com/javase/specs/jls/se8/html/jls-3.html#jls-3.1](http://docs.oracle.com/javase/specs/jls/se8/html/jls-3.html#jls-3.1)

[https://www.zhihu.com/question/27562173/answer/37188642](https://www.zhihu.com/question/27562173/answer/37188642)

[https://zh.wikipedia.org/wiki/Unicode](https://zh.wikipedia.org/wiki/Unicode)

[https://zh.wikipedia.org/wiki/UTF-16#UTF-16.E8.88.87UCS-2.E7.9A.84.E9.97.9C.E4.BF.82](https://zh.wikipedia.org/wiki/UTF-16#UTF-16.E8.88.87UCS-2.E7.9A.84.E9.97.9C.E4.BF.82)