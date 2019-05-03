# Djangosvc
### Django, MySQL, and Redis, all in Docker

This is a boilerplate repo intended for quickly starting a new **Django** project with **MySQL** and **Redis** support, all running within Docker containers. A **Nginx** service is also defined to enable immediate access to the site over port 8000.

## Getting started

1. Clone this repo
2. Delete the **.git** folder
    - `rm -rf .git/`
3. Create a new git repo
    - `git init`
    - `git add .`
    - `git commit -m "Initial Commit"`
4. Install Python dependencies in a Python3 virtual environment
    - `pip3 install -r requirements.txt`
5. Create a new Django project
    - `django-admin startproject mysvc app/`
6. Make the following changes to your Django project's **settings.py**:

```py
# mysvc/settings.py
import os

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv('DEBUG', False) == 'true'

ALLOWED_HOSTS = [
    'localhost',
]

INSTALLED_APPS = [
    # ...snip...
    'django_redis',
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('MYSQL_DATABASE'),
        'USER': os.getenv('MYSQL_USER'),
        'PASSWORD': os.getenv('MYSQL_PASSWORD'),
        'HOST': os.getenv('MYSQL_HOST', 'db'),
        'PORT': os.getenv('MYSQL_PORT', 3306),
    }
}

STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = '/static/'

# django-redis
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': os.getenv('REDIS_URL', 'redis://redis:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'
```

7. Update the **.env** file to specify values for the environment variables defined within
8. Start Django for development
    - `docker-compose up`
9. [Optional] Run migration, collect static and create admin user
    - `docker exec -it mysvc python manage.py migrate`
    - `docker exec -it mysvc python manage.py collectstatic --no-input`
    - `docker exec -it mysvc python manage.py createsuperuser`
10. Go to `http://localhost:8000/admin/`

## Components

### Dockerfile

Builds the Django container. The container is derived from the standard **python:3.7** image and will run Django's `colletstatic` when being built.

### docker-compose.yml

> NOTE: The compose file is intended for development purposes as we deploy our service using kubernetes and all configurations are handled in the infra.

Tasked with spinning up three containers: the above container for **Django**, one for **MySQL**, and one for **Redis**.

By default an **Nginx** container is also created to reverse-proxy requests to Django and serve static files. In this configuration, the Django server will be available on port 8000 during development.

If the Nginx container is removed, Docker can be accessed directly on port 8000. Static files can then be served from the **static_files_volume** Docker volume.

### requirements.in/requirmenents.txt

Includes Python packages needed to make Django, MySQL, and Redis work together.

### .env

Contains environment variables for the containers. Several variables are included for configuring MySQL and Django secrets.

### .editorconfig

Defines some common settings to help ensure consistency of styling across files.

### .flake8

Configures the **flake8** Python linter.

### app/gunicorn.cfg

Defines settings for gunicorn, including a port binding and workers.

### app/nginx.conf

Establishes a reverse-proxy to Django, and serves Django static files.

> Inspired by https://github.com/MasterKale/Docker-Django
