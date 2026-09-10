#!/usr/bin/env bash
# harness.sh — Portable Second Brain v2 scaffolder (Mac / Linux / Git Bash)
# ========================================================================
# Copy tất định template vào memory hub + tạo/merge CLAUDE.md trong codebase.
# Không cần AI. Không hardcode path — resolve qua $SECOND_BRAIN_ROOT.
#
# USAGE
#   harness init                     # L0, tên = tên folder hiện tại
#   harness init --level L1
#   harness init --name my-app --path /code/my-app
#   harness help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_ROOT="$PACKAGE_ROOT/templates"

show_help() {
  cat <<'EOF'
harness — portable Second Brain v2 scaffolder

Lệnh:
  harness init [options]   Khởi tạo harness cho dự án
  harness help             In trợ giúp

Options cho init:
  --name <name>    Tên project (mặc định: tên folder hiện tại)
  --path <path>    Path codebase (mặc định: thư mục hiện tại)
  --level <L0..L4> Cấp trưởng thành (mặc định: L0)

Yêu cầu: env var SECOND_BRAIN_ROOT (hoặc file ~/.harnessrc).
Chi tiết: README.md, docs/INSTALL.md
EOF
}

resolve_root() {
  if [[ -n "${SECOND_BRAIN_ROOT:-}" ]]; then
    echo "${SECOND_BRAIN_ROOT}"; return 0
  fi
  if [[ -f "$HOME/.harnessrc" ]]; then
    local line
    line="$(grep -m1 -v '^[[:space:]]*$' "$HOME/.harnessrc" || true)"
    if [[ -n "$line" ]]; then echo "${line}"; return 0; fi
  fi
  echo "❌ SECOND_BRAIN_ROOT chưa được set." >&2
  echo "   Set:  export SECOND_BRAIN_ROOT=\"\$HOME/SecondBrain\"  (thêm vào ~/.profile)" >&2
  echo "   Hoặc tạo ~/.harnessrc với 1 dòng là đường dẫn hub." >&2
  exit 1
}

# expand_tokens < input-file  → stdout, thay {{TOKEN}} bằng biến đã set
expand_tokens() {
  local content; content="$(cat "$1")"
  content="${content//\{\{PROJECT_NAME\}\}/$NAME}"
  content="${content//\{\{PROJECT_PATH\}\}/$PATH_ARG}"
  content="${content//\{\{DATE\}\}/$TODAY}"
  content="${content//\{\{SECOND_BRAIN_ROOT\}\}/$ROOT}"
  content="${content//\{\{STACK\}\}/$STACK}"
  printf '%s\n' "$content"
}

CREATED=()
SKIPPED=()

# copy_tpl <src> <dst>  — không overwrite, thay token
copy_tpl() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then SKIPPED+=("$dst"); return 0; fi
  mkdir -p "$(dirname "$dst")"
  expand_tokens "$src" > "$dst"
  CREATED+=("$dst")
}

# ---- parse args ----
[[ $# -eq 0 ]] && { show_help; exit 0; }
CMD="$1"; shift || true
case "$CMD" in
  help|-h|--help) show_help; exit 0 ;;
  init) : ;;
  *) echo "❌ Lệnh không hợp lệ: $CMD" >&2; show_help; exit 1 ;;
esac

NAME=""; PATH_ARG=""; LEVEL="L0"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)  NAME="$2"; shift 2 ;;
    --path)  PATH_ARG="$2"; shift 2 ;;
    --level) LEVEL="$2"; shift 2 ;;
    *) echo "⚠ Bỏ qua tham số lạ: $1" >&2; shift ;;
  esac
done

[[ -z "$PATH_ARG" ]] && PATH_ARG="$(pwd)"
[[ -z "$NAME" ]] && NAME="$(basename "$PATH_ARG")"
if [[ ! "$LEVEL" =~ ^L[0-4]$ ]]; then
  echo "❌ --level phải là L0..L4 (nhận: $LEVEL)" >&2; exit 1
fi
LVL_NUM="${LEVEL#L}"

ROOT="$(resolve_root)"
BASE="$ROOT/_projects/$NAME"
TODAY="$(date +%Y-%m-%d)"
STACK="[TBD — điền sau]"

# ---- tạo thư mục hub ----
mkdir -p "$BASE/MEMORY/sessions" "$BASE/HARNESS/stories" "$BASE/HARNESS/decisions" "$BASE/HARNESS/templates"

# ---- L0 ----
copy_tpl "$TEMPLATES_ROOT/AGENTS.md"                                  "$BASE/AGENTS.md"
copy_tpl "$TEMPLATES_ROOT/memory/CONTEXT.md"                          "$BASE/MEMORY/CONTEXT.md"
copy_tpl "$TEMPLATES_ROOT/memory/DECISIONS.md"                        "$BASE/MEMORY/DECISIONS.md"
copy_tpl "$TEMPLATES_ROOT/memory/MISTAKES.md"                         "$BASE/MEMORY/MISTAKES.md"
copy_tpl "$TEMPLATES_ROOT/harness/FEATURE_INTAKE.md"                  "$BASE/HARNESS/FEATURE_INTAKE.md"
copy_tpl "$TEMPLATES_ROOT/harness/TEST_MATRIX.md"                     "$BASE/HARNESS/TEST_MATRIX.md"
copy_tpl "$TEMPLATES_ROOT/harness/templates/story-template.md"        "$BASE/HARNESS/templates/story-template.md"
copy_tpl "$TEMPLATES_ROOT/harness/templates/adr-template.md"          "$BASE/HARNESS/templates/adr-template.md"
copy_tpl "$TEMPLATES_ROOT/harness/templates/feature-intake-template.md" "$BASE/HARNESS/templates/feature-intake-template.md"

# ---- L1+ ----
if (( LVL_NUM >= 1 )); then
  copy_tpl "$TEMPLATES_ROOT/harness/TOOL_REGISTRY.md"                "$BASE/HARNESS/TOOL_REGISTRY.md"
fi
# ---- L2+ ----
if (( LVL_NUM >= 2 )); then
  copy_tpl "$TEMPLATES_ROOT/harness/stories/story.contract.md"       "$BASE/HARNESS/stories/EXAMPLE.contract.md"
fi
# ---- L3+ ----
if (( LVL_NUM >= 3 )); then
  copy_tpl "$TEMPLATES_ROOT/harness/BOARD.md"                        "$BASE/HARNESS/BOARD.md"
fi
# ---- L4 ----
if (( LVL_NUM >= 4 )); then
  copy_tpl "$TEMPLATES_ROOT/harness/MATURITY.md"                     "$BASE/HARNESS/MATURITY.md"
  copy_tpl "$TEMPLATES_ROOT/harness/AUDIT.md"                        "$BASE/HARNESS/AUDIT.md"
  copy_tpl "$TEMPLATES_ROOT/harness/IMPROVEMENT.md"                  "$BASE/HARNESS/IMPROVEMENT.md"
fi

# ---- CLAUDE.md trong codebase (merge-aware, idempotent) ----
CLAUDE_TGT="$PATH_ARG/CLAUDE.md"
BLOCK_TMP="$(mktemp)"; trap 'rm -f "$BLOCK_TMP"' EXIT
expand_tokens "$TEMPLATES_ROOT/CLAUDE.md" > "$BLOCK_TMP"

if [[ ! -e "$CLAUDE_TGT" ]]; then
  { printf '# %s\n\n' "$NAME"; cat "$BLOCK_TMP"; } > "$CLAUDE_TGT"
  CREATED+=("$CLAUDE_TGT")
elif grep -q 'SECOND-BRAIN-V2:START' "$CLAUDE_TGT"; then
  awk -v bf="$BLOCK_TMP" '
    /<!-- SECOND-BRAIN-V2:START/ { inblk=1; while ((getline l < bf) > 0) print l; next }
    /SECOND-BRAIN-V2:END -->/    { inblk=0; next }
    !inblk { print }
  ' "$CLAUDE_TGT" > "$CLAUDE_TGT.tmp" && mv "$CLAUDE_TGT.tmp" "$CLAUDE_TGT"
  SKIPPED+=("$CLAUDE_TGT (block cập nhật)")
else
  { printf '\n\n'; cat "$BLOCK_TMP"; } >> "$CLAUDE_TGT"
  SKIPPED+=("$CLAUDE_TGT (đã chèn block, giữ nội dung cũ)")
fi

# ---- báo cáo ----
echo ""
echo "✅ Harness đã init cho [$NAME] — cấp $LEVEL"
echo "   Memory hub: $BASE"
echo "   Codebase  : $PATH_ARG"
echo ""
if (( ${#CREATED[@]} > 0 )); then
  echo "Đã tạo:"; for f in "${CREATED[@]}"; do echo "  + $f"; done
fi
if (( ${#SKIPPED[@]} > 0 )); then
  echo "Bỏ qua / cập nhật (đã tồn tại):"; for f in "${SKIPPED[@]}"; do echo "  · $f"; done
fi
echo ""
echo "👉 Bước tiếp (tuỳ chọn): mở AI agent trong dự án, nhờ điền placeholder [...] trong MEMORY/CONTEXT.md từ codebase thực."
echo ""
