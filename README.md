# Java程序制作Docker Image的例子

本例子是一个spring-boot应用，不过本例子适用于所有Java应用。

## 要求

这里先给出一些Docker Image制作的要求，之后我们再看怎么做。

1. 制作过程要融合在项目构建过程中
1. 使用官方Image作为基础Image
1. 设定正确的时区
1. Container内的程序以非root用户启动
1. 指定Web程序的接口
1. 能够传递JVM参数、Java System Properties、程序自定义的参数

下面具体讲一下具体怎么做到以上几点：

### 制作过程要融合在项目构建过程中

这里推荐使用Spotify的[dockerfile-maven-plugin](https://github.com/spotify/dockerfile-maven)，理由是这个plugin用起来最简单且容易掌握。

该plugin的本质上是你写一个Dockerfile（关于Dockerfile的具体写法请参照[官方文档](https://docs.docker.com/engine/reference/builder/)），这个plugin把一些参数传递进去来帮助你构建Docker Image。

因此只要你会写Dockerfile，就会使用这个plugin，它没有加入任何额外的概念。

### 使用官方Image作为基础Image

Java的基础镜像应该在[openjdk repository](https://hub.docker.com/_/openjdk/)里寻找，而不是在已经过时的[java repository](https://hub.docker.com/_/java/)里找。

openjdk repository提供了各种各样的image tags看起来眼花缭乱，但是本质上来说就这么几个：

* openjdk:<version>
* openjdk:<version>-slim
* openjdk:<version>-alpine

比如你可以在Dockerfile这样写：

```txt
FROM openjdk:8-alpine
```

从尺寸上来讲，alpine最小、slim稍大、默认的最大。所以应该尽可能的使用alpine版本的，如果发现程序的运行环境缺少某些东西，那么尝试用slim版本或者默认版本。就目前的经验来讲：

* 如果需要操作系统字体库，那么就得使用slim版本或者默认版本。需要操作系统字体库的程序例如：图片验证码、PDF导出。
* 如果需要某些Linux标准的动态/静态连接库，那么在alpine版本不行的情况下，尝试slim版本或默认版本。因为alpine版本是一个及其精简的Linux，它删除了很多东西。

### 设定正确的时区

几乎所有的Docker Image的时区都是UTC，我们需要给我们自己制作的Docker Image设定时区：

```bash
ENV TZ=Asia/Shanghai
RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone
```

关于数据库时区的相关内容可以见：

* [数据库时区那些事儿 - MySQL的时区处理](https://segmentfault.com/a/1190000016426048)
* [数据库时区那些事儿 - Oracle的时区处理](https://segmentfault.com/a/1190000016436947)

### Container内的程序以非root用户启动

在Docker Image内部，我们应该使用非root用户启动程序，这需要使用到[gosu](https://github.com/tianon/gosu)。

gosu的Dockerfile指南在[这里](https://github.com/tianon/gosu/blob/master/INSTALL.md)。

记得要根据不同的基础Image选择适合的安装方式。

### 指定Web程序的接口

对于联网应用而言，必须在Dockerfile中指定暴露的端口，否则该端口无法映射。

```txt
EXPOSE 8080
```

### 能够传递JVM参数、Java System Properties、程序自定义的参数

我们需要能够在启动Docker Image的时候将一些参数传递进去：

* JVM参数
* Java System Properties
* 程序启动参数

这里就需要参考[Dockerfile best practice][dockerfile-best-practice]和[Docker ENTRYPOINT][docker-endpoint]了。

## 样例项目拆解

### 目录结构

所有与程序相关的东西都存放在`/home/java-app/`下：

```
/home/java-app
   ├── docker-entrypoint.sh
   ├── lib
   │   └── java-app.jar
   ├── etc
   ├── logs
   └── tmp
```

* `docker-entrypoint.sh`，启动脚本
* `lib`，存放JAR包
* `lib/java-app.jar`，程序JAR包
* `etc`，存放配置文件
* `logs`，存放日志文件
* `tmp`，存放临时文件

### 构建Image的方法

```bash
mvn clean package dockerfile:build
```

### 运行

普通启动，然后访问`http://localhost:8080`：

```bash
docker run -p 8080:8080 chanjarster/dockerfile-java-examples-1:1.0-SNAPSHOT
```

设定JVM参数，使用`JVM_OPTS`环境变量：

```bash
docker run -p 8080:8080 -e JVM_OPTS='-Xmx128M -Xms128M' chanjarster/dockerfile-java-examples-1:1.0-SNAPSHOT
```

设定System Properties，使用`JAVA_ARGS`环境变量：

```bash
docker run -p 8080:8080 -e JAVA_ARGS='-Dabc=xyz -Ddef=uvw' chanjarster/dockerfile-java-examples-1:1.0-SNAPSHOT
```

提供程序运行参数，在后面直接添加即可：

```bash
docker run -p 8080:8080 chanjarster/dockerfile-java-examples-1:1.0-SNAPSHOT --debug
```

## 参考文档

* [Dockerfile best practice][dockerfile-best-practice]
* [Docker ENTRYPOINT][docker-endpoint]
* [Postgres Dockerfile & script](https://github.com/docker-library/postgres/tree/3f585c58df93e93b730c09a13e8904b96fa20c58/11)
* [MySQL Dockerfile & script](https://github.com/docker-library/mysql/tree/b39f1e5e4ec82dc8039cecc91dbf34f6c9ae5fb0/8.0)
* [gosu Intall](https://github.com/tianon/gosu/blob/master/INSTALL.md)
* [Bash set命令教程](http://www.ruanyifeng.com/blog/2017/11/bash-set.html)

[docker-endpoint]: https://docs.docker.com/engine/reference/builder/#entrypoint
[dockerfile-best-practice]: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
