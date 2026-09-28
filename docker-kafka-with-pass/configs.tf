# Create temporary directory for configs
resource "local_file" "broker_jaas" {
  content = <<-EOT
    KafkaServer {
        org.apache.kafka.common.security.plain.PlainLoginModule required
        username="admin"
        password="${var.kafka_admin_password}"
        user_admin="${var.kafka_admin_password}"
        user_user="${var.kafka_user_password}";
    };
  EOT
  filename = "${path.module}/tmp_kafka_configs/broker_jaas.conf"
}

resource "local_file" "client_properties" {
  content = <<-EOT
    security.protocol=SASL_PLAINTEXT
    sasl.mechanism=PLAIN
    sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="user" password="${var.kafka_user_password}";
  EOT
  filename = "${path.module}/tmp_kafka_configs/client.properties"
}

resource "null_resource" "push_kafka_configs" {
  depends_on = [local_file.broker_jaas, local_file.client_properties]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.vps_public_ip 
    agent       = true 
  }

  # Create the directory on the VPS host
  provisioner "remote-exec" {
    inline = ["mkdir -p /opt/kafka/config"]
  }

  # Push broker_jaas.conf
  provisioner "file" {
    source      = local_file.broker_jaas.filename
    destination = "/opt/kafka/config/broker_jaas.conf"
  }

  # Push client.properties
  provisioner "file" {
    source      = local_file.client_properties.filename
    destination = "/opt/kafka/config/client.properties"
  }
}