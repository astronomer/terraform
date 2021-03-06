resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.deployment_id}-astro-db-${random_id.db_name_suffix.hex}"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  depends_on = [
    "google_service_networking_connection.private_vpc_connection",
  ]

  settings {
    tier              = "${var.cloud_sql_tier}"
    availability_type = "${var.cloud_sql_availability_type}"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${google_compute_network.core.self_link}"
    }
  }
}

resource "random_string" "postgres_airflow_password" {
  count   = "${ var.postgres_airflow_password == "" ? 1 : 0 }"
  length  = 8
  special = false
}

resource "google_sql_user" "airflow" {
  name     = "airflow"
  instance = "${google_sql_database_instance.instance.name}"
  password = "${local.postgres_airflow_password}"
}
