# Guide Déploiement En Ligne : GitHub + Railway

## Vue d'ensemble

```
Votre PC (Windows)
      │  git push
      ▼
   GitHub
      │  GitHub Actions (build automatique)
      │  → génère stubs IDL
      │  → compile JAR + WAR
      │  → build image Docker
      │  → push sur DockerHub
      ▼
   Railway (hébergement gratuit)
      │  lance le conteneur Docker
      │  → orbd (NameService CORBA)
      │  → Serveur CORBA PDF
      │  → Tomcat (application web)
      ▼
   Accessible à : https://votre-app.railway.app
```

---

## PHASE 1 — Comptes à créer (tous gratuits)

| Service | Lien | Usage |
|---------|------|-------|
| GitHub | https://github.com | Hébergement code |
| Docker Hub | https://hub.docker.com | Image Docker |
| Railway | https://railway.app | Hébergement app |
| MongoDB Atlas | https://mongodb.com/atlas | Base de données |

---

## PHASE 2 — Préparer votre PC Windows

### Installer Git (si pas encore fait)
1. Téléchargez : https://git-scm.com/download/win
2. Installez avec les options par défaut
3. Vérifiez : ouvrez CMD et tapez `git --version`

### Installer JDK 8
1. Téléchargez : https://adoptium.net/temurin/releases/?version=8
2. Choisissez **Windows x64 .msi**
3. Installez et vérifiez : `java -version`

### Installer Maven
1. Téléchargez : https://maven.apache.org/download.cgi (Binary zip archive)
2. Extrayez dans `C:\maven`
3. Ajoutez `C:\maven\bin` à votre PATH
4. Vérifiez : `mvn -version`

---

## PHASE 3 — Configurer MongoDB Atlas

1. Allez sur https://cloud.mongodb.com
2. Créez un cluster **gratuit** (M0 Shared)
3. **Database Access** → Add User → notez user/password
4. **Network Access** → Add IP → `0.0.0.0/0` (Allow from anywhere)
5. **Connect** → Drivers → copiez l'URI :
   ```
   mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/pdfservice?retryWrites=true&w=majority
   ```

---

## PHASE 4 — Mettre le code sur GitHub

### Ouvrez CMD dans le dossier du projet extrait :

```cmd
cd C:\chemin\vers\corba-pdf-project

REM Initialiser Git
git init
git add .
git commit -m "Initial commit - CORBA PDF Service"
```

### Créer le repo GitHub :
1. Allez sur https://github.com/new
2. Nom du repo : `corba-pdf-project`
3. Visibilité : **Public** (ou Private)
4. **Ne pas** cocher README/gitignore (déjà présents)
5. Cliquez **Create repository**

### Lier et pousser :
```cmd
git remote add origin https://github.com/VOTRE_USERNAME/corba-pdf-project.git
git branch -M main
git push -u origin main
```

---

## PHASE 5 — Configurer les Secrets GitHub

Dans votre repo GitHub → **Settings** → **Secrets and variables** → **Actions** :

Ajoutez ces 4 secrets (bouton "New repository secret") :

| Nom du secret | Valeur |
|---------------|--------|
| `MONGODB_URI` | `mongodb+srv://user:pass@cluster.mongodb.net/pdfservice?retryWrites=true&w=majority` |
| `DOCKERHUB_USERNAME` | votre username Docker Hub |
| `DOCKERHUB_TOKEN` | votre token Docker Hub (Account Settings → Security → New Token) |
| `RAILWAY_TOKEN` | votre token Railway (voir Phase 6) |

---

## PHASE 6 — Configurer Railway

1. Allez sur https://railway.app et connectez-vous avec GitHub
2. Cliquez **New Project** → **Deploy from GitHub repo**
3. Sélectionnez votre repo `corba-pdf-project`
4. Railway détecte le `Dockerfile` automatiquement

### Ajouter la variable d'environnement sur Railway :
Dans votre projet Railway → **Variables** → **New Variable** :
```
MONGODB_URI = mongodb+srv://user:pass@cluster.mongodb.net/pdfservice?retryWrites=true&w=majority
```

### Récupérer le Railway Token :
1. https://railway.app → votre profil → **Account Settings**
2. **Tokens** → **Create Token**
3. Copiez le token et ajoutez-le dans GitHub Secrets (`RAILWAY_TOKEN`)

---

## PHASE 7 — Premier déploiement

Après avoir tout configuré, chaque `git push` sur `main` déclenche automatiquement :

```
git add .
git commit -m "Mise à jour"
git push
```

Puis dans GitHub → **Actions**, vous voyez le pipeline :
```
✅ Build (IDL stubs + JAR + WAR)
✅ Build et Push Docker Image
✅ Deploy sur Railway
```

Votre app sera accessible sur l'URL Railway :
```
https://corba-pdf-project-production.up.railway.app
```

---

## Workflow quotidien (mises à jour)

```cmd
REM Modifier votre code...
git add .
git commit -m "Description de la modification"
git push
```

→ GitHub Actions compile et redéploie automatiquement en ~5 minutes.

---

## En cas de problème

### Voir les logs Railway :
Railway Dashboard → votre service → **Deployments** → cliquer sur le déploiement → **View Logs**

### Voir les logs GitHub Actions :
GitHub → votre repo → **Actions** → cliquer sur le workflow échoué

### Problème courant : "CORBA connection refused"
Le serveur CORBA met ~10 secondes à démarrer. Tomcat démarre après (géré par supervisord).
Si le problème persiste, redémarrez le service dans Railway Dashboard.

### Problème courant : "MongoDB connection failed"
Vérifiez que `0.0.0.0/0` est bien dans Network Access sur Atlas.
Railway utilise des IPs dynamiques, donc il faut autoriser toutes les IPs.
