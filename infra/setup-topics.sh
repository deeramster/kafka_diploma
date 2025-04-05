#!/bin/bash

# Variables
CLIENT_PRINCIPAL="User:CN=client.kafka.ssl,OU=Test,O=Company,L=City,ST=State,C=RU"
MIRRORMAKER_PRINCIPAL="User:CN=mirrormaker.kafka.ssl,OU=Test,O=Company,L=City,ST=State,C=RU"
SOURCE_BROKER="broker1"
TARGET_BROKER="replica-broker1"
BOOTSTRAP_SERVER_SOURCE="${SOURCE_BROKER}:9093"
BOOTSTRAP_SERVER_TARGET="${TARGET_BROKER}:9093"
COMMAND_CONFIG="/opt/bitnami/kafka/config/certs/client-ssl.properties"

# ------------------- Client permissions (NOT MirrorMaker) -------------------
echo "Setting client permissions..."

# Create topics if they don't exist
echo "Creating topic shop-api..."
docker exec ${SOURCE_BROKER} kafka-topics.sh --create --topic shop-api --partitions 3 --replication-factor 3 \
  --if-not-exists \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

echo "Creating topic client-api..."
docker exec ${SOURCE_BROKER} kafka-topics.sh --create --topic client-api --partitions 3 --replication-factor 3 \
  --if-not-exists \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

# Set ACLs for shop-api and client-api (only what client needs)
echo "Setting ACL for shop-api (client)..."
docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${CLIENT_PRINCIPAL}" \
  --operation Read --operation Write \
  --topic shop-api \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

echo "Setting ACL for client-api (client)..."
docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${CLIENT_PRINCIPAL}" \
  --operation Write \
  --topic client-api \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

# ------------------- MirrorMaker permissions -------------------
echo "Setting MirrorMaker permissions..."

# Source permissions
echo "Setting source permissions (${SOURCE_BROKER})..."

# Topic permissions
docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic '*' \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

# Group permissions
docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe \
  --group '*' \
  --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

# MirrorMaker internal topics
docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-offset-syncs --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-heartbeats --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-checkpoints --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-configs --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

docker exec ${SOURCE_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-status --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

# Target permissions
echo "Setting target permissions (${TARGET_BROKER})..."

# ------------------- Target permissions -------------------
echo "Setting target permissions (${TARGET_BROKER})..."

# Topic permissions (using only supported operations)
docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Write --operation Alter \
  --topic '*' \
  --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

# Group permissions
docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe \
  --group '*' \
  --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

# MirrorMaker internal topics
docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-offset-syncs --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-heartbeats --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-checkpoints --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-configs --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

docker exec ${TARGET_BROKER} kafka-acls.sh --add --allow-principal "${MIRRORMAKER_PRINCIPAL}" \
  --operation Read --operation Describe --operation Create --operation Alter --operation DescribeConfigs \
  --topic mm2-status --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}

echo "Permissions configured."

echo "Source topic list:"
docker exec ${SOURCE_BROKER} kafka-topics.sh --list --bootstrap-server ${BOOTSTRAP_SERVER_SOURCE} --command-config ${COMMAND_CONFIG}

echo "Target topic list:"
docker exec ${TARGET_BROKER} kafka-topics.sh --list --bootstrap-server ${BOOTSTRAP_SERVER_TARGET} --command-config ${COMMAND_CONFIG}
