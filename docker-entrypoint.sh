#!/bin/sh

set -ex;

/usr/bin/java \
  $JAVA_OPTS \
  -Djava.io.tmpdir="/home/java-app/tmp" \
  -jar \
  /home/java-app/lib/app.jar \
  "$@"
