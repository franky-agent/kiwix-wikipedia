#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# install_kiwix.sh — Install the Kiwix reader (Flatpak) + download a Wikipedia
# .zim archive + open it in Kiwix. Everything runs locally, nothing uploaded.
#
# Usage:
#   ./install_kiwix.sh                                          # 284 MB top-mini (quick start)
#   ZIM_FILE=wikipedia_en_all_maxi_2026-08.zim ./install_kiwix.sh   # full English + images (119 GB)
#   ZIM_FILE=wikipedia_en_all_nopic_2026-06.zim ./install_kiwix.sh  # full English, no images (50 GB)
#   ZIM_FILE=wikipedia_en_physics_mini_2026-10.zim ./install_kiwix.sh  # physics subset (~16 MB)
#
# Environment overrides:
#   ZIM_FILE    — which .zim to download (see README.md for the full list)
#   ZIM_DIR     — where to store archives (default: ./zim_files)
#   ZIM_BASE_URL — base URL for downloads (default: download.kiwix.org/zim/wikipedia)
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"

# ---- config ---------------------------------------------------------------
ZIM_BASE_URL="${ZIM_BASE_URL:-https://download.kiwix.org/zim/wikipedia}"
# Default: the 284 MB "top mini" — tiny, fast, perfect for a first run.
ZIM_FILE="${ZIM_FILE:-wikipedia_en_top_mini_2026-09.zim}"
ZIM_DIR="${ZIM_DIR:-zim_files}"
ZIM_PATH="${ZIM_DIR}/${ZIM_FILE}"

# ---- helpers --------------------------------------------------------------
c_green() { printf '\033[0;32m%s\033[0m' "$1"; }
c_yellow() { printf '\033[1;33m%s\033[0m' "$1"; }
c_red() { printf '\033[0;31m%s\033[0m' "$1"; }

bytes_to_human() {
  local b=$1
  if   (( b >= 1073741824 )); then printf '%.1f GB' "$(echo "scale=1; $b/1073741824" | bc)"
  elif (( b >= 1048576 ));    then printf '%.1f MB' "$(echo "scale=1; $b/1048576" | bc)"
  elif (( b >= 1024 ));       then printf '%.1f KB' "$(echo "scale=1; $b/1024" | bc)"
  else printf '%d B' "$b"
  fi
}

check_free_disk() {
  local needed=$1
  local avail
  avail=$(df -B1 "${ZIM_DIR}" 2>/dev/null | awk 'NR==2 {print $4}')
  if [[ -z "$avail" ]]; then
    # ZIM_DIR doesn't exist yet; measure the parent
    avail=$(df -B1 "$(dirname "${ZIM_DIR}")" 2>/dev/null | awk 'NR==2 {print $4}')
  fi
  if (( avail < needed )); then
    echo ""
    echo "$(c_red "ERROR: not enough free disk space.")"
    echo "  Needed:   $(bytes_to_human "$needed")"
    echo "  Available: $(bytes_to_human "$avail")"
    echo "  Pick a smaller ZIM_FILE (see README.md) or free up disk."
    return 1
  fi
  echo "  Free disk: $(bytes_to_human "$avail") — OK"
}

# ---- 1. Install Kiwix reader (Flatpak) ------------------------------------
echo "=== [1/3] Installing Kiwix reader ==="

if flatpak list 2>/dev/null | grep -q 'org.kiwix.desktop'; then
  echo "  $(c_green 'Kiwix already installed') — skipping."
else
  if ! command -v flatpak >/dev/null 2>&1; then
    echo "  $(c_yellow 'flatpak not found.') Attempting to install it..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -qq && sudo apt-get install -y flatpak
      # Add Flathub repo
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y flatpak
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm flatpak
    else
      echo "$(c_red 'ERROR: could not install flatpak automatically.')"
      echo "       Install flatpak manually, then re-run this script."
      echo "       Alternatively, download Kiwix from https://www.kiwix.org/download/"
      exit 1
    fi
  fi
  echo "  Installing Kiwix from Flathub (this downloads ~100 MB)..."
  flatpak install -y flathub org.kiwix.desktop
  echo "  $(c_green 'Kiwix installed.')"
fi

# ---- 2. Download the .zim archive -----------------------------------------
echo ""
echo "=== [2/3] Downloading Wikipedia archive ==="
echo "  File:   $ZIM_FILE"
echo "  URL:    ${ZIM_BASE_URL}/${ZIM_FILE}"

mkdir -p "$ZIM_DIR"

if [[ -f "$ZIM_PATH" ]]; then
  echo "  $(c_green "Already exists") at $ZIM_PATH — skipping download."
  echo "  (delete it to force a fresh download)"
else
  # Check the remote file size (HEAD request, follow redirects)
  REMOTE_SIZE=$(curl -sIL "${ZIM_BASE_URL}/${ZIM_FILE}" \
    | grep -i '^content-length' | tail -1 | tr -d '\r' | awk '{print $2}')
  if [[ -z "$REMOTE_SIZE" || "$REMOTE_SIZE" == "0" ]]; then
    echo "$(c_red "ERROR: could not determine file size.") The file may not exist."
    echo "  Check the filename at: ${ZIM_BASE_URL}/"
    echo "  See README.md for the list of valid ZIM_FILE values."
    exit 1
  fi
  echo "  Size:   $(bytes_to_human "$REMOTE_SIZE")"
  check_free_disk "$REMOTE_SIZE" || exit 1

  echo ""
  echo "  Downloading (resumable with wget -c)..."
  echo "  You can Ctrl-C and re-run to continue later."
  echo ""
  wget -c --show-progress -O "$ZIM_PATH" "${ZIM_BASE_URL}/${ZIM_FILE}"
  echo ""
  echo "  $(c_green 'Download complete.')"
fi

# ---- 3. Open in Kiwix -----------------------------------------------------
echo ""
echo "=== [3/3] Opening in Kiwix ==="
echo "  Launching: flatpak run org.kiwix.desktop \"$ZIM_PATH\""
echo ""
flatpak run org.kiwix.desktop "$ZIM_PATH" &
echo ""
echo "$(c_green 'Done!') Kiwix is opening your Wikipedia archive."
echo "Use the search bar to find any article — it all works offline."
echo ""
echo "Tip: to download a bigger/different edition later, run:"
echo "  ZIM_FILE=wikipedia_en_all_maxi_2026-08.zim ./install_kiwix.sh"
