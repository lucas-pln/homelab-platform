# Terraform Proxmox API Authentication Test

This directory contains a minimal Terraform configuration used to verify that Terraform can authenticate to the Proxmox API using an API token.

Credentials are not stored in Terraform files. The Proxmox API token is injected using environment variables.

This test is read-only. It does not create, modify, or delete any Proxmox resources.

## Files

```text
terraform/
├── main.tf
├── variables.tf
└── terraform.tfvars.example
```