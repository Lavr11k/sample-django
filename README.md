# Samle django app in Docker

This project is a Dockerized Django web application, based on [digitalocean/sample-django](https://github.com/digitalocean/sample-django). It uses Gunicorn, Whitenoise, and environment variables to enable easy deployment.

## Installation
- Docker installed on your machine
- `.env` file with required settings

## Build and run the app for local testing using docker image

### 1. Create `.env` file

```.env
DJANGO_ALLOWED_HOSTS=*
DATABASE_URL=postgres://your_user:your_pass@your_db_host:5432/your_db_name
```

⚠️**Note that application doesn't work without database connection, so you need to provide database connection string as above.**

### 2. Build the image

```sh
docker build -t django-app .
```

### 3. Run the app for local testing

```sh
docker run --rm -p 8000:8000 -d --env-file .env django-app
```

Then visit http://localhost:8000 in your browser.

## Build and run the app for local testing using docker compose.

### 1. Create `.env` file

```.env
POSTGRESQL_DJANGO_USER=app
POSTGRESQL_DJANGO_PASSWORD=pass123
POSTGRESQL_PORT=5432
POSTGRESQL_DJANGO_DATABASE=django
```

### 2. Run the app

```sh
docker compose up --build -d
```

