#!/bin/bash
echo "==================================================="
echo "   Démarrage du Serveur CORBA PDF Service"
echo "==================================================="

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORBA_DIR="$PROJECT_DIR/corba-server"
IDL_FILE="$PROJECT_DIR/idl/PDFService.idl"

cd "$CORBA_DIR"

# --- Étape 1: Génération des stubs depuis IDL ---
echo ""
echo "[1/3] Génération des stubs CORBA depuis IDL..."
mkdir -p src/main/java/pdfservice
idlj -fall -td src/main/java "$IDL_FILE"
if [ $? -ne 0 ]; then
    echo "ERREUR: Échec génération IDL"
    exit 1
fi
echo "  ✅ Stubs générés"

# --- Étape 2: Compilation Maven ---
echo ""
echo "[2/3] Compilation Maven..."
mvn clean package -q
if [ $? -ne 0 ]; then
    echo "ERREUR: Échec compilation Maven"
    exit 1
fi
echo "  ✅ JAR compilé"

# --- Étape 3: Démarrage NameService + Serveur ---
echo ""
echo "[3/3] Démarrage du NameService CORBA (port 1050)..."
orbd -ORBInitialPort 1050 -ORBInitialHost localhost &
ORBD_PID=$!
sleep 3
echo "  ✅ NameService démarré (PID: $ORBD_PID)"

echo ""
echo "Démarrage du Serveur PDF CORBA..."
java -cp target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar \
     -Dorg.omg.CORBA.ORBInitialHost=localhost \
     -Dorg.omg.CORBA.ORBInitialPort=1050 \
     com.pdfservice.server.PDFServer

# Cleanup
kill $ORBD_PID 2>/dev/null
