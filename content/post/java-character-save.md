---
title: "Java 中 String 存在哪"
date: 2017-09-10T18:19:49+08:00
tags: ["jvm", "string"]
categories: ["jvm"]
toc: true
---
### 字符串驻留
什么是字符串驻留[wiki](https://en.wikipedia.org/wiki/String_interning)

    Incomputer science, string interning is a method of storing only onecopy of each distinct string value, which must be immutable. Interning strings makes some stringprocessing tasks more time- or space-efficient at the cost of requiring moretime when the string is created or interned. The distinct values are stored ina string intern pool. 
    在计算机科学中， string interning (字符串驻留) 是一种只存储不同的字符串的值的拷贝的方法，它必须是不可变的。字符串驻留使一些字符串处理任务节省更多的时间和空间，但是代价是需要更多的时间用在字符串的创建或者驻留上。这些不同的字符串值会存储在一个 string intern pool (字符串驻留池)里面。
    
    很多现代的语言都支持字符串驻留，例如python,php(从5.4开始),Lua,Ruby,Java和.Net这些语言都使用了字符串驻留

### java 驻留实现
java String 使用 String.intern 实现驻留。

1. 同一个字符串常量，在常量池只有一份副本；
2. 通过双引号声明的字符串，直接保存在常量池中；
3. 如果是String对象，可以通过String.intern方法，把字符串常量保存到常量池中；

具体请查看这篇文章[Stirng.intern 具体实现(hotspot 1.7)](http://www.jianshu.com/p/c14364f72b7e)



不同 jdk 版本实现的区别

| java 版本 | 字符串池位置      | 池默认大小                        | 是否复制 String 实例 |
| ------- | ----------- | ---------------------------- | -------------- |
| 6       | 永久代 pernGen | 1009                         | 是              |
| 7       | 堆 heap      | 7-7u40: 1009 / 7u40-8: 60013 | 否              |
| 8       | 堆 heap      | 60013                        | 否              |

根据JVM规范的定义它必须存在于Java heap中，所以 String 对象是在 heap 中。

### String 字面量如何实现驻留

> java 中 String 字面值 是驻留的。[$jls-3.10.5](https://docs.oracle.com/javase/specs/jls/se8/html/jls-3.html#jls-3.10.5)

#### String 字面量在类文件中的存储

首先了解一下java class file，在 class file 中有常量池`constant pool` 用来存储 class 文件中的 常量，其中包括字符串常量，字符串常量存储在 `CONSTANT_String_info` 结构中。

> [jvm 类文件规范](http://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4)
>
> [实例分析JAVA CLASS的文件结构](https://coolshell.cn/articles/9229.html)

#### 类文件加载

在 jvm load class 时，会对类文件中 `CONSTANT_String_info` 引用的字符串进行检查，执行以下操作

- 如果`CONSTANT_String_info` 引用的字面量的相同字符串已经执行过 `String.intern`，那么该字面量将引用到相同字符串的实例
- 否则`CONSTANT_String_info` 引用的字面量将会创建新的实例，并调用新实例的 `intern` 方法

[java class load](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-5.html#jvms-5.1)



#### String 常量是么时候进入字符串常量池

String 的常量并不是立即调用 intern 方法进入常量池的。

具体看[Java 中new String("字面量") 中 "字面量" 是何时进入字符串常量池的?](https://www.zhihu.com/question/55994121/answer/147296098)


### 其他相关文章：
[关于Java内存分配的一道题?](https://www.zhihu.com/question/38881695/answer/78650273)

[为什么Java中的密码优先使用 char[] 而不是String？](https://www.zhihu.com/question/36734157)

[How many Objects created with: String str=new String("Hello")？](http://www.ciaoshen.com/java/2016/07/29/string.html)

