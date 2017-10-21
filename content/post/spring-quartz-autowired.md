---
title: "Spring 中使用 Quartz 时，Job 无法注入spring bean的问题"
date: 2017-10-20T17:12:01+08:00
tags: ["quartz","spring"]
categories: ["quartz"]
toc: true
---

Quartz 中 Job 是通过反射出来的实例，不受spring的管理，所以就导致Job 中无法注入 spring 的 bean。
#### 解决方案
Quartz 中有一个 `JobFactory` 接口，负责生成Job类的实例。

这个接口可能对那些希望通过某种特殊机制使其应用程序产生Job实例的用户，例如给予依赖注入的操作性。

我们需要做的就是实现一个 `JobFactory` 接口的类，实现依赖注入。

<!--more-->

##### 在 spring 中 如果没有依赖 `spring-context-support`的情况

```java
@Service
public class QuartzService implements ApplicationContextAware {

    private transient ApplicationContext applicationContext;

    public Scheduler getScheduler() throws SchedulerException {
        SchedulerFactory schedulerFactory = new org.quartz.impl.StdSchedulerFactory();
        Scheduler scheduler = schedulerFactory.getScheduler();
        AutowiringSpringBeanJobFactory autowiringSpringBeanJobFactory = new AutowiringSpringBeanJobFactory();
        autowiringSpringBeanJobFactory.setApplicationContext(applicationContext);
        scheduler.setJobFactory(autowiringSpringBeanJobFactory);
        return scheduler;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }

  	// 自定义实现 JobFactory
    class AutowiringSpringBeanJobFactory extends AdaptableJobFactory {
        private transient AutowireCapableBeanFactory autowireCapableBeanFactory;

        public void setApplicationContext(final ApplicationContext context) {
            autowireCapableBeanFactory = context.getAutowireCapableBeanFactory();
        }

        @Override
        public Object createJobInstance(final TriggerFiredBundle bundle) throws Exception {
            final Object job = super.createJobInstance(bundle);
            autowireCapableBeanFactory.autowireBean(job);  //the magic is done here
            return job;
        }
    }
}
```

##### 在 spring 中 有依赖 `spring-context-support`的情况

```java
@Component
public class SpringJobFactory extends AdaptableJobFactory {

    @Autowired
    private AutowireCapableBeanFactory capableBeanFactory;

    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        Object jobInstance = super.createJobInstance(bundle);
        capableBeanFactory.autowireBean(jobInstance);
        return jobInstance;
    }
}
```
```java
@Configuration
public class SchedulerConfig {
    @Autowired
    private SpringJobFactory springJobFactory;

    @Bean
    public SchedulerFactoryBean schedulerFactoryBean() {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();
        schedulerFactoryBean.setJobFactory(springJobFactory);
        return schedulerFactoryBean;
    }
}
```


因为 `SchedulerFactoryBean` 是 [FactoryBean](https://spring.io/blog/2011/08/09/what-s-a-factorybean) 因此，在使用的时候，可以直接注入 `Scheduler` 进行下一步操作。