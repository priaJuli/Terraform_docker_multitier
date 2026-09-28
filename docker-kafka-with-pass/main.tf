
# 5. Create Docker Volume for Kafka Data
resource "docker_volume" "kafka_data" {
  name = "kafka_data_volume"
}

resource "docker_container" "kafka" {
  name  = "kafka-broker"
  image = "apache/kafka:3.7.0" # Using modern KRaft (Zookeeper-less) version

  # Expose port 9092 for external client access
  ports {
    internal = 9092
    external = 9092
    ip       = "0.0.0.0"
  }

  # Mount the JAAS config into the container
  volumes {
    host_path      = "/opt/kafka/config/broker_jaas.conf"
    container_path = "/opt/kafka/config/broker_jaas.conf"
  }

  # Mount the client properties into the container (Req 4)
  volumes {
    host_path      = "/opt/kafka/config/client.properties"
    container_path = "/opt/kafka/client.properties"
  }

  # Mount the persistent data volume (Req 5)
  volumes {
    volume_name    = docker_volume.kafka_data.name
    container_path = "/var/lib/kafka/data"
  }

  # Kafka Environment Variables (KRaft mode + SASL configuration)
  env = [
    # KRaft (Zookeeper-less) basic config
    "KAFKA_NODE_ID=1",
    "KAFKA_PROCESS_ROLES=broker,controller",
    "KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093",
    
    # LISTENERS CONFIG (Crucial for Req 1: External Access)
    "KAFKA_LISTENERS=SASL_PLAINTEXT://:9092,CONTROLLER://:9093",
    "KAFKA_ADVERTISED_LISTENERS=SASL_PLAINTEXT://${var.vps_public_ip}:9092",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,SASL_PLAINTEXT:SASL_PLAINTEXT",
    "KAFKA_INTER_BROKER_LISTENER_NAME=SASL_PLAINTEXT",
    
    # SASL / JAAS Config (Req 2 & 3)
    "KAFKA_SASL_ENABLED_MECHANISMS=PLAIN",
    "KAFKA_SASL_MECHANISM_CONTROLLER_PROTOCOL=PLAIN",
    "KAFKA_OPTS=-Djava.security.auth.login.config=/opt/kafka/config/broker_jaas.conf",
    
    # Data directory
    "KAFKA_LOG_DIRS=/var/lib/kafka/data"
  ]

  depends_on = [null_resource.push_kafka_configs]
  
  # Restart policy for resilience
  restart = "unless-stopped"
}