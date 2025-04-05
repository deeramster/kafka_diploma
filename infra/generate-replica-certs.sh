#!/bin/bash

# Генерация ключей и сертификатов для брокеров

# Replica Broker 1
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.keystore.jks -alias replica-broker1 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=replica-broker1.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/replica-broker1/kafka.replica-broker1.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Replica Broker 2
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.keystore.jks -alias replica-broker2 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=replica-broker2.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/replica-broker2/kafka.replica-broker2.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Replica Broker 3
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

# Генерация ключей для клиента (mirrormaker)
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=mirrormaker.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация запроса на подписание сертификата для клиента
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -certreq -file secrets/mirrormaker/mirrormaker.csr -storepass test1234 -keypass test1234

# Подписание CSR клиента
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/mirrormaker/mirrormaker.csr -out secrets/mirrormaker/mirrormaker-signed-cert -days 365 -CAcreateserial -passin pass:test1234

# Импорт подписанного сертификата клиента
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -import -file secrets/mirrormaker/mirrormaker-signed-cert -storepass test1234 -keypass test1234 -noprompt

echo "Сертификаты и хранилища ключей для replica кластера успешно созданы."
