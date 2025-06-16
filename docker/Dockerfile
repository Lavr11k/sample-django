FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1
WORKDIR /code
COPY ../requirements.txt /code/
RUN apt update
RUN apt install libpq-dev -y
RUN apt install gcc -y
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY ../ /code/
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["gunicorn", "mysite.wsgi:application", "--bind", "0.0.0.0:8000"]
