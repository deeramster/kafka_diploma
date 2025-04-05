#!/bin/bash


# Генерация CA (Certificate Authority)
openssl req -new -x509 -keyout secrets/ca/ca-key -out secrets/ca/ca-cert -days 365 -subj '/CN=ca.kafka.ssl/OU=Test/O=Company/L=City/ST=State/C=RU' -passin pass:test1234 -passout pass:test1234

# Генерация ключей и сертификатов для брокеров

# Broker 1
keytool -keystore secrets/broker1/kafka.broker1.keystore.jks -alias broker1 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=broker1.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/broker1/kafka.broker1.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Broker 2
keytool -keystore secrets/broker2/kafka.broker2.keystore.jks -alias broker2 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=broker2.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/broker2/kafka.broker2.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Broker 3
keytool -keystore secrets/broker3/kafka.broker3.keystore.jks -alias broker3 -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=broker3.kafka.ssl, OU=Test, O=Company, L=City, ST=State, C=RU"
keytool -keystore secrets/broker3/kafka.broker3.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация запросов на подписание сертификатов (CSR)
keytool -keystore secrets/broker1/kafka.broker1.keystore.jks -alias broker1 -certreq -file secrets/broker1/broker1.csr -storepass test1234 -keypass test1234
keytool -keystore secrets/broker2/kafka.broker2.keystore.jks -alias broker2 -certreq -file secrets/broker2/broker2.csr -storepass test1234 -keypass test1234
keytool -keystore secrets/broker3/kafka.broker3.keystore.jks -alias broker3 -certreq -file secrets/broker3/broker3.csr -storepass test1234 -keypass test1234

# Подписание CSR с помощью CA
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/broker1/broker1.csr -out secrets/broker1/broker1-signed-cert -days 365 -CAcreateserial -passin pass:test1234
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/broker2/broker2.csr -out secrets/broker2/broker2-signed-cert -days 365 -CAcreateserial -passin pass:test1234
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/broker3/broker3.csr -out secrets/broker3/broker3-signed-cert -days 365 -CAcreateserial -passin pass:test1234

# Импорт подписанных сертификатов в keystore
keytool -keystore secrets/broker1/kafka.broker1.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/broker1/kafka.broker1.keystore.jks -alias broker1 -import -file secrets/broker1/broker1-signed-cert -storepass test1234 -keypass test1234 -noprompt

keytool -keystore secrets/broker2/kafka.broker2.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/broker2/kafka.broker2.keystore.jks -alias broker2 -import -file secrets/broker2/broker2-signed-cert -storepass test1234 -keypass test1234 -noprompt

keytool -keystore secrets/broker3/kafka.broker3.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/broker3/kafka.broker3.keystore.jks -alias broker3 -import -file secrets/broker3/broker3-signed-cert -storepass test1234 -keypass test1234 -noprompt

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

# Генерация Keystore для MirrorMaker
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -validity 365 -genkey -keyalg RSA -storepass test1234 -keypass test1234 -dname "CN=mirrormaker.kafka.ssl, OU=MirrorMaker, O=Company, L=City, ST=State, C=RU"

# Создание Truststore для MirrorMaker (импорт CA Certificate)
# Предполагается, что у вас уже есть ca-cert в secrets/ca/ca-cert
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.truststore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt

# Генерация запроса на подписание сертификата (CSR) для MirrorMaker
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -certreq -file secrets/mirrormaker/mirrormaker.csr -storepass test1234 -keypass test1234

# Подписание CSR MirrorMaker (с использованием OpenSSL)
openssl x509 -req -CA secrets/ca/ca-cert -CAkey secrets/ca/ca-key -in secrets/mirrormaker/mirrormaker.csr -out secrets/mirrormaker/mirrormaker-signed-cert -days 365 -CAcreateserial -passin pass:test1234

# Импорт подписанного сертификата в Keystore MirrorMaker
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias CARoot -import -file secrets/ca/ca-cert -storepass test1234 -keypass test1234 -noprompt
keytool -keystore secrets/mirrormaker/kafka.mirrormaker.keystore.jks -alias mirrormaker -import -file secrets/mirrormaker/mirrormaker-signed-cert -storepass test1234 -keypass test1234 -noprompt


echo "Сертификаты и хранилища ключей успешно созданы."
