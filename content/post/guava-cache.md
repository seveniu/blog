---
title: "Guava Cache 的刷新机制"
date: 2017-09-12T22:07:51+08:00
tags: ["guava cache", "cache"]
categories: ["guava"]
toc: true
---
在工作时遇到一个缓存的场景，使用了 Guava cache。使用过程中有一些疑惑，顺便记录一下。

具体的使用就不说了，可以看文章最先面的参考文章。

这篇文章主要说一下 Guava cache 的刷新。
<!--more-->

### 什么时候刷新
官方文档上说：

    a refresh will only be actually initiated when the entry is queried.. 

刷新只在查询需要刷新的对象时才会启动刷新。

看下面的例子，设置 `6s` 刷新，load 需要 `1s`

```java
LogTime logTime = new LogTime();
AtomicInteger value = new AtomicInteger();
LoadingCache<String, String> cb = CacheBuilder.newBuilder()
        .maximumSize(1000)
        .refreshAfterWrite(6, TimeUnit.SECONDS)
        .removalListener((RemovalListener<String, String>) notification -> {
            logTime.log("remove key : " + notification.getKey() + ", value : " + notification.getValue() + ", cause  " + notification.getCause());
        })
        .build(new CacheLoader<String, String>() {
            public String load(String key) { // no checked exception
                String newValue = String.valueOf(value.getAndIncrement());
                logTime.log("load ");
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                logTime.log("load end ");
                return newValue;
            }
        });
logTime.start();
logTime.log("value : " + cb.get("name"));
TimeUnit.SECONDS.sleep(10);
logTime.log("value : " + cb.get("name"));
``` 

    0s -- main ---- load 
    1s -- main ---- load end 
    1s -- main ---- value : 0
    11s -- main ---- load 
    12s -- main ---- load end 
    12s -- main ---- remove key : name, value : 0, cause  REPLACED
    12s -- main ---- value : 1

结果可以看到 sleep 10秒之间并没有 `load`，而在之后 get 才 load，验证了查询时才更新。

### 异步更新
默认情况刷新是同步的，通过重写 `reload` 方法可以实现异步操作，那么异步操作时 `get` 返回的值是旧值。

     The old value (if any) is still returned while the key is being refreshed


```java
LogTime logTime = new LogTime();
AtomicInteger value = new AtomicInteger();
ExecutorService executor = Executors.newFixedThreadPool(1);
LoadingCache<String, String> cb = CacheBuilder.newBuilder()
        .maximumSize(1000)
        .refreshAfterWrite(6, TimeUnit.SECONDS)
        .removalListener((RemovalListener<String, String>) notification -> {
            logTime.log("remove key : " + notification.getKey() + ", value : " + notification.getValue() + ", cause  " + notification.getCause());
        })
        .build(new CacheLoader<String, String>() {
            public String load(String key) { // no checked exception
                String newValue = String.valueOf(value.getAndIncrement());
                logTime.log("load ");
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                logTime.log("load end ");
                return newValue;
            }
            @Override
            public ListenableFuture<String> reload(String key, String oldValue) throws Exception {
                // asynchronous!
                logTime.log("refresh ");
                ListenableFutureTask<String> task = ListenableFutureTask.create(() -> load(key));
                executor.execute(task);
                return task;
            }
        });
logTime.start();
logTime.log("value : " + cb.get("name"));
TimeUnit.SECONDS.sleep(10);
logTime.log("value : " + cb.get("name"));
TimeUnit.SECONDS.sleep(2);
logTime.log("value : " + cb.get("name"));
```
结果

    0s -- main ---- load 
    1s -- main ---- load end 
    1s -- main ---- value : 0
    11s -- main ---- refresh 
    11s -- pool-1-thread-1 ---- load 
    11s -- main ---- value : 0
    12s -- pool-1-thread-1 ---- load end 
    12s -- pool-1-thread-1 ---- remove key : name, value : 0, cause  REPLACED
    13s -- main ---- value : 1

上面的代码重写 reload 方法。实现异步操作, 对比第一次的结果，可以看到, 刷新用了单独的线程，并且第二次 get 返回的是 `0` 是旧值，刷新操作并没有阻塞线程，刷新操作完成后才返回新值

### refreshAfterWrite 和 expireAfterWrite 同时使用时，entry 是否会过期
如果这个条目可以刷新，但是一直没有查询，时间超过 expire 的时间，那么这个条目就过期了

    So, for example, you can specify both refreshAfterWrite and expireAfterWrite on the same cache, so that the expiration timer on an entry isn't blindly reset whenever an entry becomes eligible for a refresh, so if an entry isn't queried after it comes eligible for refreshing, it is allowed to expire.

```java
LogTime logTime = new LogTime();
AtomicInteger value = new AtomicInteger();
LoadingCache<String, String> cb = CacheBuilder.newBuilder()
        .maximumSize(1000)
        .refreshAfterWrite(6, TimeUnit.SECONDS)
        .expireAfterAccess(10, TimeUnit.SECONDS)
        .removalListener((RemovalListener<String, String>) notification -> {
            logTime.log("remove key : " + notification.getKey() + ", value : " + notification.getValue() + ", cause  " + notification.getCause());
        })
        .build(new CacheLoader<String, String>() {
            public String load(String key) { // no checked exception
                String newValue = String.valueOf(value.getAndIncrement());
                return newValue;
            }
            @Override
            public ListenableFuture<String> reload(String key, String oldValue) throws Exception {
                // asynchronous!
                logTime.log("refresh ");
                ExecutorService executor = Executors.newFixedThreadPool(1);
                ListenableFutureTask<String> task = ListenableFutureTask.create(() -> load(key));
                executor.execute(task);
                return task;
            }
        });
logTime.start();

logTime.log("value : " + cb.get("name"));
TimeUnit.SECONDS.sleep(7);
cb.cleanUp();
logTime.log("size : " + cb.size());
// get
logTime.log("value : " + cb.get("name"));
TimeUnit.SECONDS.sleep(7);
cb.cleanUp();
logTime.log("size : " + cb.size());
```
7s 之后 get 查询的结果

    0s -- main ---- value : 0
    7s -- main ---- size : 1
    7s -- main ---- refresh 
    7s -- main ---- remove key : name, value : 0, cause  REPLACED
    7s -- main ---- value : 1
    14s -- main ---- size : 1

7s 之后没有 get 查询的结果

    0s -- main ---- value : 0
    7s -- main ---- size : 1
    14s -- main ---- remove key : name, value : 0, cause  EXPIRED
    14s -- main ---- size : 0

可以看到没有查询的结果中，数据已经过期清除掉了。

### 总结

1. 查询时才触发 refresh 操作，所以对于查询不是很频繁的操作，刷新的时间可以设置短一些
2. refresh 默认是同步的，需要自己实现 reload 方法改为异步。同步操作阻塞线程，异步操作体验更好，但是刷新时返回的是旧值
3. refreshAfterWrite 和 expireAfterWrite 同时使用，可以避免 entry 一直存在的cache 中
 
[代码文件](https://gist.github.com/seveniu/85aa6c3f81b8f8d6997c2d922b01e34a)

-----
Reference:

[官方文档](https://github.com/google/guava/wiki/CachesExplained)

[官方文档翻译](http://ifeve.com/google-guava-cachesexplained/)

[缓存模式](https://coolshell.cn/articles/17416.html)