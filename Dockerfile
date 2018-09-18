FROM openjdk:8-alpine

ARG NAME
ARG VERSION
ARG JAR_FILE

LABEL name=$NAME \
      version=$VERSION

# 安装GOSU
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	apk add --no-cache --virtual .gosu-deps \
		dpkg \
		gnupg \
		openssl \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	apk del .gosu-deps

# 新建用户java-app
RUN set -eux; \
    adduser --home=/home/java-app/ --shell=/bin/sh --disabled-password java-app; \
    adduser java-app java-app; \
    mkdir -p /home/java-app/lib /home/java-app/etc /home/java-app/logs /home/java-app/tmp; \
    chown -R java-app:java-app /home/java-app

# 设定操作系统时区
ENV TZ=Asia/Shanghai
RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

COPY --chown=java-app:java-app docker-entrypoint.sh /home/java-app/docker-entrypoint.sh
COPY --chown=java-app:java-app target/${JAR_FILE} /home/java-app/lib/app.jar

RUN chmod +x /home/java-app/docker-entrypoint.sh
ENTRYPOINT ["/home/java-app/docker-entrypoint.sh"]

EXPOSE 8080
