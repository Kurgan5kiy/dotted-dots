#!/usr/bin/env sh
set -eu

repository=${1:-Kurgan5kiy/dotted-dots}

command -v gh >/dev/null 2>&1 || {
  printf 'gh is required\n' >&2
  exit 1
}

gh auth status >/dev/null

gh api --method PATCH "repos/$repository" \
  -F has_issues=true \
  -F has_projects=true \
  -F has_wiki=false \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true >/dev/null

gh repo edit "$repository" \
  --add-topic linux \
  --add-topic wayland \
  --add-topic niri \
  --add-topic quickshell \
  --add-topic qml \
  --add-topic desktop-shell \
  --add-topic spec-driven-development

gh api --method PUT "repos/$repository/branches/main/protection" \
  -H 'Accept: application/vnd.github+json' \
  --input - >/dev/null <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["validate"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

printf 'Configured squash-only merging and main branch protection for %s\n' "$repository"
