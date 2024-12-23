FROM python:3.12-alpine

WORKDIR /app

ENV FLASK_APP=app
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN adduser -D user && chown -R user:user /app
USER user

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]