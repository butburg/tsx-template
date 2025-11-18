#!/usr/bin/env bash
set -euo pipefail

# Replace the placeholder component with a user-supplied TSX file.
# This script copies the component into src/, rewrites main.tsx to render it,
# updates the HTML title, and adds any new bare imports to package.json.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"
PLACEHOLDER="${SRC_DIR}/ReplaceMeExample.tsx"
MAIN_FILE="${SRC_DIR}/main.tsx"
INDEX_HTML="${ROOT_DIR}/index.html"
PACKAGE_JSON="${ROOT_DIR}/package.json"

prompt_path() {
  local input_path="${1:-}"
  if [[ -z "${input_path}" ]]; then
    read -rp "Path to your TSX component: " input_path
  fi
  if [[ -z "${input_path}" ]]; then
    echo "No path provided. Exiting." >&2
    exit 1
  fi
  echo "${input_path}"
}

to_component_name() {
  local raw_name="$1"
  python3 - "$raw_name" <<'PY'
import re, sys
raw = sys.argv[1]
parts = [p for p in re.split(r"[^0-9a-zA-Z]+", raw) if p]
if not parts:
    print("App")
    sys.exit()
name = "".join(p[:1].upper() + p[1:] for p in parts)
if not re.match(r"[A-Za-z]", name[0]):
    name = "App" + name
print(name)
PY
}

rewrite_main() {
  local component_name="$1"
  cat > "${MAIN_FILE}" <<EOF
import React from 'react';
import { createRoot } from 'react-dom/client';
import ${component_name} from './${component_name}';
import './styles.css';

const root = document.getElementById('root');

if (!root) {
  throw new Error('Root element with id "root" was not found in index.html');
}

createRoot(root).render(
  <React.StrictMode>
    <${component_name} />
  </React.StrictMode>
);
EOF
}

update_title() {
  local app_name="$1"
  if [[ ! -f "${INDEX_HTML}" ]]; then
    return
  fi
  python3 - "$app_name" "${INDEX_HTML}" <<'PY'
import re, sys
name, path = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
updated = re.sub(r"<title>.*?</title>", f"<title>{name}</title>", text, flags=re.I|re.S)
open(path, "w", encoding="utf-8").write(updated)
PY
}

ensure_dependencies() {
  local component_path="$1"
  if [[ ! -f "${PACKAGE_JSON}" ]]; then
    echo "package.json not found; cannot add dependencies." >&2
    return
  fi

  python3 - "${component_path}" "${PACKAGE_JSON}" <<'PY'
import json, re, sys, pathlib
component_path, pkg_path = map(pathlib.Path, sys.argv[1:3])
src = component_path.read_text(encoding="utf-8")
imports = set(re.findall(r"import(?:[\s\w\{\}\*,]+from\s*)?['\"]([^'\"]+)['\"]", src))
deps = {i for i in imports if not i.startswith(('.', '/'))}
deps.update(["react", "react-dom"])

pkg = json.loads(pkg_path.read_text(encoding="utf-8"))
pkg.setdefault("dependencies", {})
devdeps = pkg.get("devDependencies", {})

changed = False
for dep in sorted(deps):
    if dep not in pkg["dependencies"] and dep not in devdeps:
        pkg["dependencies"][dep] = "latest"
        changed = True

if changed:
    pkg_path.write_text(json.dumps(pkg, indent=2) + "\n", encoding="utf-8")
PY
}

copy_component() {
  local source="$1"
  local component_name="$2"
  mkdir -p "${SRC_DIR}"
  local dest="${SRC_DIR}/${component_name}.tsx"

  if [[ "$(cd "$(dirname "${source}")" && pwd)/$(basename "${source}")" == "${dest}" ]]; then
    echo "${dest}"
    return
  fi

  cp "${source}" "${dest}"
  if [[ "${source}" != "${dest}" ]]; then
    rm -f "${source}"
  fi
  echo "${dest}"
}

main() {
  local input_path
  input_path="$(prompt_path "${1-}")"

  local absolute_source
  absolute_source="$(cd "$(dirname "${input_path}")" && pwd)/$(basename "${input_path}")"

  if [[ ! -f "${absolute_source}" ]]; then
    echo "File not found: ${absolute_source}" >&2
    exit 1
  fi

  if [[ "${absolute_source##*.}" != "tsx" ]]; then
    echo "Please provide a .tsx file." >&2
    exit 1
  fi

  local base_name
  base_name="$(basename "${absolute_source}" .tsx)"
  local component_name
  component_name="$(to_component_name "${base_name}")"

  local component_path
  component_path="$(copy_component "${absolute_source}" "${component_name}")"

  if [[ -f "${PLACEHOLDER}" ]]; then
    rm -f "${PLACEHOLDER}"
  fi

  rewrite_main "${component_name}"
  update_title "${component_name}"
  ensure_dependencies "${component_path}"

  echo "✅ Moved ${absolute_source} to ${component_path}"
  echo "✅ Updated src/main.tsx to render ${component_name}"
  echo "✅ index.html title set to \"${component_name}\""
  echo "Done. Run npm install to pull any newly added dependencies."
}

main "$@"
