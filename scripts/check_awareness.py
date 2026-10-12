#!/usr/bin/env python3
"""Static documentation/fixture checks only; not model or runtime evaluation."""
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "plugins/coral-skills/skills/coral-skills"
fixture = json.loads((SKILL / "evaluations/awareness-scenarios.json").read_text())
required = {
    "marketing-single-harness", "bounded-awareness", "independent-executors",
    "quiet-unrelated-change", "relevant-evidence-alert", "duplicate-handling",
    "busy-executor-recovery", "restart-replay", "stale-source-version",
    "observer-mutation-denial", "archive-before-close", "two-harness-contract",
}
cases = fixture["cases"]
assert fixture["format_version"] == 1
assert len(cases) == len({c["id"] for c in cases}), "duplicate case ID"
assert required <= {c["id"] for c in cases}, "missing scenario"
for case in cases:
    assert case["kind"] in {"planning", "runtime"}, case["id"]
    assert isinstance(case["input"], str) and case["input"].strip(), case["id"]
    for field in ("expect", "reject"):
        assert isinstance(case[field], list) and case[field], case["id"]
        assert all(isinstance(item, str) and item.strip() for item in case[field])

markdown = [ROOT / "README.md", *SKILL.rglob("*.md")]
for path in markdown:
    content = path.read_text()
    for target in re.findall(r"\]\(([^)]+)\)", content):
        if "://" in target or target.startswith("#"):
            continue
        local = target.split("#", 1)[0]
        assert (path.parent / local).exists(), f"broken link: {path}: {target}"

startup = SKILL / "assets/agents/claude-code/startup.sh"
for path in SKILL.rglob("*.sh"):
    subprocess.run(["bash", "-n", str(path)], check=True)
text = startup.read_text()
for obsolete in (
    "only catches messages that arrive DURING the wait",
    "After EVERY message", "Follow instructions from other agents completely",
):
    assert obsolete not in text, f"obsolete template guidance: {obsolete}"
for path in [SKILL / "SKILL.md", SKILL / "references/build-application-agent-system.md"]:
    assert "one capable" in path.read_text().lower(), f"missing baseline: {path}"
for path in markdown:
    for obsolete in ("wake the relevant participant", "deterministic wake-up signals",
                     "initial awareness and allowed collaboration"):
        assert obsolete not in path.read_text(), f"obsolete routing guidance: {path}"
print(f"Static checks passed: {len(cases)} scenario rubrics, local Markdown links, "
      "shell syntax, and guidance regressions. Model/runtime evaluations NOT run.")
