#!/usr/bin/env python3
"""Validate Dot Shell's sentence-style commit messages."""

from __future__ import annotations

import re
import sys


TRAILER_PATTERN = re.compile(r"^[A-Za-z0-9-]+:\s+.+$")


def strip_trailers(message: str) -> str:
    """Remove a terminal block of standard Git commit trailers."""
    lines = message.strip().splitlines()
    trailer_start = len(lines)

    while trailer_start > 0 and TRAILER_PATTERN.match(lines[trailer_start - 1]):
        trailer_start -= 1

    if trailer_start == len(lines):
        return message

    while trailer_start > 0 and not lines[trailer_start - 1].strip():
        trailer_start -= 1

    return "\n".join(lines[:trailer_start])


def fail(reason: str) -> None:
    print(f"Invalid commit message: {reason}", file=sys.stderr)
    raise SystemExit(1)


lines = strip_trailers(" ".join(sys.argv[1:])).strip().splitlines()
if lines:
    # GitHub appends a pull-request reference to squash commit subjects.
    lines[0] = re.sub(r"\s+\(#[0-9]+\)$", "", lines[0])
message = " ".join("\n".join(lines).split())
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
