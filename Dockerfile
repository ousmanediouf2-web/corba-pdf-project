# ═══════════════════════════════════════════════════════
# Dockerfile - CORBA PDF Service
# Compatible Render.com (Free tier)
# Les stubs CORBA sont générés par Maven (exec-maven-plugin)
# ═══════════════════════════════════════════════════════

# ── Étape 1 : Build ─────────────────────────────────
FROM eclipse-temurin:8-jdk AS builder

WORKDIR /build

# Installer Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copier TOUT le projet
COPY idl/           ./idl/
COPY corba-server/  ./corba-server/
COPY web-app/       ./web-app/

# Vérifier que idlj est disponible (inclus dans JDK 8)
RUN idlj -version 2>&1 || echo "idlj disponible"

# Compiler le serveur CORBA
# Maven génère automatiquement les stubs IDL via exec-maven-plugin
# puis les compile avec le reste du code
RUN cd corba-server && mvn clean package -DskipTests

# Compiler l'application web
# Même chose : Maven génère les stubs client IDL puis compile
RUN cd web-app && mvn clean package -DskipTests

# ── Étape 2 : Image finale ───────────────────────────
FROM eclipse-temurin:8-jre

ENV TOMCAT_VERSION=9.0.82
ENV CATALINA_HOME=/opt/tomcat
ENV JAVA_HOME=/opt/java/openjdk

# Installer Tomcat + Supervisor
RUN apt-get update && apt-get install -y wget supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} ${CATALINA_HOME} && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm -rf ${CATALINA_HOME}/webapps/ROOT \
           ${CATALINA_HOME}/webapps/examples \
           ${CATALINA_HOME}/webapps/docs \
           ${CATALINA_HOME}/webapps/manager \
           ${CATALINA_HOME}/webapps/host-manager

# Copier le JAR du serveur CORBA
COPY --from=builder \
    /build/corba-server/target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar \
    /app/corba-server.jar

# Copier le WAR de l'application web
COPY --from=builder \
    /build/web-app/target/corba-pdf-app.war \
    ${CATALINA_HOME}/webapps/ROOT.war

# Copier les configs
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/setenv.sh        ${CATALINA_HOME}/bin/setenv.sh
COPY docker/start.sh         /start.sh

RUN chmod +x ${CATALINA_HOME}/bin/setenv.sh /start.sh && \
    mkdir -p /var/log/supervisor

EXPOSE 8080

CMD ["/start.sh"]
