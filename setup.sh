#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║       CORBA PDF Service - Setup Complet          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# ---- Vérifier Java ----
if ! command -v java &> /dev/null; then
    echo "[✗] Java non trouvé. Installez JDK 8."
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "[✓] Java: $JAVA_VERSION"

# ---- Vérifier idlj ----
if ! command -v idlj &> /dev/null; then
    echo "[✗] idlj non trouvé. Assurez-vous que JDK 8 est installé (pas JRE)."
    exit 1
fi
echo "[✓] idlj disponible"

# ---- Vérifier Maven ----
if ! command -v mvn &> /dev/null; then
    echo "[✗] Maven non trouvé. Installez Maven 3.x."
    exit 1
fi
echo "[✓] Maven disponible"

echo ""
echo "═══════════════════════════════════════════════════"
echo " CONFIGURATION MONGODB ATLAS"
echo "═══════════════════════════════════════════════════"
echo ""
read -p "Entrez votre URI MongoDB Atlas (ou Entrée pour passer): " MONGO_URI

if [ ! -z "$MONGO_URI" ]; then
    # Échapper les caractères spéciaux pour sed
    ESCAPED_URI=$(echo "$MONGO_URI" | sed 's/[&/\]/\\&/g')
    sed -i "s|mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@YOUR_CLUSTER.mongodb.net/pdfservice.*|$ESCAPED_URI|g" \
        web-app/src/main/java/com/pdfservice/dao/MongoDBDAO.java
    echo "[✓] URI MongoDB configurée"
else
    echo "[!] Éditez manuellement: web-app/src/main/java/com/pdfservice/dao/MongoDBDAO.java"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo " GÉNÉRATION DES STUBS IDL"
echo "═══════════════════════════════════════════════════"
echo ""

# Stubs serveur
mkdir -p corba-server/src/main/java/pdfservice
idlj -fall -td corba-server/src/main/java idl/PDFService.idl
[ $? -ne 0 ] && echo "[✗] Échec stubs serveur" && exit 1
echo "[✓] Stubs serveur générés"

# Stubs client
mkdir -p web-app/src/main/java/pdfservice
idlj -fclient -td web-app/src/main/java idl/PDFService.idl
[ $? -ne 0 ] && echo "[✗] Échec stubs client" && exit 1
echo "[✓] Stubs client générés"

echo ""
echo "═══════════════════════════════════════════════════"
echo " COMPILATION"
echo "═══════════════════════════════════════════════════"
echo ""

# Compiler serveur CORBA
echo "Compilation du serveur CORBA..."
cd corba-server && mvn clean package -q
[ $? -ne 0 ] && echo "[✗] Échec compilation serveur" && exit 1
echo "[✓] Serveur CORBA compilé"
cd "$PROJECT_DIR"

# Compiler application web
echo "Compilation de l'application web..."
cd web-app && mvn clean package -q
[ $? -ne 0 ] && echo "[✗] Échec compilation web" && exit 1
echo "[✓] Application web compilée: web-app/target/corba-pdf-app.war"
cd "$PROJECT_DIR"

echo ""
echo "═══════════════════════════════════════════════════"
echo " DÉPLOIEMENT TOMCAT"
echo "═══════════════════════════════════════════════════"
echo ""
read -p "Chemin vers Tomcat (ex: /opt/tomcat9), ou Entrée pour ignorer: " TOMCAT_DIR

if [ ! -z "$TOMCAT_DIR" ] && [ -d "$TOMCAT_DIR/webapps" ]; then
    cp web-app/target/corba-pdf-app.war "$TOMCAT_DIR/webapps/"
    echo "[✓] WAR copié dans $TOMCAT_DIR/webapps/"

    # Configurer setenv.sh
    echo 'export JAVA_OPTS="-Dcorba.host=localhost -Dcorba.port=1050"' > "$TOMCAT_DIR/bin/setenv.sh"
    chmod +x "$TOMCAT_DIR/bin/setenv.sh"
    echo "[✓] setenv.sh configuré"
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║                 SETUP TERMINÉ !                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Pour lancer l'application:"
echo ""
echo "  1. Démarrez le serveur CORBA:"
echo "     chmod +x start-corba-server.sh && ./start-corba-server.sh"
echo ""
echo "  2. Démarrez Tomcat:"
echo "     [TOMCAT]/bin/startup.sh"
echo ""
echo "  3. Ouvrez votre navigateur:"
echo "     http://localhost:8080/corba-pdf-app"
echo ""
