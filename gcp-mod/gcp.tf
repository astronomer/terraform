module "gcp-astro" {
  source = "/Users/kaxil/Documents/Astro/Github/terraform/gcp"

  bastion_admins = [
    "user:greg@astronomer.io",
    "user:kaxil@astronomer.io",
    "user:ian@astronomer.io",
  ]

  bastion_users = [
    "user:greg@astronomer.io",
    "user:kaxil@astronomer.io",
    "user:ian@astronomer.io",
  ]

  cluster_name                     = "cloud-dev-cluster"
  gke_secondary_ip_ranges_pods     = "10.32.0.0/14"
  gke_secondary_ip_ranges_services = "10.98.0.0/20"
}
