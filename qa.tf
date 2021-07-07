# terraform {

#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "3.52.0"
#     }
#   }

#   #required_version = "~> 0.14"

#   backend "remote" {
#     organization = "sreyo23"

#     workspaces {
#       name = "gke_cluster"
#     }
#   }

# }


# variable "region" {
#   default     = "us-central1"
#   description = "region"
# }

# variable "zone" {
#   default     = "us-central1-a"
#   description = "zone"
# }

variable "name_var1" {
  description = "name"
}

# provider "google" {
#   region = var.region
# }

# variable "gke_username" {
#   default     = ""
#   description = "gke username"
# }

# variable "gke_password" {
#   default     = ""
#   description = "gke password"
# }

# variable "gke_num_nodes" {
#   default     = 1
#   description = "number of gke nodes"
# }

# VPC
resource "google_compute_network" "vpc1" {
  name                    = "${var.name_var1}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet1" {
  name          = "${var.name_var1}-subnet"
  region        = var.region
  network       = google_compute_network.vpc1.name
  ip_cidr_range = "10.10.0.0/24"
}

# GKE cluster
resource "google_container_cluster" "primary1" {
  name     = "${var.name_var1}-gke"
  location = var.zone
  #location = var.region
  #zone     = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc1.name
  subnetwork = google_compute_subnetwork.subnet1.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes1" {
  name       = "${google_container_cluster.primary1.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary1.name
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
    tags         = ["gke-node", "${var.name_var1}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
