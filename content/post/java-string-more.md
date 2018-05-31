---
title: "Java String 知识点补充以及在 Java 9 中的变化"
date: 2018-05-12T22:07:51+08:00
tags: ["java", "java 9"]
categories: ["java"]
toc: true
---


1. G1 垃圾回收器对字符串的优化

   G1 GC 下的字符串排重。它是通过将相同数据的字符串指向同一份数据。以此来减少内存占用。

   这个功能目前是默认关闭的，你需要使用下面参数开启，并且需要指定使用 G1 GC：

   ```
   -XX:+UseStringDeduplication
   ```

2.  Intrinsic 机制

   是一种利用 native 方式 hard-coded 的逻辑，算是一种特别的内联，很多优化还是需要直接使用特定的 CPU 指令。

   Intrinsic方法简单的说就是jvm对某些声明为了intrinsic的方法进行特殊的处理，不按照java里提供的代码逻辑或者jni里的实现，而是按照特定平台优化后的指令来处理。

   这个机制不仅仅作用于 String。

3. Compact Strings 的设计

   Java 9 中引入 Compact Strings 的设计，将数据存储方式从 char 数组，改变为一个 byte 数组加上一个标识编码的所谓 coder。

   如果String只包含 Latin1 字符，coder 就标示为 `LATIN1`，如果String含有  Latin1 字符之外的字符，coder 就标示为 `UTF16`。

   新增了两个类：`StringLatin1`，`StringUTF16` 分别处理不同编码情况下的操作。