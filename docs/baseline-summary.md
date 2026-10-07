# Redacted compliance baseline

Raw Prowler output was removed from the repository. The figures below are finding counts from that scan. A finding is one check result for one resource or region, so these totals are higher than a unique-check rollup. No account IDs, ARNs, or resource names are included.

## Status

| Result | Findings | Share |
| --- | ---: | ---: |
| Passed | 127 | 34.6% |
| Failed | 237 | 64.6% |
| Manual | 3 | 0.8% |
| Total | 367 | 100% |

## Failed findings by severity

| Severity | Failed findings |
| --- | ---: |
| Critical | 3 |
| High | 21 |
| Medium | 159 |
| Low | 54 |

## Findings by service

| Service | Failed | Passed | Manual |
| --- | ---: | ---: | ---: |
| ec2 | 68 | 51 | 0 |
| cloudtrail | 53 | 51 | 0 |
| accessanalyzer | 17 | 0 | 0 |
| config | 17 | 0 | 0 |
| macie | 17 | 0 | 0 |
| securityhub | 17 | 0 | 0 |
| vpc | 16 | 1 | 0 |
| cloudwatch | 15 | 0 | 0 |
| s3 | 9 | 8 | 0 |
| iam | 8 | 16 | 0 |
| account | 0 | 0 | 3 |

An earlier README quoted 278 checks, 71 passes, and 204 failures. Those figures do not match this scan and are not used here.

Regenerate this shape of report from a local scan with `python3 scripts/analyze-prowler.py <prowler-json>`. Keep the raw file out of git.
