# ═══════════════════════════════════════════════════════
# Dockerfile - CORBA PDF Service
# Compatible Render.com (Free tier)
# Lance : orbd (NameService) + Serveur CORBA + Tomcat
# ═══════════════════════════════════════════════════════

# ── Étape 1 : Build ─────────────────────────────────
FROM eclipse-temurin:8-jdk AS builder

WORKDIR /build

# Installer Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copier les sources
COPY idl/           ./idl/
COPY corba-server/  ./corba-server/
COPY web-app/       ./web-app/

# Générer les stubs CORBA depuis l'IDL
RUN mkdir -p corba-server/src/main/java/pdfservice \
    && mkdir -p web-app/src/main/java/pdfservice \
    && idlj -fall    -td corba-server/src/main/java idl/PDFService.idl \
    && idlj -fclient -td web-app/src/main/java      idl/PDFService.idl

# Compiler le serveur CORBA (JAR)
RUN cd corba-server && mvn clean package -DskipTests -q

# Compiler l'application web (WAR)
RUN cd web-app && mvn clean package -DskipTests -q

# ── Étape 2 : Image finale ───────────────────────────
FROM eclipse-temurin:8-jre

# Variables d'environnement
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

# Copier les artefacts buildés
COPY --from=builder \
    /build/corba-server/target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar \
    /app/corba-server.jar

COPY --from=builder \
    /build/web-app/target/corba-pdf-app.war \
    ${CATALINA_HOME}/webapps/ROOT.war

# Copier les fichiers de configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/setenv.sh        ${CATALINA_HOME}/bin/setenv.sh
COPY docker/start.sh         /start.sh

RUN chmod +x ${CATALINA_HOME}/bin/setenv.sh /start.sh && \
    mkdir -p /var/log/supervisor

# Port exposé (Render utilise $PORT, défaut 8080)
EXPOSE 8080

CMD ["/start.sh"]
