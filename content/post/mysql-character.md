---
title: "Mysql Character"
date: 2017-09-04T11:45:29+08:00
tags: ["Mysql", "Character"]
categories: ["Mysql"]
toc: true
---

### Mysql 的字符集

    Character Set 是存储字符集
    Collation 是排序字符集

<!--more-->
### Character Set

#### `utf8`, `utf8mb4` 选择

* MySQL里实现的utf8最长使用3个字节，也就是只支持到了 Unicode 中的 基本多文本平面（U+0000至U+FFFF），包含了控制符、拉丁文，中、日、韩等绝大多数国际字符，但并不是所有，最常见的就算现在手机端常用的表情字符 emoji和一些不常用的汉字，如 “墅” ，这些需要四个字节才能编码出来。
* MySQL里实现的utf8mb4最长使用4个字节，U+0000至U+FFFF 用3个字节，0x10000至0x10FFFF 用4个字节

> utf8mb4 可以看作是 utf8 的超集，U+0000至U+FFFF 的字符同样是占用3个字节，因此通常情况下设置为 utf8mb4

### Collation

#### `utf8mb4_unicode_ci`, `utf8mb4_general_ci` 选择

* 唯一的区别是在 排序和比较方面
* 排序（比较）准确性
    * utf8mb4_unicode_ci 是基于标准的Unicode来排序和比较，能够在各种语言之间精确排序
    * utf8mb4_general_ci 没有实现Unicode排序规则，在遇到某些特殊语言或字符是，排序结果可能不是所期望的。
* 性能
    * utf8mb4_general_ci 理论上更快，提升意义不大

> 推荐使用 utf8mb4_unicode_ci

------

### 参考

[http://seanlook.com/2016/10/23/mysql-utf8mb4/](http://seanlook.com/2016/10/23/mysql-utf8mb4/)

[https://dev.mysql.com/doc/refman/5.7/en/charset-unicode-utf8mb4.html](https://dev.mysql.com/doc/refman/5.7/en/charset-unicode-utf8mb4.html)

[https://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci](https://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci)

