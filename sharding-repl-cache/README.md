# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

Отправьте get запрос http://localhost:8080/helloDoc/users

Выведется список users. При повторной отправке запроса он отрабоатет быстрее.

