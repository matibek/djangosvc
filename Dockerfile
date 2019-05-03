FROM python:3.7.2

# Configure python
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONUNBUFFERED=1

# collectstatic needs the secret key to be set. We store that in this environment variable.
# Set this value in this project's .env file
ARG DJANGO_SECRET_KEY

# Configure log
RUN mkdir -p /var/log/djangosvc

# Configure App
WORKDIR /djangosvc
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app ./
RUN python manage.py collectstatic --no-input
