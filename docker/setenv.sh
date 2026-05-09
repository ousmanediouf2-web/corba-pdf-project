#!/bin/bash
# Chargé automatiquement par Tomcat au démarrage
export JAVA_OPTS="\
  -Dcorba.host=localhost \
  -Dcorba.port=1050 \
  -DMONGODB_URI=${MONGODB_URI} \
  -Dfile.encoding=UTF-8 \
  -Xmx400m -Xms200m"
