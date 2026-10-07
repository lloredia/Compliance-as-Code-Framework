terraform {
  # Partial configuration. Copy backend.hcl.example to backend.hcl and run:
  #   terraform init -backend-config=backend.hcl
  # CI and local validation use: terraform init -backend=false
  backend "s3" {}
}
