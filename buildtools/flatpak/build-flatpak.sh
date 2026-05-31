#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────
# Build a Flatpak of Solian.
#
# Uses flatpak build-init / build / build-finish to assemble the
# Flatpak manually. Missing system libraries (libmpv, libayatana,
# libsecret) are copied from the host via /var/run/host/.
#
# Usage:
#   ./build-flatpak.sh              # uses existing Flutter bundle
#   ./build-flatpak.sh --build      # runs `flutter build linux` first
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

APP_ID="dev.solsynth.solian"
BINARY="island"
RUNTIME="org.freedesktop.Platform"
RUNTIME_VER="24.08"
SDK="org.freedesktop.Sdk"
BRANCH="master"

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"
FLUTTER_BUNDLE="$REPO_ROOT/build/linux/x64/release/bundle"
BUILDDIR="$HERE/builddir"
REPO="$HERE/repo"

# ── Sanity checks ───────────────────────────────────────────────
for cmd in flatpak; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found."
    exit 1
  fi
done

# ── Build Flutter first if requested ────────────────────────────
if [ "${1:-}" = "--build" ]; then
  echo "=== Building Flutter Linux bundle ==="
  (cd "$REPO_ROOT" && flutter build linux --release)
fi

if [ ! -d "$FLUTTER_BUNDLE" ]; then
  echo "Error: Flutter bundle not found at $FLUTTER_BUNDLE"
  echo "Run 'flutter build linux --release' first or pass --build"
  exit 1
fi

# ── Clean previous build ────────────────────────────────────────
rm -rf "$BUILDDIR" "$REPO"
mkdir -p "$REPO"

# ── Step 1: Initialize build directory ──────────────────────────
echo "=== Initializing build directory ==="
flatpak build-init \
  "$BUILDDIR" \
  "$APP_ID" \
  "$SDK//$RUNTIME_VER" \
  "$RUNTIME//$RUNTIME_VER" \
  "$BRANCH"

# ── Step 2: Install app files ───────────────────────────────────
echo "=== Installing app files ==="
flatpak build "$BUILDDIR" mkdir -p /app/bin
flatpak build "$BUILDDIR" cp -r "$FLUTTER_BUNDLE"/* /app/bin/
flatpak build "$BUILDDIR" install -Dm644 \
  "$HERE/$APP_ID.desktop" \
  /app/share/applications/"$APP_ID".desktop
flatpak build "$BUILDDIR" install -Dm644 \
  "$HERE/$APP_ID.metainfo.xml" \
  /app/share/metainfo/"$APP_ID".metainfo.xml
flatpak build "$BUILDDIR" install -Dm644 \
  "$HERE/$APP_ID.png" \
  /app/share/icons/hicolor/256x256/apps/"$APP_ID".png

# ── Step 3: Resolve and bundle missing system libraries ─────────
echo "=== Bundling missing system libraries ==="
flatpak build "$BUILDDIR" mkdir -p /app/lib

flatpak build "$BUILDDIR" bash << 'SCRIPT'
  set -e
  shopt -s nullglob
  HOST_LIBS=/var/run/host/usr/lib
  TARGET=/app/lib
  COPY_LOG=/tmp/copied.txt
  : > "$COPY_LOG"

  for iteration in 1 2 3 4 5; do
    echo "  Iteration $iteration" >&2
    for f in /app/bin/island /app/bin/lib/*.so "$TARGET"/*.so; do
      [ -f "$f" ] || continue
      ldd "$f" 2>/dev/null | while IFS= read -r line; do
        lib=$(echo "$line" | grep "not found" | awk '{print $1}')
        [ -z "$lib" ] && continue
        lib=$(basename "$lib")
        [[ "$lib" == *.so* ]] || continue
        [[ "$lib" != *:* ]] || continue
        grep -qxF "$lib" "$COPY_LOG" 2>/dev/null && continue
        host_path=$(find "$HOST_LIBS" -maxdepth 1 -name "$lib" -print -quit 2>/dev/null || true)
        if [ -n "$host_path" ]; then
          echo "  + $lib" >&2
          cp -L "$host_path" "$TARGET/$lib"
          echo "$lib" >> "$COPY_LOG"
        fi
      done
    done
  done
  echo "=== Copied libraries ===" >&2
  cat "$COPY_LOG" >&2
SCRIPT

# ── Step 4: Fix absolute DT_NEEDED paths in bundled libs ────────
echo "=== Fixing library paths ==="
if ! command -v patchelf &>/dev/null; then
  if [ -f /tmp/patchelf ]; then
    PATCHELF=/tmp/patchelf
  else
    echo "  Downloading patchelf..."
    curl -fsSL "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" \
      -o /tmp/patchelf.tar.gz
    (mkdir -p /tmp/patchelf_extract && \
     tar xzf /tmp/patchelf.tar.gz -C /tmp/patchelf_extract 2>/dev/null) || true
    PATCHELF=$(find /tmp/patchelf_extract /tmp -name patchelf -type f 2>/dev/null | head -1)
    if [ -z "$PATCHELF" ]; then
      echo "  WARNING: could not get patchelf. Skipping path fixes."
      PATCHELF=""
    fi
  fi
else
  PATCHELF=$(command -v patchelf)
fi

if [ -n "${PATCHELF:-}" ]; then
  cp "$PATCHELF" "$BUILDDIR/patchelf"
  flatpak build "$BUILDDIR" bash << 'SCRIPT'
    shopt -s nullglob
    PATCH="$(ls /patchelf 2>/dev/null || echo "")"
    [ -z "$PATCH" ] && exit 0
    for f in /app/lib/*.so; do
      [ -f "$f" ] || continue
      # Fix absolute DT_NEEDED paths (e.g. /usr/lib/libfoo.so -> libfoo.so)
      readelf -d "$f" 2>/dev/null | grep "NEEDED" | grep "/" | while IFS= read -r line; do
        old=$(echo "$line" | sed 's/.*\[\(.*\)\]/\1/')
        new=$(basename "$old")
        echo "  $f: $old -> $new" >&2
        "$PATCH" --replace-needed "$old" "$new" "$f" 2>/dev/null || true
      done
    done
SCRIPT
  rm -f "$BUILDDIR/patchelf"
fi

# ── Step 5: Finalize the build ──────────────────────────────────
echo "=== Finalizing ==="
flatpak build-finish \
  "$BUILDDIR" \
  --command=island \
  --socket=wayland \
  --socket=fallback-x11 \
  --device=dri \
  --share=network \
  --share=ipc \
  --env=LD_LIBRARY_PATH=/app/lib

# ── Step 6: Export to repository ────────────────────────────────
echo "=== Exporting to repository ==="
flatpak build-export \
  --no-update-summary \
  "$REPO" \
  "$BUILDDIR" \
  "$BRANCH"

# ── Step 7: Install locally ────────────────────────────────────
echo "=== Installing locally ==="
flatpak --user install -y --noninteractive "$REPO" "$APP_ID" "$BRANCH" 2>/dev/null && true

echo ""
echo "Done! Run: flatpak run $APP_ID"
