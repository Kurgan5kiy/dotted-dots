#!/usr/bin/env python3
"""Validate Dot Shell's sentence-style commit messages."""

from __future__ import annotations

import re
import sys


def fail(reason: str) -> None:
    print(f"Invalid commit message: {reason}", file=sys.stderr)
    raise SystemExit(1)


message = " ".join(" ".join(sys.argv[1:]).split())
if not message:
    fail("the message is empty")

if not message.endswith("."):
    fail("the final sentence must end with a period")

sentences = re.split(r"(?<=\.)\s+", message)
if not 1 <= len(sentences) <= 3:
    fail("use one to three sentences")

for sentence in sentences:
    if not re.match(r"^[A-Z]", sentence):
        fail(f"each sentence must start with a capital letter: {sentence!r}")
    if not sentence.endswith("."):
        fail(f"each sentence must end with a period: {sentence!r}")

print("Commit message is valid.")
