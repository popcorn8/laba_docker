# Лабораторная работа Docker  
**Дамакин Роман 2384 и Шурыгин Данил 2384**

---

## Описание проекта
В рамках лабораторной работы была произведена докеризация Flask-приложения с использованием базы данных **PostgreSQL**. Приложение включает автоматические миграции базы данных при запуске. 

---

## 🛠️ Стек технологий
- **Backend**: Flask  
- **База данных**: PostgreSQL 15 (alpine)  
- **Контейнеризация**: Docker + Docker Compose  

---

## Особенности реализации
1. **Легковесные образы**: Используются Python 3.12 и PostgreSQL на базе Alpine.  
2. **Порты**: Проброшен порт для локального запуска (`5001:5000`). 
3. **Переменные окружения**: Переменные окружения задаются в докерфайлах.  
4. **Хранение данных**: Данные базы сохраняются в **volume** и не теряются при перезапуске контейнеров.  
5. **Пользователь**: Приложение запускается от непривилегированного пользователя.   

---

## 📜 Dockerfile
```dockerfile
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
```
 ## Объяснение:
 - Используется легковесный образ Python 3.12 на базе Alpine.
 - Устанавливаются зависимости из requirements.txt без кеширования.
 - Добавляется непривилегированный пользователь для запуска контейнера.

 ---

 ## 📋 docker-compose.yml
 ```yaml
 version: '3.8'

services:
  web:
    build: .
    ports:
      - "5001:5000"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/flaskdb
    volumes:
      - .:/app

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: flaskdb
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```
 ## Объяснение:
 - Для базы данных используется PostgreSQL 15 на основе Alpine.
 - Данные сохраняются в volume pgdata.
 - Сервис web запускается только после старта db.
 - Проброшен порт 5001:5000 для работы Flask-сервера.
 ---
  ## ⚙️ entrypoint.sh
```bash
flask db init || true
flask db migrate -m "Initial migration" || true
flask db upgrade
exec flask run
```
 ## Объяснение:
 - Автоматически выполняются миграции базы данных при старте контейнера. "Initial migration" необходим для автоматического создания папки migrations.
 - Запускается Flask-сервер с учетом автоматизации миграций (flask db upgrade).


## Соответствие требованиям лабораторной работы

### 1. Легковесный образ

- **Dockerfile** использует базовый образ `python:3.12-alpine`, что обеспечивает минимальный размер конечного образа.

### 2. Использование Alpine

- В прошлом пункте указан используемый образ.

### 3. Конфигурация через переменные окружения

- В `docker-compose.yml` и `Dockerfile` определены переменные окружения для базы данных и приложения.

### 4. Внешний том для статики и зависимостей

- В `docker-compose.yml` указаны тома для хранения данных базы данных и кода приложения.

### 5. docker-compose для старта и сборки

- Проект содержит `docker-compose.yml`, который автоматизирует сборку и запуск контейнеров.

### 6. Использование базы данных

- В `docker-compose.yml` задействован контейнер с PostgreSQL.

### 7. Автоматические миграции при старте

- Скрипт `entrypoint.sh` выполняет миграции автоматически при запуске контейнера:
  ```bash
  flask db upgrade
  ```

### 8. Запуск от непривилегированного пользователя

- В Dockerfile добавлен непривилегированный пользователь:
  ```dockerfile
  RUN adduser -D user && chown -R user:user /app
  USER user
  ```

### 9. Очистка кеша после установки

- Dockerfile очищает кеш после установки зависимостей:
  ```dockerfile
  RUN pip install --no-cache-dir -r requirements.txt
  ```

## Установка и запуск проекта

### 1. Клонирование репозитория

```bash
  git clone <repository-url>
  cd flask-project
```

### 2. Сборка и запуск контейнеров

```bash
  docker-compose up --build
```

После успешного запуска приложение будет доступно по адресу http://localhost:5001.

### 3. Остановка контейнеров

```bash
  docker-compose down
```

### 4. Просмотр логов

```bash
  docker-compose logs
```

## Структура проекта

```
flask-project/
│
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   └── templates/
│       └── index.html
│
├── migrations/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── entrypoint.sh
```

## Примечания

- Убедитесь, что у вас установлен Docker и Docker Compose.
- База данных сохраняет данные между перезапусками контейнеров благодаря тому, что использует том `pgdata`.
- Для очистки базы данных выполните:

```bash
  docker-compose down -v
```

- Итоговый вес контейнера составляет ~90мб

