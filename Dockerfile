FROM maven:3.9-eclipse-temurin-8

WORKDIR /app

# Copier tout le projet (stubs déjà inclus dans src/main/java/pdfservice/)
COPY . .

# Installer Tomcat
RUN apt-get update && apt-get install -y wget && \
    wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.82/bin/apache-tomcat-9.0.82.tar.gz && \
    tar -xzf apache-tomcat-9.0.82.tar.gz && \
    mv apache-tomcat-9.0.82 /opt/tomcat && \
    rm apache-tomcat-9.0.82.tar.gz && \
    rm -rf /opt/tomcat/webapps/ROOT \
           /opt/tomcat/webapps/examples \
           /opt/tomcat/webapps/docs

# Compiler directement - les stubs sont déjà dans src/main/java/pdfservice/
RUN mvn clean package -DskipTests

# Déployer le WAR dans Tomcat
RUN cp web-app/target/ROOT.war /opt/tomcat/webapps/ROOT.war

# Script de démarrage
RUN printf '#!/bin/bash\n\
orbd -ORBInitialPort 1050 -ORBInitialHost localhost &\n\
sleep 4\n\
java -cp /app/corba-server/target/corba-server-1.0-jar-with-dependencies.jar \\\n\
  -Dorg.omg.CORBA.ORBInitialHost=localhost \\\n\
  -Dorg.omg.CORBA.ORBInitialPort=1050 \\\n\
  com.pdfservice.server.PDFServer &\n\
sleep 5\n\
export JAVA_OPTS="-Dcorba.host=localhost -Dcorba.port=1050 -DMONGODB_URI=$MONGODB_URI"\n\
PORT=${PORT:-8080}\n\
sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /opt/tomcat/conf/server.xml\n\
exec /opt/tomcat/bin/catalina.sh run\n' > /start.sh && chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
