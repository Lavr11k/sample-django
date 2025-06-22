# Common base image
FROM python:3.8-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create non-root user and set permissions
RUN addgroup --system djangogroup && \
  adduser --system --ingroup djangogroup djangouser && \
  mkdir /code && \
  chown djangouser:djangogroup /code

WORKDIR /code

# Build stage
FROM base AS build

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  gcc \
  libc-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install requirements using pip
COPY . .
RUN pip install --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

# Collect static files
RUN python manage.py collectstatic --noinput

# Main stage
FROM base

# Copy binaries
COPY --from=build ["/usr/local/bin/gunicorn", "/usr/local/bin/django-admin", "/usr/local/bin/sqlformat", "/usr/local/bin/"]

# Copy packages installed with pip
COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

# Copy the code with collected static files
COPY --from=build /code .

USER djangouser

EXPOSE 80
CMD ["gunicorn", "mysite.wsgi:application", "--bind", "0.0.0.0:80"]
