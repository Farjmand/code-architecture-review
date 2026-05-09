#!/usr/bin/env bash
# scan_structure.sh — Snapshot a project's structure for architecture review
# Usage: bash scan_structure.sh [project-root] [max-depth]

ROOT="${1:-.}"
DEPTH="${2:-4}"

echo "===== PROJECT STRUCTURE (depth $DEPTH) ====="
if command -v tree &>/dev/null; then
  tree "$ROOT" -L "$DEPTH" \
    --dirsfirst \
    -I "node_modules|.git|__pycache__|.venv|venv|env|dist|build|.next|.nuxt|coverage|.cache|*.egg-info|target|vendor" \
    -a
else
  # Fallback: find + awk for clean indented output
  find "$ROOT" \
    -not \( \
      -path "*/node_modules/*" -o \
      -path "*/.git/*" -o \
      -path "*/__pycache__/*" -o \
      -path "*/.venv/*" -o \
      -path "*/venv/*" -o \
      -path "*/dist/*" -o \
      -path "*/build/*" -o \
      -path "*/.next/*" -o \
      -path "*/coverage/*" -o \
      -path "*/target/*" -o \
      -path "*/vendor/*" \
    \) \
    -maxdepth "$DEPTH" \
    | sort \
    | awk -F'/' '{
        depth = NF - 1;
        indent = "";
        for (i = 0; i < depth; i++) indent = indent "  ";
        print indent $NF
      }'
fi

echo ""
echo "===== DEPENDENCY / CONFIG FILES ====="
for f in package.json pyproject.toml setup.py Cargo.toml go.mod pom.xml build.gradle *.csproj Gemfile requirements.txt; do
  found=$(find "$ROOT" -maxdepth 3 -name "$f" 2>/dev/null | head -5)
  if [ -n "$found" ]; then
    echo "Found: $found"
  fi
done

echo ""
echo "===== FILE COUNT BY TYPE ====="
find "$ROOT" \
  -not \( -path "*/node_modules/*" -o -path "*/.git/*" -o -path "*/__pycache__/*" -o -path "*/dist/*" -o -path "*/build/*" \) \
  -type f \
  | sed 's/.*\.//' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -20

echo ""
echo "===== LARGEST FILES (potential God files) ====="
find "$ROOT" \
  -not \( -path "*/node_modules/*" -o -path "*/.git/*" -o -path "*/__pycache__/*" -o -path "*/dist/*" -o -path "*/build/*" \) \
  -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.cs" \) \
  | xargs wc -l 2>/dev/null \
  | sort -rn \
  | head -15

echo ""
echo "===== POTENTIAL CIRCULAR IMPORTS (JS/TS) ====="
if command -v madge &>/dev/null; then
  madge --circular "$ROOT/src" 2>/dev/null || echo "(madge not available — install with: npm install -g madge)"
else
  echo "(madge not installed — run: npm install -g madge)"
fi

echo ""
echo "===== TEST COVERAGE SIGNAL ====="
src_count=$(find "$ROOT" \
  -not \( -path "*/node_modules/*" -o -path "*/.git/*" -o -path "*/dist/*" -o -path "*/build/*" \) \
  -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) \
  -not \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" \) \
  | wc -l)

test_count=$(find "$ROOT" \
  -not \( -path "*/node_modules/*" -o -path "*/.git/*" -o -path "*/dist/*" -o -path "*/build/*" \) \
  -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" \) \
  | wc -l)

echo "Source files: $src_count"
echo "Test files:   $test_count"
if [ "$src_count" -gt 0 ]; then
  ratio=$(echo "scale=1; $test_count * 100 / $src_count" | bc 2>/dev/null || echo "n/a")
  echo "Test/source ratio: ${ratio}%"
fi
