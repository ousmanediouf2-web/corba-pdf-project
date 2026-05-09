# Guide : Publier sur GitHub et Déployer

## ÉTAPE 1 — Initialiser Git et pousser sur GitHub

### Sur votre machine Windows, ouvrez Git Bash ou CMD dans le dossier du projet :

```bash
cd corba-pdf-project

# Initialiser le dépôt Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit - CORBA PDF Service"

# Créer le dépôt sur GitHub (https://github.com/new) puis :
git remote add origin https://github.com/VOTRE_USERNAME/corba-pdf-project.git
git branch -M main
git push -u origin main
```

> ⚠️ Avant de pusher, assurez-vous que MongoDBDAO.java utilise la variable
>    d'environnement et NON un mot de passe hardcodé (déjà configuré ainsi).

---

## ÉTAPE 2 — Configurer le Secret MongoDB dans GitHub

Pour que le build CI/CD fonctionne sans exposer votre mot de passe :

1. Allez dans votre repo GitHub → **Settings** → **Secrets and variables** → **Actions**
2. Cliquez **New repository secret**
3. Nom : `MONGODB_URI`
4. Valeur : `mongodb+srv://user:password@cluster.mongodb.net/pdfservice?retryWrites=true&w=majority`
5. Cliquez **Add secret**

---

## ÉTAPE 3 — Récupérer et Déployer sur votre machine Denver

### A. Cloner le projet depuis GitHub

```bash
git clone https://github.com/VOTRE_USERNAME/corba-pdf-project.git
cd corba-pdf-project
```

### B. Configurer MONGODB_URI en local

Créez un fichier `setenv.bat` dans votre Tomcat/bin/ :
```cmd
set JAVA_OPTS=-DMONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/pdfservice?retryWrites=true^&w=majority -Dcorba.host=localhost -Dcorba.port=1050
```

### C. Lancer le setup complet

```cmd
setup.bat
```

---

## ÉTAPE 4 — Démarrage quotidien

### Terminal 1 — Name Service CORBA :
```cmd
orbd -ORBInitialPort 1050 -ORBInitialHost localhost
```

### Terminal 2 — Serveur PDF CORBA :
```cmd
cd corba-server
java -cp target\corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar ^
     -Dorg.omg.CORBA.ORBInitialHost=localhost ^
     -Dorg.omg.CORBA.ORBInitialPort=1050 ^
     com.pdfservice.server.PDFServer
```

### Terminal 3 — Tomcat (avec le WAR déployé) :
```cmd
[TOMCAT]\bin\startup.bat
```

### Accès :
```
http://localhost:8080/corba-pdf-app
```

---

## Structure GitHub recommandée

```
corba-pdf-project/          ← Racine du repo
├── .github/workflows/      ← CI/CD automatique
├── .gitignore              ← Exclut target/, stubs IDL, etc.
├── idl/PDFService.idl      ← Interface CORBA
├── corba-server/           ← Serveur Java CORBA
├── web-app/                ← Application Web JSP/Servlet
├── setup.bat               ← Setup Windows
├── setup.sh                ← Setup Linux/Mac
├── start-corba-server.bat  ← Démarrage serveur
└── README.md               ← Documentation
```

Les stubs CORBA (`pdfservice/`) sont dans `.gitignore` car ils sont
générés automatiquement par `idlj` lors du build.
