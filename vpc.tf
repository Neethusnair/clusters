terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }

  #required_version = "~> 0.14"

  backend "remote" {
    organization = "sreyo23"

    workspaces {
      name = "gke_cluster"
    }
  }

}


variable "region" {
  default     = "us-central1"
  description = "region"
}

variable "zone" {
  default     = "us-central1-a"
  description = "zone"
}

variable "name_var" {
  description = "name"
}

provider "google" {
  #credentials = file("**")
  #project     = var.project_id
  region = var.region
  #zone        = var.zone
}


# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.name_var}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_var}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
