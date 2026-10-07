"""Tests for the redacted Prowler summary."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

import pytest

_SCRIPT = Path(__file__).with_name("analyze-prowler.py")
_SPEC = importlib.util.spec_from_file_location("analyze_prowler", _SCRIPT)
if _SPEC is None or _SPEC.loader is None:
    raise RuntimeError("could not load analyze-prowler.py")
analyze_prowler = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(analyze_prowler)


def test_redact_strips_account_arn_and_iam_name() -> None:
    raw = (
        "arn:aws:iam::111122223333:user/sample-user in 111122223333 "
        "user/sample-user ops@example.com"
    )
    cleaned = analyze_prowler.redact(raw)
    assert "111122223333" not in cleaned
    assert "arn:aws" not in cleaned
    assert "sample-user" not in cleaned
    assert "ops@example.com" not in cleaned
    assert "[REDACTED_ARN]" in cleaned
    assert "[REDACTED_ACCOUNT]" in cleaned


def test_summary_omits_identifiers(capsys: pytest.CaptureFixture[str], tmp_path: Path) -> None:
    finding = {
        "Status": "FAIL",
        "Severity": "high",
        "ServiceName": "iam",
        "CheckTitle": "Console access",
        "StatusExtended": "User sample-user in account 111122223333",
        "ResourceArn": "arn:aws:iam::111122223333:user/sample-user",
        "AccountId": "111122223333",
    }
    report = tmp_path / "scan.json"
    report.write_text(json.dumps([finding]), encoding="utf-8")

    assert analyze_prowler.main([str(report)]) == 0
    output = capsys.readouterr().out
    assert "111122223333" not in output
    assert "arn:aws" not in output
    assert "sample-user" not in output
    assert "Failed: 1" in output
    assert "iam: fail=1" in output


def test_service_label_is_redacted() -> None:
    stats = analyze_prowler.summarize(
        [{"Status": "FAIL", "Severity": "critical", "ServiceName": "ec2-111122223333"}]
    )
    rendered = analyze_prowler.render_summary(stats)
    assert "111122223333" not in rendered
    assert "REDACTED_ACCOUNT" in rendered
    assert "critical: 1" in rendered


def test_compare_is_redacted(capsys: pytest.CaptureFixture[str], tmp_path: Path) -> None:
    before = tmp_path / "before.json"
    after = tmp_path / "after.json"
    before.write_text(
        json.dumps(
            [
                {
                    "Status": "FAIL",
                    "Severity": "high",
                    "ServiceName": "s3",
                    "ResourceArn": "arn:aws:s3:::logs-111122223333",
                }
            ]
        ),
        encoding="utf-8",
    )
    after.write_text(
        json.dumps([{"Status": "PASS", "Severity": "high", "ServiceName": "s3"}]),
        encoding="utf-8",
    )

    exit_code = analyze_prowler.main(["--compare", "--before", str(before), "--after", str(after)])
    output = capsys.readouterr().out
    assert exit_code == 0
    assert "111122223333" not in output
    assert "arn:aws" not in output
    assert "Passed delta: +1" in output
    assert "Failed delta: -1" in output


def test_empty_file_does_not_divide_by_zero() -> None:
    rendered = analyze_prowler.render_summary(analyze_prowler.summarize([]))
    assert "Total findings: 0" in rendered
    assert "0.0%" in rendered
