#!/usr/bin/env python3
"""Redacted summary of Prowler JSON results.

Counts findings by status, severity, and service. Account IDs, ARNs, emails,
and IAM path names are stripped before any text is printed.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

ARN_RE = re.compile(r"arn:aws[a-zA-Z-]*:[^\s\"']+")
ACCOUNT_RE = re.compile(r"\b\d{12}\b")
EMAIL_RE = re.compile(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}")
IAM_NAME_RE = re.compile(r"\b(?:user|role|group)/[A-Za-z0-9_+=,.@-]+", re.IGNORECASE)
SEVERITY_ORDER = ("critical", "high", "medium", "low")


def redact(text: str) -> str:
    """Remove account IDs, ARNs, emails, and IAM path names from text."""
    cleaned = ARN_RE.sub("[REDACTED_ARN]", text)
    cleaned = ACCOUNT_RE.sub("[REDACTED_ACCOUNT]", cleaned)
    cleaned = EMAIL_RE.sub("[REDACTED_EMAIL]", cleaned)
    return IAM_NAME_RE.sub("[REDACTED_IAM_NAME]", cleaned)


def load_findings(filepath: Path) -> list[dict[str, Any]]:
    """Load a Prowler JSON list, or an object with a findings array."""
    with filepath.open(encoding="utf-8") as handle:
        payload = json.load(handle)
    if isinstance(payload, list):
        findings = payload
    elif isinstance(payload, dict) and isinstance(payload.get("findings"), list):
        findings = payload["findings"]
    else:
        message = f"Unsupported Prowler JSON in {filepath.name}"
        raise ValueError(message)
    if not all(isinstance(item, dict) for item in findings):
        message = f"Unsupported Prowler JSON in {filepath.name}"
        raise ValueError(message)
    return findings


def _status(finding: dict[str, Any]) -> str:
    raw = finding.get("Status") or finding.get("status_code") or finding.get("status") or "UNKNOWN"
    return str(raw).upper()


def _severity(finding: dict[str, Any]) -> str:
    raw = finding.get("Severity") or finding.get("severity") or "unknown"
    return str(raw).lower()


def _service(finding: dict[str, Any]) -> str:
    raw = finding.get("ServiceName") or finding.get("service_name")
    if not raw:
        resources = finding.get("resources")
        if isinstance(resources, list) and resources and isinstance(resources[0], dict):
            raw = resources[0].get("type") or "unknown"
        else:
            raw = "unknown"
    return redact(str(raw))


def summarize(findings: list[dict[str, Any]]) -> dict[str, Any]:
    """Return counts only. Resource identifiers are not copied into the result."""
    by_service: dict[str, dict[str, int]] = defaultdict(lambda: {"pass": 0, "fail": 0, "info": 0})
    by_severity: dict[str, int] = defaultdict(int)
    counts = {"pass": 0, "fail": 0, "info": 0}
    for finding in findings:
        status = _status(finding)
        service = _service(finding)
        if status == "PASS":
            counts["pass"] += 1
            by_service[service]["pass"] += 1
        elif status == "FAIL":
            counts["fail"] += 1
            by_service[service]["fail"] += 1
            by_severity[_severity(finding)] += 1
        else:
            counts["info"] += 1
            by_service[service]["info"] += 1
    return {
        "total": len(findings),
        "pass": counts["pass"],
        "fail": counts["fail"],
        "info": counts["info"],
        "failures_by_severity": dict(by_severity),
        "by_service": {name: dict(values) for name, values in sorted(by_service.items())},
    }


def _percent(part: int, total: int) -> str:
    if total == 0:
        return "0.0%"
    return f"{part / total * 100:.1f}%"


def render_summary(stats: dict[str, Any]) -> str:
    """Render a redacted text summary."""
    lines = [
        "PROWLER REDACTED SUMMARY",
        f"Total findings: {stats['total']}",
        f"Passed: {stats['pass']} ({_percent(stats['pass'], stats['total'])})",
        f"Failed: {stats['fail']} ({_percent(stats['fail'], stats['total'])})",
        f"Manual: {stats['info']}",
        "",
        "Failures by severity:",
    ]
    severity_lines = [
        f"  {severity}: {stats['failures_by_severity'][severity]}"
        for severity in SEVERITY_ORDER
        if stats["failures_by_severity"].get(severity, 0)
    ]
    lines.extend(severity_lines or ["  none"])
    lines.extend(["", "Findings by service:"])
    service_lines = [
        (f"  {service}: fail={counts['fail']} pass={counts['pass']} manual={counts['info']}")
        for service, counts in stats["by_service"].items()
    ]
    lines.extend(service_lines or ["  none"])
    return "\n".join(lines)


def render_comparison(before: dict[str, Any], after: dict[str, Any]) -> str:
    """Render a redacted before/after comparison."""
    pass_delta = after["pass"] - before["pass"]
    sign = "+" if pass_delta > 0 else ""
    lines = [
        "PROWLER REDACTED COMPARISON",
        (
            f"Before: {before['pass']}/{before['total']} passed "
            f"({_percent(before['pass'], before['total'])})"
        ),
        (
            f"After: {after['pass']}/{after['total']} passed "
            f"({_percent(after['pass'], after['total'])})"
        ),
        f"Passed delta: {sign}{pass_delta}",
        f"Failed delta: {after['fail'] - before['fail']}",
        "",
        "Failure severity:",
    ]
    seen = set(before["failures_by_severity"]) | set(after["failures_by_severity"])
    ordered = [severity for severity in SEVERITY_ORDER if severity in seen]
    ordered.extend(sorted(seen - set(SEVERITY_ORDER)))
    for severity in ordered:
        before_count = before["failures_by_severity"].get(severity, 0)
        after_count = after["failures_by_severity"].get(severity, 0)
        if before_count or after_count:
            lines.append(f"  {severity}: {before_count} -> {after_count}")
    if len(lines) == 7:
        lines.append("  none")
    return "\n".join(lines)


def _latest_report(directory: Path) -> Path | None:
    matches = [
        path
        for path in directory.glob("prowler-output-*.json")
        if not path.name.endswith(".ocsf.json")
    ]
    if not matches:
        return None
    return max(matches, key=lambda path: path.stat().st_mtime)


def main(argv: list[str] | None = None) -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(description="Print a redacted Prowler summary.")
    parser.add_argument("file", nargs="?", help="Prowler JSON file")
    parser.add_argument("--compare", action="store_true", help="Compare two scan files")
    parser.add_argument("--before", help="Earlier scan")
    parser.add_argument("--after", help="Later scan")
    parser.add_argument("--json", action="store_true", help="Print the redacted summary as JSON")
    args = parser.parse_args(argv)

    try:
        if args.compare:
            if not args.before or not args.after:
                print("Error: --compare requires --before and --after", file=sys.stderr)
                return 1
            before = summarize(load_findings(Path(args.before)))
            after = summarize(load_findings(Path(args.after)))
            comparison = {"before": before, "after": after}
            payload: dict[str, Any] | str = (
                comparison if args.json else render_comparison(before, after)
            )
        else:
            target = Path(args.file) if args.file else _latest_report(Path("."))
            if target is None:
                print("Error: no Prowler JSON file found", file=sys.stderr)
                return 1
            stats = summarize(load_findings(target))
            payload = stats if args.json else render_summary(stats)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    if isinstance(payload, str):
        print(payload)
    else:
        print(json.dumps(payload, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
