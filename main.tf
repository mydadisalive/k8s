# main.tf

provider "google" {
  credentials = file("key.json")
  project     = "cosmic-palace-393118"
  region      = "us-central1"  # Replace with your desired region
}

resource "google_container_cluster" "my_cluster" {
  name               = "my-gke-cluster"
  location           = "us-central1"  # Replace with your desired zone/region
  initial_node_count = 2  

#   remove_default_node_pool = true  # Remove the default node pool created by Terraform

  master_auth {
    # At least one "client_certificate_config" block is required.
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "null_resource" "configure_kubectl" {
  # This resource will trigger after the GKE cluster is created
  depends_on = [google_container_cluster.my_cluster]

  # The inline provisioner will configure kubectl
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials my-gke-cluster --zone=us-central1 --project=cosmic-palace-393118"
  }
}

resource "null_resource" "deploy_kubernetes_resources" {
  # This resource will trigger after the GKE cluster is created and kubectl is configured
  depends_on = [null_resource.configure_kubectl]

  # The inline provisioner will run the kubectl apply command
  provisioner "local-exec" {
    command = "kubectl apply -f flask-app.yaml"
    interpreter = ["bash", "-c"]
  }
}