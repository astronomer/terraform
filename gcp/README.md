# Terraform Module for Astronomer for GCP

[Terraform](https://www.terraform.io/) is a simple and powerful tool that lets us write, plan and create infrastructure as code. This code will allow you to efficiently provision the infrastructure required to run the Astronomer platform.

## Features
* Private Kubernetes cluster
* Cloud SQL with Postgres
* Bastion host for secure cluster administration

## Architecture

![Astronomer GCP Architecture](images/Astronomer-GCP-white-background.png)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bastion\_admins | List of email addresses of users with Sudo who be able to SSH into Bastion using Cloud IAP & OS Login | list | n/a | yes |
| bastion\_image\_family | The Name & Project of the Image Family with which Bastion will be created. | map | `{ "name": "ubuntu-1804-lts", "project": "ubuntu-os-cloud" }` | no |
| bastion\_users | List of email addresses of users who be able to SSH into Bastion using Cloud IAP & OS Login | list | n/a | yes |
| cloud\_sql\_availability\_type | Whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL). | string | `"REGIONAL"` | no |
| cloud\_sql\_tier | The machine tier (First Generation) or type (Second Generation) to use. See https://cloud.google.com/sql/pricing for supported tiers. | string | `"db-f1-micro"` | no |
| cluster\_name | The name of the GKE cluster | string | n/a | yes |
| gke\_secondary\_ip\_ranges\_pods | GKE Secondary IP Ranges for Pods | string | n/a | yes |
| gke\_secondary\_ip\_ranges\_services | GKE Secondary IP Ranges for Services | string | n/a | yes |
| iap\_cidr\_ranges | Cloud IAP CIDR Range as described on https://cloud.google.com/iap/docs/using-tcp-forwarding | list | `[ "35.235.240.0/20" ]` | no |
| machine\_type | The GCP machine type for GKE worker nodes | string | `"n1-standard-8"` | no |
| max\_node\_count | The maximum amount of worker nodes in GKE cluster | string | `"10"` | no |
| min\_node\_count | The minimum amount of worker nodes in GKE cluster | string | `"3"` | no |
| node\_version | The version of Kubernetes in GKE cluster | string | `"1.12.7-gke.7"` | no |
| postgres\_airflow\_password | Password for the 'airflow' user in Cloud SQL Postgres Instance. If not specified, creates a random Password. | string | `""` | no |
| region | The GCP region to deploy infrastructure into | string | `"us-east4"` | no |
| zone | The GCP zone to deploy infrastructure into | string | `"us-east4-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_ip | Bastion IP Address |
| bastion\_subnetwork\_selflink | Selflink for the Bastion SubNetwork |
| container\_registry\_bucket\_name | Cloud Storage Bucket Name to be used for Container Registry |
| gke\_cluster\_master\_cidr | CIDR Range for Cluster Master |
| gke\_cluster\_pods\_cidr | CIDR Range for Cluster Pods |
| gke\_cluster\_services\_cidr | CIDR Range for Cluster Services |
| gke\_subnetwork\_selflink | Selflink for the GKE SubNetwork |
| postgres\_ip | Postgres IP Address |
| postgres\_password | Postgres Password |
| postgres\_user | Postgres Username |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Usage

```hcl
module "gcp-astro" {
  source = "git::https://github.com/astronomer/terraform.git//gcp"

  bastion_admins = [
    "user:testuser@gmail.com",
    "user:testemail@gmail.com",
  ]

  bastion_users = [
    "user:testuser@gmail.com",
    "user:testemail@gmail.com",
  ]

  cluster_name                     = "cloud-dev-cluster"
  gke_secondary_ip_ranges_pods     = "10.32.0.0/14"
  gke_secondary_ip_ranges_services = "10.98.0.0/20"
}
```

Use both `google` and `google-beta` providers as few resources use `google-beta` provider too:
```hcl
provider google {
  region  = "${var.region}"
  project = "${var.project}"
}

provider google-beta {
  region  = "${var.region}"
  project = "${var.project}"
}
```

## Steps to use the module

1. Set Google application default credentials:
    ```bash
    gcloud auth application-default login
    ```

1. Get the latest terraform module:

    ```bash
    terraform get -update
    ```
    This will download the module to `.terraform` directory in the current folder.

1. Initialise terraform:
    
    ```bash
    terraform init
    ```
	
1. Check what the infrastructure changes would be made:

    ```bash
    terraform plan
    ```
	
1. Run the terraform files:

    ```bash
    terraform apply
    ```

### Access Kubernetes Cluster

Replace `${GCP_PROJECT}` in all the commands below with your GCP Project ID.

1. SSH into Bastion using IAP:

    ```bash
    gcloud beta compute ssh bastion --project ${GCP_PROJECT} --tunnel-through-iap
    ```
  
1. Generate Kubeconfig entry to connect to k8s cluster:

    ```bash
    gcloud beta container clusters get-credentials cloud-dev-cluster --region us-east4 --project ${GCP_PROJECT} --internal-ip
    ```
    
    Make sure that `--internal-ip` is passed to the command.
    
1. Test `kubectl` command:

    ```bash
    kubectl get po --all-namespaces
    ```

1. In order to access the k8s cluster as an admin:
    
    * Run the following command
     
      ```bash
      gcloud auth login
      ```
    
    * To authenticate with the cluster: 
      
      ```bash
      gcloud beta container clusters get-credentials cloud-dev-cluster --region us-east4 --project ${GCP_PROJECT} --internal-ip
      ```
      
    * Test it using the following command:
    
      ```bash
      kubectl create ns astronomer
      ```

    To run Admin commands on the k8s cluster, the user needs to be listed in `bastion_admins` terraform variable as `bastion_admins` get [**Container Admin**](https://cloud.google.com/kubernetes-engine/docs/how-to/iam#kubernetes-engine-roles) permissions (`roles/container.admin`).
