variable "name_var2" {
  description = "name"
}

# VPC
resource "google_compute_network" "vpc2" {
  name                    = "${var.name_var2}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet2" {
  name          = "${var.name_var2}-subnet"
  region        = var.region
  network       = google_compute_network.vpc2.name
  ip_cidr_range = "10.10.0.0/24"
}

# GKE cluster
resource "google_container_cluster" "primary2" {
  name     = "${var.name_var2}-gke"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc2.name
  subnetwork = google_compute_subnetwork.subnet2.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes2" {
  name       = "${google_container_cluster.primary2.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary2.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    #labels = {
    #env = var.project_id
    #}

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.name_var2}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
