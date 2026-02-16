# Nirvista Admin Website (Flutter Web on Render)

This project is configured to deploy on **Render Web Service** using Docker.
No `render.yaml` Blueprint is required.

## Files Added For Render

- `Dockerfile`
- `.dockerignore`
- `deploy/nginx/default.conf.template`

## 1. Push This Project To GitHub

If this folder is already a git repo:

```powershell
git add .
git commit -m "Add Render Web Service deployment setup for Flutter web"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

If remote `origin` already exists, update it:

```powershell
git remote set-url origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## 2. Create Render Web Service (Manual, Not Blueprint)

In Render dashboard:

1. `New +` -> `Web Service`
2. Connect your GitHub repo
3. Choose branch: `main`
4. Runtime/Environment: `Docker`
5. Region/Plan: your choice
6. Create Web Service

Render will detect `Dockerfile`, build Flutter web, and serve with Nginx.

## 3. Render Settings To Use

- Build Command: leave empty (Docker handles build)
- Start Command: leave empty (Docker/Nginx handles start)
- Health Check Path: `/`
- Auto-Deploy: optional (recommended ON)

## 4. Local Docker Test (Optional)

```powershell
docker build -t nirvista-admin-web .
docker run --rm -p 10000:10000 -e PORT=10000 nirvista-admin-web
```

Then open `http://localhost:10000`.
