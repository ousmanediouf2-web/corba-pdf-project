# CORBA PDF Service - Application Web Complète

## Architecture du Projet

```
corba-pdf-project/
├── idl/
│   └── PDFService.idl              # Interface CORBA
├── corba-server/                   # Serveur CORBA (JAR)
│   ├── pom.xml
│   └── src/main/java/com/pdfservice/
│       ├── impl/PDFOperationsImpl.java   # Logique PDF (PDFBox)
│       └── server/PDFServer.java         # Serveur principal
├── web-app/                        # Application Web (WAR)
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/pdfservice/
│       │   ├── dao/MongoDBDAO.java        # Base de données MongoDB Atlas
│       │   ├── model/User.java            # Modèle utilisateur
│       │   ├── model/OperationHistory.java
│       │   ├── servlet/AuthServlet.java   # Login / Register / Logout
│       │   ├── servlet/DashboardServlet.java
│       │   ├── servlet/PDFOperationServlet.java # Toutes les ops PDF
│       │   └── util/CORBAClient.java      # Client CORBA
│       └── webapp/
│           ├── WEB-INF/pages/            # Pages JSP
│           └── css/style.css
├── start-corba-server.bat / .sh    # Démarrer le serveur CORBA
├── build-web-app.bat               # Compiler le WAR
└── README.md
```

---

## Prérequis

| Outil | Version | Lien |
|-------|---------|------|
| JDK | 8 (obligatoire pour CORBA) | https://www.oracle.com/java/technologies/java8-archive-downloads.html |
| Maven | 3.6+ | https://maven.apache.org/download.cgi |
| Tomcat | 9.x | https://tomcat.apache.org/download-90.cgi |
| MongoDB Atlas | Compte gratuit | https://www.mongodb.com/atlas |

---

## ÉTAPE 1 — Configurer MongoDB Atlas

1. Créez un compte sur https://www.mongodb.com/atlas
2. Créez un cluster gratuit (M0 Free Tier)
3. Créez un utilisateur de base de données (Database Access → Add New User)
4. Autorisez votre IP (Network Access → Add IP Address → Allow Access from Anywhere : 0.0.0.0/0)
5. Copiez la connection string : `mongodb+srv://<user>:<password>@<cluster>.mongodb.net/`

6. **Editez** `web-app/src/main/java/com/pdfservice/dao/MongoDBDAO.java` :

```java
// Ligne à modifier (ligne ~15) :
private static final String MONGODB_URI =
    "mongodb+srv://VOTRE_USER:VOTRE_MOT_DE_PASSE@VOTRE_CLUSTER.mongodb.net/pdfservice?retryWrites=true&w=majority";
```

---

## ÉTAPE 2 — Générer les Stubs CORBA depuis l'IDL

Les stubs CORBA sont les classes Java générées automatiquement depuis le fichier `.idl`.
Ils permettent à la couche web (client) et au serveur de communiquer via CORBA.

### Pour le Serveur CORBA :
```bash
cd corba-server
idlj -fall -td src/main/java ../idl/PDFService.idl
```

### Pour le Client Web :
```bash
cd web-app
idlj -fclient -td src/main/java ../idl/PDFService.idl
```

> **Note** : `idlj` est inclus dans le JDK 8. Il se trouve dans `%JAVA_HOME%\bin\idlj`

Ces commandes créent le package `pdfservice/` dans `src/main/java/` avec les fichiers :
- `PDFOperations.java`
- `PDFOperationsHelper.java`
- `PDFOperationsHolder.java`
- `PDFOperationsPOA.java` (côté serveur uniquement)
- `PDFException.java`
- etc.

---

## ÉTAPE 3 — Compiler le Serveur CORBA

```bash
cd corba-server
mvn clean package
```

Cela génère : `target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar`

---

## ÉTAPE 4 — Compiler l'Application Web

```bash
cd web-app
mvn clean package
```

Cela génère : `target/corba-pdf-app.war`

---

## ÉTAPE 5 — Démarrer le Serveur CORBA

### Windows :
```cmd
REM 1. Démarrer le Name Service CORBA (dans un terminal séparé)
orbd -ORBInitialPort 1050 -ORBInitialHost localhost

REM 2. Démarrer le serveur PDF (dans un autre terminal)
cd corba-server
java -cp target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar ^
     -Dorg.omg.CORBA.ORBInitialHost=localhost ^
     -Dorg.omg.CORBA.ORBInitialPort=1050 ^
     com.pdfservice.server.PDFServer
```

### Linux/Mac :
```bash
# 1. Démarrer le Name Service CORBA (en arrière-plan)
orbd -ORBInitialPort 1050 -ORBInitialHost localhost &

# 2. Démarrer le serveur PDF
cd corba-server
java -cp target/corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar \
     -Dorg.omg.CORBA.ORBInitialHost=localhost \
     -Dorg.omg.CORBA.ORBInitialPort=1050 \
     com.pdfservice.server.PDFServer
```

Vous devez voir :
```
=== Démarrage du Serveur CORBA PDF ===
✅ Connexion MongoDB Atlas établie
=== Serveur CORBA PDF démarré sur le port 1050 ===
Service enregistré sous le nom: PDFService
En attente de requêtes...
IOR écrit dans pdf_service.ior
```

---

## ÉTAPE 6 — Déployer sur Tomcat

1. Copiez le fichier WAR dans le répertoire de déploiement Tomcat :
```bash
cp web-app/target/corba-pdf-app.war /chemin/vers/tomcat/webapps/
```

2. Démarrez Tomcat :
```bash
# Linux/Mac
/chemin/vers/tomcat/bin/startup.sh

# Windows
/chemin/vers/tomcat/bin/startup.bat
```

3. Accédez à l'application :
```
http://localhost:8080/corba-pdf-app
```

---

## ÉTAPE 7 — Premier Accès

1. Ouvrez `http://localhost:8080/corba-pdf-app`
2. Vous serez redirigé vers la page de connexion
3. Cliquez sur **"Créer un compte"** pour vous inscrire
4. Connectez-vous avec vos identifiants
5. Le tableau de bord s'affiche avec le statut du serveur CORBA

---

## Configuration Tomcat pour les Propriétés Système

Pour passer l'hôte/port CORBA à l'application web, ajoutez dans `tomcat/bin/setenv.bat` (Windows) :
```cmd
set JAVA_OPTS=-Dcorba.host=localhost -Dcorba.port=1050
```

Ou `tomcat/bin/setenv.sh` (Linux) :
```bash
export JAVA_OPTS="-Dcorba.host=localhost -Dcorba.port=1050"
```

---

## Déploiement en Production (Denver / Serveur distant)

### Si le serveur CORBA et Tomcat sont sur la même machine :
Aucune modification nécessaire. Utilisez `localhost`.

### Si le serveur CORBA est sur une machine différente :
1. Modifiez `CORBAClient.java` :
```java
private static final String CORBA_HOST = "IP_DU_SERVEUR_CORBA";
```
Ou passez la propriété système :
```bash
java -Dcorba.host=192.168.1.100 -Dcorba.port=1050 ...
```

2. Ouvrez le port `1050` dans le pare-feu du serveur CORBA.

### Variables d'environnement MongoDB Atlas pour la production :
Remplacez la chaîne de connexion codée en dur par une variable d'environnement :
```java
private static final String MONGODB_URI = System.getenv("MONGODB_URI");
```
Puis définissez la variable dans votre environnement serveur.

---

## Opérations PDF disponibles

| Opération | Description | URL |
|-----------|-------------|-----|
| Fusion | Fusionner plusieurs PDF | `/pdf/merge` |
| Découpage | Extraire une plage de pages | `/pdf/split` |
| Extraction de pages | Extraire des pages spécifiques | `/pdf/extract` |
| Suppression de pages | Supprimer des pages | `/pdf/delete` |
| Mot de passe | Protéger avec mot de passe | `/pdf/password` |
| PDF → Images | Convertir pages en PNG (ZIP) | `/pdf/convert` |
| Extraction texte | Extraire le texte | `/pdf/text` |
| Création PDF | Créer un PDF depuis texte | `/pdf/create` |

---

## Résolution des problèmes courants

### "Le serveur CORBA n'est pas disponible"
- Vérifiez que `orbd` tourne sur le port 1050
- Vérifiez que `PDFServer` est démarré
- Vérifiez que le pare-feu n'est pas bloquant

### "Erreur connexion MongoDB"
- Vérifiez la chaîne de connexion dans `MongoDBDAO.java`
- Vérifiez que votre IP est autorisée dans MongoDB Atlas Network Access
- Vérifiez que le mot de passe ne contient pas de caractères spéciaux non encodés

### "ClassNotFoundException: pdfservice.PDFOperations"
- Les stubs IDL n'ont pas été générés
- Réexécutez `idlj -fall ...` puis recompilez

### "Erreur 404 sur /pdf/merge"
- Vérifiez que le WAR est bien déployé dans Tomcat
- Vérifiez les logs Tomcat dans `logs/catalina.out`

### Port 1050 déjà utilisé
```bash
# Trouver le processus utilisant le port
netstat -ano | findstr 1050   # Windows
lsof -i :1050                  # Linux/Mac

# Changer le port CORBA (modifier aussi dans CORBAClient.java)
orbd -ORBInitialPort 1051 ...
```

---

## Flux de fonctionnement complet

```
Navigateur Client
      │
      │  HTTP (login, upload PDF, résultat)
      ▼
Tomcat + Servlets JSP   ←──── MongoDB Atlas (users, historique)
      │
      │  CORBA / IIOP (RPC distant, binaire PDF)
      ▼
Serveur CORBA (JacORB)
      │
      │  Java API
      ▼
Apache PDFBox (traitement PDF)
```

---

## Sécurité

- Les mots de passe sont hashés avec **BCrypt** (12 rounds)
- Les sessions Tomcat expirent après **1 heure**
- Les pages JSP sont protégées par vérification de session
- Les fichiers JSP sont dans `WEB-INF` (non accessibles directement)
- MongoDB Atlas : connexion via TLS, authentification par user/password

---

## Technologies utilisées

- **CORBA** : JacORB 3.9 (implémentation Java de CORBA 1.8)
- **IDL** : Interface Definition Language (standard OMG)
- **PDF** : Apache PDFBox 2.0.30
- **Web** : Java Servlet 4.0 + JSP 2.3 + JSTL 1.2
- **Base de données** : MongoDB Atlas (cloud) + MongoDB Driver 4.11
- **Auth** : BCrypt (jbcrypt 0.4)
- **Upload** : Apache Commons FileUpload 1.5
- **Serveur** : Apache Tomcat 9.x
- **Build** : Maven 3.x
- **JDK** : Java 8 (requis pour CORBA/IDL)
