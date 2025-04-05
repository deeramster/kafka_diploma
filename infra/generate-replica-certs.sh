#!/bin/bash


# Генерация ключей и сертификатов для брокеров

# Broker 1
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.keystore.jks -alias replica-broker1 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=replica-broker1.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Broker 2
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.keystore.jks -alias replica-broker2 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=replica-broker2.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Broker 3
keytool -keystore secrets/replica-broker3/kafka.replica-broker3.keystore.jks -alias replica-broker3 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=replica-broker3.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/replica-broker3/kafka.replica-broker3.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация запросов на подписание сертификатов (CSR)
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.keystore.jks -alias replica-broker1 -certreq -file secrets/replica-broker1/replica-broker1.csr -storepass test1234 -keypass test1234
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.keystore.jks -alias replica-broker2 -certreq -file secrets/replica-broker2/replica-broker2.csr -storepass test1234 -keypass test1234
keytool -keystore secrets/replica-broker3/kafka.replica-broker3.keystore.jks -alias replica-broker3 -certreq -file secrets/replica-broker3/replica-broker3.csr -storepass test1234 -keypass test1234

# Подписание CSR с помощью CA
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/replica-broker1/replica-broker1.csr -out secrets/replica-broker1/replica-broker1-signed-cert -days 365 -CAcreateserial -passin pass:test1234
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/replica-broker2/replica-broker2.csr -out secrets/replica-broker2/replica-broker2-signed-cert -days 365 -CAcreateserial -passin pass:test1234
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/replica-broker3/replica-broker3.csr -out secrets/replica-broker3/replica-broker3-signed-cert -days 365 -CAcreateserial -passin pass:test1234

# Импорт подписанных сертификатов в keystore
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.keystore.jks -alias replica-broker1 -import -file secrets/replica-broker1/replica-broker1-signed-cert -storepass test1234 -keypass test1234 -noprompt

keytool -keystore secrets/replica-broker2/kafka.replica-broker2.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.keystore.jks -alias replica-broker2 -import -file secrets/replica-broker2/replica-broker2-signed-cert -storepass test1234 -keypass test1234 -noprompt

keytool -keystore secrets/replica-broker3/kafka.replica-broker3.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/replica-broker3/kafka.replica-broker3.keystore.jks -alias replica-broker3 -import -file secrets/replica-broker3/replica-broker3-signed-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация ключей для клиента (продюсер и консьюмер)
keytool -keystore secrets/client/kafka.client.keystore.jks -alias client -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=client.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/client/kafka.client.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация запроса на подписание сертификата для клиента
keytool -keystore secrets/client/kafka.client.keystore.jks -alias client -certreq -file secrets/client/client.csr -storepass test1234 -keypass test1234

# Подписание CSR клиента
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/client/client.csr -out secrets/client/client-signed-cert -days 365 -CAcreateserial -passin pass:test1234

# Импорт подписанного сертификата клиента
keytool -keystore secrets/client/kafka.client.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/client/kafka.client.keystore.jks -alias client -import -file secrets/client/client-signed-cert -storepass test1234 -keypass test1234 -noprompt

echo "Сертификаты и хранилища ключей успешно созданы."
