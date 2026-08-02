#!/bin/bash

set -e

# Target Android compileSdk for all patched plugin modules.
# Override on CI with:  MAX_COMPILE_SDK=36 ./patch-android-gradle-cfg.sh
: "${MAX_COMPILE_SDK:=37}"
MAX_COMPILE_SDK="$(printf '%d' "$MAX_COMPILE_SDK")"   # coerce/int, guards against junk input

PUB_CACHE="${PUB_CACHE:-${HOME}/.pub-cache/hosted/pub.dev}"
export LC_ALL=C

# Counters
patched_gradle=0
patched_gradle_kts=0

replace_in_file() {
  local expression="$1"
  local file="$2"
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -E "$expression" "$file"
  else
    sed -i -E "$expression" "$file"
  fi
}

echo "Patching Flutter plugin compileSdk versions to ${MAX_COMPILE_SDK} in ${PUB_CACHE}"

# Groovy DSL — only touch files that declare a *lower* compileSdk.
# The guard avoids gratuitous rewrites (and mtime churn) for already-correct files.
while IFS= read -r file; do
  if grep -E 'compileSdk(Version)?[[:space:]]*([=:][[:space:]]*)?[0-9]+' "$file" >/dev/null; then
    replace_in_file "s/compileSdkVersion[[:space:]]+[0-9]+/compileSdkVersion ${MAX_COMPILE_SDK}/g" "$file"
    replace_in_file "s/compileSdk[[:space:]]+[=:][[:space:]]*[0-9]+/compileSdk = ${MAX_COMPILE_SDK}/g" "$file"
    patched_gradle=$((patched_gradle + 1))
  fi
done < <(find "$PUB_CACHE" -type f -name "*.gradle" 2>/dev/null)

# Kotlin DSL
while IFS= read -r file; do
  if grep -E 'compileSdk(Version)?[[:space:]]*([=:][[:space:]]*)?[0-9]+' "$file" >/dev/null; then
    replace_in_file "s/compileSdk[[:space:]]*=[[:space:]]*[0-9]+/compileSdk = ${MAX_COMPILE_SDK}/g" "$file"
    replace_in_file "s/compileSdkVersion\([[:space:]]*[0-9]+[[:space:]]*\)/compileSdkVersion(${MAX_COMPILE_SDK})/g" "$file"
    patched_gradle_kts=$((patched_gradle_kts + 1))
  fi
done < <(find "$PUB_CACHE" -type f -name "*.gradle.kts" 2>/dev/null)

echo "Done: patched $patched_gradle *.gradle, $patched_gradle_kts *.gradle.kts to ${MAX_COMPILE_SDK}."