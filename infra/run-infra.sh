#!/bin/bash

BASE_DIR="secrets"

DIRS=("broker1" "broker2" "broker3" "replica-broker1" "replica-broker2" "replica-broker3" "ca" "client" "mirrormaker")

if [ ! -d "$BASE_DIR" ]; then
    mkdir "$BASE_DIR"
    echo "Создана директория: $BASE_DIR"
else
    echo "Директория $BASE_DIR уже существует"
fi

for DIR in "${DIRS[@]}"; do
    FULL_PATH="$BASE_DIR/$DIR"
    if [ ! -d "$FULL_PATH" ]; then
        mkdir "$FULL_PATH"
        echo "Создана директория: $FULL_PATH"
    else
        echo "Директория $FULL_PATH уже существует"
    fi
done

# Запуск скрипта генерации сертификатов
echo "Генерация сертификатов..."
chmod +x generate-certs.sh
./generate-certs.sh
chmod +x generate-replica-certs.sh
./generate-replica-certs.sh

# Запуск Docker Compose
echo "Запуск кластера Kafka..."
docker-compose up -d

# Создание директорий для сертификатов в контейнерах
docker exec broker1 mkdir -p /opt/bitnami/kafka/config/certs
docker exec broker2 mkdir -p /opt/bitnami/kafka/config/certs
docker exec broker3 mkdir -p /opt/bitnami/kafka/config/certs
docker exec replica-broker1 mkdir -p /opt/bitnami/kafka/config/certs
docker exec replica-broker2 mkdir -p /opt/bitnami/kafka/config/certs
docker exec replica-broker3 mkdir -p /opt/bitnami/kafka/config/certs

# Ожидание запуска брокеров
echo "Ожидание запуска брокеров..."
sleep 80

# Настройка топиков и ACL
echo "Настройка топиков и прав доступа..."
chmod +x setup-topics.sh
./setup-topics.sh

echo "Кластер Kafka успешно запущен с SSL и ACL."
echo "Теперь вы можете использовать скрипты producer.sh и consumer.sh для тестирования:"
echo "  ./producer.sh topic-1  - для отправки сообщений в топик-1"
echo "  ./consumer.sh topic-1  - для чтения сообщений из топика-1"
echo "  ./producer.sh topic-2  - для отправки сообщений в топик-2"
echo "  ./consumer.sh topic-2  - для чтения сообщений из топика-2 (должно завершиться ошибкой доступа)"
