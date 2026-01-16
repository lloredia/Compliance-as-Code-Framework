<div id="top">

<!-- HEADER STYLE: CLASSIC -->
<div align="center">


# COMPLIANCE-AS-CODE-FRAMEWORK

<em>Automate Compliance, Elevate Security, Accelerate Innovation</em>

<!-- BADGES -->
<img src="https://img.shields.io/github/last-commit/lloredia/Compliance-as-Code-Framework?style=flat&logo=git&logoColor=white&color=0080ff" alt="last-commit">
<img src="https://img.shields.io/github/languages/top/lloredia/Compliance-as-Code-Framework?style=flat&color=0080ff" alt="repo-top-language">
<img src="https://img.shields.io/github/languages/count/lloredia/Compliance-as-Code-Framework?style=flat&color=0080ff" alt="repo-language-count">

<em>Built with the tools and technologies:</em>

<img src="https://img.shields.io/badge/JSON-000000.svg?style=flat&logo=JSON&logoColor=white" alt="JSON">
<img src="https://img.shields.io/badge/Markdown-000000.svg?style=flat&logo=Markdown&logoColor=white" alt="Markdown">
<img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style=flat&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash">
<img src="https://img.shields.io/badge/HCL-006BB6.svg?style=flat&logo=HCL&logoColor=white" alt="HCL">
<img src="https://img.shields.io/badge/Python-3776AB.svg?style=flat&logo=Python&logoColor=white" alt="Python">
<img src="https://img.shields.io/badge/GitHub%20Actions-2088FF.svg?style=flat&logo=GitHub-Actions&logoColor=white" alt="GitHub%20Actions">
<img src="https://img.shields.io/badge/Terraform-844FBA.svg?style=flat&logo=Terraform&logoColor=white" alt="Terraform">

</div>
<br>

---

Automated AWS security compliance framework based on CIS AWS Foundations Benchmark. This project uses Terraform for infrastructure-as-code and Prowler for continuous compliance monitoring.

## 📊 Current Compliance Status

Based on initial Prowler scan (2026-01-12):
- **Total Checks**: 278
- **Passed**: 71 (25.5%)
- **Failed**: 204 (73.4%)
- **Critical/High Issues**: 101

### Top Problem Areas
1. **EC2**: 68 failures (security groups, encryption, monitoring)
2. **CloudTrail**: 19 failures (logging not enabled)
3. **VPC**: 17 failures (flow logs, network ACLs)
4. **IAM**: 10 failures (password policies, MFA, access keys)
5. **S3**: 7 failures (encryption, logging)

## 🎯 Project Goals

**Phase 1** (Current): Automate fixes for high-priority CIS controls
- ✅ Enable CloudTrail (CIS 3.1)
- ✅ Enable VPC Flow Logs
- ✅ IAM Password Policy (CIS 1.8-1.11)
- 🚧 S3 Bucket Encryption
- 🚧 Security Group Rules Audit

**Phase 2** (Next): Monitoring and alerting
- CloudWatch metric filters and alarms
- SNS notifications for compliance violations

**Phase 3** (Future): Advanced automation
- AWS Config rules
- Automated incident response
- Compliance dashboards

## 🏗️ Project Structure

```
compliance-as-code/
├── modules/                      # Reusable Terraform modules
│   ├── cloudtrail/              # Multi-region CloudTrail logging
│   ├── vpc-flow-logs/           # VPC Flow Logs enablement
│   ├── iam-password-policy/     # IAM password policy enforcement
│   ├── s3-encryption/           # S3 default encryption (TODO)
│   └── security-groups/         # Security group auditing (TODO)
├── terraform/                    # Root Terraform configuration
│   ├── main.tf                  # Main infrastructure code
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   └── terraform.tfvars         # Variable values (gitignored)
├── .github/workflows/           # CI/CD automation
│   └── compliance.yml           # Compliance check workflow
└── scripts/                     # Helper scripts
    ├── analyze-prowler.py       # Parse Prowler results
    └── check-compliance.sh      # Quick compliance check
```

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform >= 1.0
- Python 3.11+
- Prowler

### 1. Run Initial Compliance Scan

```bash
# Install Prowler
pip install prowler

# Run CIS benchmark scan
prowler aws --compliance cis_1.5_aws
```

### 2. Deploy Compliance Fixes

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the fixes
terraform apply
```

### 3. Verify Improvements

```bash
# Run Prowler again to see improvements
prowler aws --compliance cis_1.5_aws

# Compare before/after results
python3 ../scripts/analyze-prowler.py --compare
```

## 🔧 Configuration

### Terraform Variables

Create a `terraform/terraform.tfvars` file:

```hcl
aws_region              = "us-east-1"
environment             = "prod"
project_name            = "my-company-compliance"
cloudtrail_retention_days = 365
flowlog_retention_days    = 30

tags = {
  Owner       = "SecurityTeam"
  CostCenter  = "IT-Security"
}
```

### Module Customization

Each module can be customized independently:

**CloudTrail Module:**
```hcl
module "cloudtrail" {
  source = "../modules/cloudtrail"
  
  trail_name         = "my-trail"
  bucket_name        = "my-cloudtrail-bucket"
  log_retention_days = 365
}
```

**VPC Flow Logs Module:**
```hcl
module "vpc_flow_logs" {
  source = "../modules/vpc-flow-logs"
  
  enable_per_vpc     = true
  traffic_type       = "ALL"  # or "ACCEPT" or "REJECT"
  log_retention_days = 30
}
```

**IAM Password Policy Module:**
```hcl
module "iam_password_policy" {
  source = "../modules/iam-password-policy"
  
  minimum_password_length   = 14
  max_password_age          = 90
  password_reuse_prevention = 24
}
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **On Pull Request:**
   - Runs Prowler compliance scan
   - Validates Terraform code
   - Runs security scan with Checkov
   - Creates Terraform plan
   - Comments plan on PR

2. **On Push to Main:**
   - Runs full compliance scan
   - Applies Terraform changes
   - Runs post-deployment verification

3. **Daily Schedule (2 AM UTC):**
   - Automated compliance monitoring
   - Generates compliance reports

### Required GitHub Secrets

- `AWS_ROLE_ARN`: IAM role ARN for GitHub Actions (use OIDC)

## 📈 Monitoring Compliance

### View Prowler Results

```bash
# Generate HTML report
prowler aws --compliance cis_1.5_aws --output-formats html

# View in browser
open prowler-output-*.html
```

### Analyze Trends

```bash
# Compare multiple scans
python3 scripts/analyze-prowler.py \
  --before prowler-2026-01-12.json \
  --after prowler-2026-01-19.json
```

## 🛡️ Security Considerations

### Terraform State

- **Production**: Use S3 backend with state locking (DynamoDB)
- **Enable encryption** on the state bucket
- **Enable versioning** for state recovery

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "compliance/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### IAM Permissions

The IAM role/user running Terraform needs:
- CloudTrail: `CreateTrail`, `UpdateTrail`
- S3: `CreateBucket`, `PutBucketPolicy`
- EC2: `CreateFlowLogs`, `DescribeVpcs`
- IAM: `UpdateAccountPasswordPolicy`
- CloudWatch: `CreateLogGroup`, `PutRetentionPolicy`

## 🐛 Troubleshooting

### CloudTrail Already Exists

If a trail already exists:
```bash
# Import existing trail
terraform import module.cloudtrail.aws_cloudtrail.main existing-trail-name
```

### S3 Bucket Name Conflicts

S3 bucket names must be globally unique:
```hcl
bucket_name = "compliance-cloudtrail-${data.aws_caller_identity.current.account_id}"
```

### VPC Flow Logs Permission Errors

Ensure the IAM role has permissions and the trust policy is correct.

## 📚 Resources

- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [Prowler Documentation](https://docs.prowler.com/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `terraform fmt` and `terraform validate`
5. Submit a pull request

## 📝 License

MIT License - See LICENSE file for details

## 🎓 Next Steps

1. **Review and customize** the Terraform variables
2. **Run initial deployment** in a dev/test environment
3. **Monitor compliance improvements** with before/after Prowler scans
4. **Iterate on remaining failures** from the compliance scan
5. **Set up automated monitoring** with the GitHub Actions workflow

---

**Questions?** Open an issue or reach out to the security team.
