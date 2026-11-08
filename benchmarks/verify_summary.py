#!/usr/bin/env python3
"""Verify the arithmetic in durmem's public benchmark summary receipt."""

import json
from pathlib import Path


def main() -> None:
    receipt = json.loads(Path(__file__).with_name("summary.json").read_text())
    assert receipt["schema_version"] == 1
    assert len(receipt["results"]) == 3
    for result in receipt["results"]:
        computed = round(100 * result["correct"] / result["scored"], 1)
        assert computed == result["reported_percent"], (
            f"{result['benchmark']}: computed {computed}, "
            f"reported {result['reported_percent']}"
        )
        assert "cohort" in result and "scope" in result
        print(
            f"{result['benchmark']}: {result['correct']}/{result['scored']} "
            f"= {computed:.1f}% ({result['cohort']})"
        )


if __name__ == "__main__":
    main()
