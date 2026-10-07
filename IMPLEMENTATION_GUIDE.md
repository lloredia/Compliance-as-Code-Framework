# Implementation guide

This repository is a single Terraform root, `terraform/`, that composes the modules under `modules/`.

## What gets created

- CloudTrail in all regions, with log-file validation, a KMS-encrypted bucket, CloudWatch Logs, and an SNS notification topic
- VPC flow logs for each VPC in the provider region
- An IAM account password policy that cannot be set below the CIS floor enforced by the module
- Account-level S3 Block Public Access
- Optional KMS encryption and Block Public Access on pre-existing buckets (`manage_existing_s3_buckets`, default `false`)
- An AWS Config recorder, delivery channel, and CIS-aligned conformance pack
- Config rules `restricted-ssh` and `restricted-common-ports`
- CloudWatch metric filters and alarms for CIS 4.1–4.15

## Apply

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
cd terraform
terraform init -backend=false
terraform plan
terraform apply
```

For a shared backend, copy `backend.hcl.example` to `backend.hcl` and run `terraform init -backend-config=backend.hcl`. Create the S3 bucket and DynamoDB table first. The example file has the commands.

## Continuous checks

GitHub Actions runs format, validate, tflint, checkov, OPA/conftest, ruff, and pytest. It does not apply Terraform and it does not run Prowler. See the README for the local plan command that feeds conftest.

## Scans

Keep Prowler JSON on disk and summarize it:

```bash
python3 scripts/analyze-prowler.py prowler-output.json
```

The script prints counts by service and severity and strips account IDs, ARNs, emails, and IAM path names. Do not commit the raw report.

## Troubleshooting

- **Bucket name already taken.** Change `project_name`. Bucket names include that prefix and the account ID from the caller identity data source.
- **CloudTrail or Config already exists.** Import the existing trail or recorder, or remove it before apply. A region can have one Config recorder.
- **Password policy variables rejected.** The IAM module refuses a minimum length under 14, a max age over 90, or a reuse memory under 24.
- **Existing buckets changed unexpectedly.** Leave `manage_existing_s3_buckets` false unless you intend to adopt buckets outside the project prefix.
