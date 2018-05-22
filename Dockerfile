FROM python:2-alpine
LABEL maintainer="ember@pfragoso.org"

ENV REDIS_URL localhost

RUN pip install --upgrade pip
RUN mkdir -p /app

ADD app.py requirements.txt /app/

WORKDIR /app
RUN pip install -r /app/requirements.txt

EXPOSE 5000

CMD ["python", "/app/app.py"]
