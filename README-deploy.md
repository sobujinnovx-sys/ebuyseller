# Docker + Deployment notes for eBuySeller

This document explains how to run this Laravel app with Docker locally and outlines free/low-cost deployment options.

Local (Docker) quick start

1. Build and start containers

```cmd
cd /d e:\laragon\www\eBuySeller
docker compose up --build -d
```

2. Create `.env` (copy from `.env.example`) and set DB credentials to match `docker-compose.yml` (user: `user`, password: `secret`, database: `e_shop`).

3. Run migrations & seeders, generate app key, and link storage (from host or inside `app` container):

```cmd
docker compose exec app bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
exit
```

4. Open http://127.0.0.1:8000

Notes about production
- The `Dockerfile` provided is a simple starting point. For production, build with `--no-dev`, optimize autoload, and use multi-stage builds to avoid shipping dev tools.
- Store secrets in a secure place (Railway, Fly, GitHub Secrets) and do NOT commit `.env`.

Free hosting options (short summary)

- Fly.io — supports Docker images, easy for small apps. Free tier available with limited shared CPU and memory. Good for Laravel, supports volumes and postgres/mysql as addons.
- Railway.app — easy PostgreSQL/MySQL + Docker deploys. Free tier with expires/usage limits but very simple CI integration.
- Render.com — offers Docker and services with free tier for static sites; web services have a free tier with sleeps.
- Vercel/Netlify — not suitable for running PHP backends; you'd need to deploy as serverless functions (not recommended here).
- GitHub Actions + a container registry (Docker Hub / GitHub Packages) + Render/Fly — common flow for CI/CD.

Deploy tips
- Prefer using managed DB (provided by host) rather than shipping a DB container in production.
- Use `APP_ENV=production` and `APP_DEBUG=false` in production.
- Use a volume for persistent storage (uploads) or an external S3-compatible storage.

If you want, I can:
- Add a GitHub Actions workflow to build and push images.
- Create a Fly.io deployment config (fly.toml) with secrets set.
- Create a Railway deploy template.
