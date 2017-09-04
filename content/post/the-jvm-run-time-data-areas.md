---
title: "JVM 中规定的运行时数据区域"
date: 2017-08-28T17:02:18+08:00
tags: ["jvm"]
categories: ["jvm"]
toc: true
---

## 概述

Java虚拟机定义了在执行程序期间使用的各种运行时数据区域。

* The pc Register -- 程序计数器
* java virtual machine stacks -- 虚拟机栈
* Heap -- 堆
* method area -- 方法区
* Run-Time Constant Pool -- 运行时常量池
* native method stacks -- 本地方法栈

一图胜千言

![](http://ww1.sinaimg.cn/large/9ce9f97aly1fizklxpy51j209e0agdfz.jpg)
![](http://ww1.sinaimg.cn/large/9ce9f97aly1fizkftkgllj20or0g3q3h.jpg)

## 各部分详细分析
### The pc Register -- 程序计数器

* 每个线程都有自己的线程计数器
* 作用
  * 记录当前执行的虚拟机指令的地址
  * 如果当前方法是 native 的，计数器的值为 undefined

### Java Virtual Machine stack java -- 虚拟机栈
* 当创建线程的同时，会创建该线程私有的的java 虚拟机栈
* 作用
  * 存储栈帧（frame）
* 虚拟机栈在内存中不是必须连续的空间
* 虚拟机栈的大小可以是固定的(看下面OOME中 R大回答的图片)，也可以是动态的
  * HotSpot 栈是固定大小的默认大小（-XX:ThreadStackSize=512）

      http://www.oracle.com/technetwork/articles/java/vmoptions-jsp-140102.html
  * 参考R大的[回答](https://www.zhihu.com/question/27844575/answer/38370294)
* HotSpot 具体实现
  * 以Oracle JDK / OpenJDK的HotSpot VM为例，它使用所谓的“mixed stack”——在同一个调用栈里存放Java方法的栈帧与native方法的栈帧，所以每个Java线程其实只有一个调用栈，融合了JVM规范的JVM栈与native方法栈这俩概念。[摘自R大的回答](https://www.zhihu.com/question/29833675/answer/82661572)
* 两个异常
  * 如果计算需要的空间大小比允许的栈空间更大，那么抛出 StackOverflowError
  * 如果可以动态扩展栈，尝试扩展的时候，但是内存不足以实现扩展；或者没有内存可以用来创建新的栈，那么抛出 OutOfMemoryError

          > 书中以及其他博客经常表达成深度，个人感觉不太合适，其实是限制的大小，深度只是经常对递归调用而言的

  * 关于 oome R大的回答

      ![](http://ww1.sinaimg.cn/large/9ce9f97aly1fiylemchg4j20my0c2jun.jpg)
      -Xss配置的是栈大小，不是栈帧￼数量。
题主的问题其实要针对特定JVM实现问才有意义。
有采用固定栈大小的JVM实现，也有采用动态增减栈大小的JVM实现。前者如HotSpot VM，后者如Classic VM。
前者的话，整个栈都是在Java线程创建时分配的，如果那个时候分配不到足够空间，就会抛OutOfMemoryError，此时该线程尚未执行任何Java方法。如果一个Java线程已经成功创建出来，那它就不会在运行时因为栈内存不足而抛OOME，而只会在用尽了栈空间时抛StackOverflowException。
后者的话，栈是一段一段慢慢分配出来的，如果当前段已经用完了要申请新的段时得不到足够空间，也会抛OOME。这种VM如果没用到-Xss上限就遇到分配不到新的段的状况会抛OOME，否则如果已经达到了-Xss上限会抛StackOverflowException。
​
* java 虚拟机栈在内存中的位置

    ![](http://ww1.sinaimg.cn/large/9ce9f97aly1fiylfver7sj20n40bswhk.jpg)
HotSpot VM在native memory里分配Java线程栈，没有分配上限，一直能分配到耗尽native内存（无论是虚拟内存还是虚拟内存地址空间）。​

### frame 帧
* 用来存储数据，部分结果，执行动态链接，返回方法的结果，发送异常
* 执行方法时创建 frame ，方法执行完毕时销毁 frame
* frame 是从对应的线程的 stack 中创建并分配
* frame 有自己的局部变量数组，操作数栈，常量池的引用，方法调用时同时分配这些结构的内存。
  * 局部变量表
    * 一个局部变量保存（boolean, byte, char, short, int, float, reference, or returnAddress）
    * 一对局部变量保存（long or double）
    * 基本类型，引用，返回地址
    * 局部变量表通过索引访问，从 0 开始
    * long 或者 double 占用两个位置，第二个位置无法索引
    * 局部变量的第一个参数是用于存储方法的参数的引用
  * 操作数栈
    这篇文章说的很好，[参考](http://wangwengcn.iteye.com/blog/1622195)

  * Dynamic Linking
       
       看不懂
### Heap -- 堆
* jvm 有一个共享给所有 jvm 线程的堆。
* 运行时数据区域，该区域用于非配所有类的实例和数组
* 在 jvm 启动时创建
* 自动存储管理系统（称为垃圾收集器）回收堆存储;
* 对象不能显示回收
* jvm 的没有指定具体的"自动内存管理系统"，不同的jvm可以有不同的实现
* 堆的大小可以是固定的，也可以是动态扩展和收缩的
* 堆内存可以是不连续的
* 没有更多的内存可用时，抛出 OutOfMemoryError 

### method area -- 方法区
* jvm 有一个共享给所有 jvm 线程的方法区。
* 存储 类的结构
  * 运行时常量池
  * 字段
  * 方法
  * 构造函数
  * 方法和构造函数的代码
* 方法区在 jvm 启动时创建
* 本规范（Java SE 8）不规定方法区域的位置或用于管理编译代码的策略。
* 大小可以是固定的，也可以是动态扩展和收缩的
* 内存可以是不连续的
* 具体实现
  * HotSpot -- 永久代 PermGen（ java 8 元空间 MetaSpace）是Hotspot虚拟机特有的概念，是方法区的一种实现
* 参考[这个回答](https://www.zhihu.com/question/49044988/answer/113961406)中 R大的评论会有更清楚的认识

    ![](http://ww1.sinaimg.cn/large/9ce9f97aly1fj0eq6kusjj20g60nx7c1.jpg)

### Run-Time Constant Pool -- 运行时常量
运行时常量池是类文件中的constant_pool表的每类或每个接口运行时表示形式

    类文件格式参考：http://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4
常量池是分配在 jvm 的方法区
常量池是在 jvm 创建 class 或者 interface 是创建
OutOfMemoryError
### native method stacks -- 本地方法栈
* 作用
  * native 方法执行
