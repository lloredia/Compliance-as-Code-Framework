# Prowler Quick Reference Guide

## Installation

```bash
pip install prowler
```

## Basic Scans

### Full CIS 1.5 Compliance Scan
```bash
prowler aws --compliance cis_1.5_aws
```

### Scan Specific Services
```bash
# CloudTrail only
prowler aws --services cloudtrail

# Multiple services
prowler aws --services cloudtrail iam s3 vpc
```

### Custom Output Formats
```bash
prowler aws \
  --compliance cis_1.5_aws \
  --output-formats json csv html \
  --output-directory ./reports
```

## Advanced Usage

### Scan Specific Checks
```bash
# Run only password policy checks
prowler aws --checks iam_password_policy*

# Run checks by severity
prowler aws --severity critical high
```

### Filter by Status
```bash
# Show only failures
prowler aws --status FAIL

# Show only passes
prowler aws --status PASS
```

### Scan Multiple Accounts
```bash
# Using AWS profiles
prowler aws --profile account1
prowler aws --profile account2

# Using role assumption
prowler aws --role arn:aws:iam::123456789012:role/ProwlerRole
```

## Interpreting Results

### Severity Levels
- **CRITICAL**: Immediate action required, severe security risk
- **HIGH**: Important vulnerabilities, should be fixed soon
- **MEDIUM**: Security improvements recommended
- **LOW**: Minor issues, best practices

### Common Findings

#### CloudTrail Not Enabled
```
CHECK ID: cloudtrail_multi_region_enabled
STATUS: FAIL
SEVERITY: high
REMEDIATION: Enable CloudTrail in all regions
```

#### Weak IAM Password Policy
```
CHECK ID: iam_password_policy_*
STATUS: FAIL
SEVERITY: medium
REMEDIATION: Strengthen password requirements
```

#### S3 Bucket Not Encrypted
```
CHECK ID: s3_bucket_default_encryption
STATUS: FAIL
SEVERITY: medium
REMEDIATION: Enable default encryption
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Run Prowler
  run: |
    prowler aws \
      --compliance cis_1.5_aws \
      --output-formats json \
      --output-directory ./reports
```

### Parse Results
```python
import json

with open('prowler-output.json') as f:
    findings = json.load(f)

critical = [f for f in findings if f['Severity'] == 'critical' and f['Status'] == 'FAIL']
print(f"Found {len(critical)} critical issues")
```

## Performance Tips

### Faster Scans
```bash
# Skip slow checks
prowler aws --excluded-checks guardduty_* detective_*

# Scan specific regions only
prowler aws --regions us-east-1 us-west-2
```

### Parallel Execution
```bash
# Use multiple threads (default: 4)
prowler aws --parallel 8
```

## Common Issues

### Issue: Rate limiting
**Solution**: Add delays between API calls
```bash
prowler aws --sleep-time 0.5
```

### Issue: Permission denied
**Solution**: Ensure IAM permissions include:
- ReadOnlyAccess policy
- SecurityAudit policy

### Issue: Timeout on large accounts
**Solution**: Run service-specific scans
```bash
prowler aws --services cloudtrail
prowler aws --services s3
# etc.
```

## Compliance Frameworks

### Available Frameworks
```bash
# List all available compliance frameworks
prowler aws --list-compliance

# Common frameworks
prowler aws --compliance cis_1.5_aws
prowler aws --compliance cis_2.0_aws
prowler aws --compliance pci_3.2.1_aws
prowler aws --compliance hipaa_aws
prowler aws --compliance gdpr_aws
```

## Report Analysis

### View Summary
```bash
# JSON summary
jq '.[] | select(.Status=="FAIL") | {CheckTitle, Severity}' prowler-output.json

# Count by severity
jq '.[] | select(.Status=="FAIL") | .Severity' prowler-output.json | sort | uniq -c
```

### Extract Specific Findings
```bash
# All CloudTrail failures
jq '.[] | select(.ServiceName=="cloudtrail" and .Status=="FAIL")' prowler-output.json

# Critical severity issues
jq '.[] | select(.Severity=="critical" and .Status=="FAIL")' prowler-output.json
```

## Remediation Workflow

1. **Run initial scan**
   ```bash
   prowler aws --compliance cis_1.5_aws
   ```

2. **Prioritize by severity**
   - Fix critical first
   - Then high
   - Then medium/low

3. **Apply fixes** (Terraform, manual, or automated)

4. **Re-scan to verify**
   ```bash
   prowler aws --compliance cis_1.5_aws
   ```

5. **Track progress**
   - Compare before/after pass rates
   - Document exceptions

## Best Practices

1. **Run regularly** - Weekly or after major changes
2. **Track trends** - Monitor compliance scores over time
3. **Document exceptions** - Some failures may be acceptable
4. **Automate remediation** - Use Terraform/CloudFormation
5. **Integrate with CI/CD** - Catch issues before production

## Additional Resources

- [Prowler GitHub](https://github.com/prowler-cloud/prowler)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
