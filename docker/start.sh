#!/bin/bash
set -e

echo "================================================="
echo "  CORBA PDF Service - Démarrage sur Render.com"
echo "================================================="

mkdir -p /var/log/supervisor

# Render injecte $PORT automatiquement (souvent 10000)
PORT=${PORT:-8080}
echo "Port détecté : $PORT"

# Reconfigurer Tomcat si le port n'est pas 8080
if [ "$PORT" != "8080" ]; then
    echo "Reconfiguration Tomcat sur port $PORT..."
    sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /opt/tomcat/conf/server.xml
fi

# Vérifier MONGODB_URI
if [ -z "$MONGODB_URI" ]; then
    echo "ATTENTION: MONGODB_URI non définie !"
    echo "Ajoutez-la dans Render Dashboard > votre service > Environment"
fi

echo "Démarrage des services (supervisord)..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
