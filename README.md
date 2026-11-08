# Offline Wikipedia with Kiwix — Complete Setup Guide

**Goal:** Have the full Wikipedia available locally on your machine, searchable
and readable with zero internet connection, using [Kiwix](https://www.kiwix.org).

No LLM, no vector database, no GPU — just a reader app + a pre-packaged
archive file (`.zim`). This is the simplest, most reliable way to carry
Wikipedia offline.

---

## How it works

```
1. Install the Kiwix reader app          (~100 MB)
2. Download a Wikipedia .zim archive      (you pick the size — see table below)
3. Open the .zim file in Kiwix            → full-text search, browse, read offline
```

A `.zim` file is a single compressed archive containing the entire Wikipedia
text + images, with a built-in full-text search index. Kiwix is the reader.

---

## Step 1 — Install the Kiwix reader

### Linux (this machine)

**Option A — Flatpak (recommended, latest version 2.5.1):**
```bash
flatpak install flathub org.kiwix.desktop
```

**Option B — Direct Flatpak download:**
```bash
wget https://download.kiwix.org/release/kiwix-desktop/org.kiwix.desktop.2.5.1.flatpak
flatpak install org.kiwix.desktop.2.5.1.flatpak
```

**Option C — Build from source (tarball):**
```bash
wget https://download.kiwix.org/release/kiwix-desktop/kiwix-desktop-2.5.1.tar.gz
# Requires: Qt5, libzim, kiwix-lib — see the GitHub repo for build deps
# https://github.com/kiwix/kiwix-desktop
```

> 💡 Flatpak is the path of least resistance. The included `install_kiwix.sh`
> script handles it automatically (Step 3 below).

### Other platforms
| Platform | How to install |
|---|---|
| **Windows** | Download the `.exe` installer from <https://www.kiwix.org/download/> |
| **macOS** | Download the `.dmg` from <https://www.kiwix.org/download/> or `brew install --cask kiwix` |
| **Android** | Google Play: "Kiwix" |
| **iOS** | App Store: "Kiwix" |

---

## Step 2 — Choose and download a Wikipedia `.zim` archive

### English Wikipedia — available variants

| File | Size | What's in it | Best for |
|---|---|---|---|
| `wikipedia_en_all_maxi_2026-08.zim` | **119 GB** | All articles + all images | Complete offline English Wikipedia |
| `wikipedia_en_all_nopic_2026-06.zim` | **50 GB** | All articles, **no images** | Full text, save disk space |
| `wikipedia_en_all_mini_2026-09.zim` | **14 GB** | All articles, reduced images | Good balance of size / completeness |
| `wikipedia_en_top_maxi_2026-09.zim` | **6.6 GB** | Top ~100k articles + images | Most-read topics only |
| `wikipedia_en_top_nopic_2026-09.zim` | **2.6 GB** | Top ~100k articles, no images | Lightweight essentials |
| `wikipedia_en_top_mini_2026-09.zim` | **284 MB** | Top articles, minimal | **Testing / USB stick / quick start** |

### Variant naming explained
- **all** — every article in the language edition
- **top** — only the most-viewed ~100,000 articles (covers ~99% of lookups)
- **maxi** — includes all images at full resolution
- **nopic** — no images at all (text only)
- **mini** — article text + tiny/compressed images

### Other languages

Replace `en` with the [ISO 639-1 code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes):
```
https://download.kiwix.org/zim/wikipedia/wikipedia_DE_all_maxi_LATEST.zim
                                    ^^^^^^^^^^^ ^^^^^^^^ ^^^^
                                    wikipedia   language scope
```
Browse all available files at: <https://download.kiwix.org/zim/wikipedia/>

### Topic-specific ZIMs

Kiwix also offers curated subsets — e.g. only Physics, Medicine, History,
Math, Computer Science articles. Available in maxi/nopic/mini variants:
```
wikipedia_en_physics_maxi_2026-10.zim
wikipedia_en_medicine_maxi_2026-10.zim
wikipedia_en_computer_maxi_2026-09.zim
wikipedia_en_history_maxi_2026-10.zim
wikipedia_en_chemistry_maxi_2026-10.zim
wikipedia_en_mathematics_maxi_2026-10.zim
wikipedia_en_biology_maxi_2026-10.zim
wikipedia_en_geography_maxi_2026-10.zim
wikipedia_en_sociology_maxi_2026-10.zim
```
These are typically 100 MB – 2 GB each — great if you only need one domain.

---

## Step 3 — Let the script do it for you

The included `install_kiwix.sh` script:

1. Installs the Kiwix Flatpak app (if not already present)
2. Downloads the `.zim` file you choose (defaults to the **284 MB top-mini**
   for a quick first run)
3. Opens it in Kiwix

```bash
cd kiwix-wikipedia

# Quick start — downloads the 284 MB top-mini archive and opens it:
./install_kiwix.sh

# Download the full English Wikipedia with images (119 GB):
ZIM_FILE=wikipedia_en_all_maxi_2026-08.zim ./install_kiwix.sh

# Download the no-pictures full English (50 GB):
ZIM_FILE=wikipedia_en_all_nopic_2026-06.zim ./install_kiwix.sh

# Download a topic subset (e.g. Physics, ~250 MB):
ZIM_FILE=wikipedia_en_physics_mini_2026-10.zim ./install_kiwix.sh
```

> **Disk space check:** The script refuses to download if you have less free
> disk than the archive size. The `en_all_maxi` at 119 GB requires a drive
> with at least that much free — check with `df -h .` before starting.

---

## Step 4 — Using Kiwix

Once the `.zim` is open in Kiwix:

- **Search** — type in the search bar; full-text search works instantly offline
- **Browse** — click article links just like on wikipedia.org
- **Bookmarks** — star articles for quick access
- **Tabs** — open multiple articles in tabs
- **Random article** — the dice icon gives you a random page

### Serving Wikipedia over your local network (Kiwix Server)

Kiwix Desktop has a **"Local server"** feature (menu → or the hotspot icon).
Enable it and anyone on your Wi-Fi can browse your Wikipedia archive by
visiting `http://YOUR_IP:8080` in their browser — no app install needed on
their end. Great for households or a Raspberry Pi setup.

### Kiwix Hotspot / Raspberry Pi

For a always-on offline Wikipedia box:
- Install `kiwix-tools` (the CLI/server package) on a Raspberry Pi
- Drop the `.zim` on the SD card / USB drive
- Run `kiwix-serve --port=8080 /path/to/wikipedia.zim`
- Connect devices to the Pi's Wi-Fi → browse at the served URL

---

## Tips & Gotchas

- **FAT32 can't store files > 4 GB.** If your USB stick is FAT32, reformat to
  exFAT or NTFS before copying a large `.zim` onto it.
- **Downloads are resumable.** If a large download is interrupted, re-running
  the script (or `wget -c`) picks up where it left off.
- **ZIM files are updated periodically** (monthly for `all`, roughly quarterly
  for `top`). Redownload to refresh — there's no in-place update.
- **Multiple ZIMs.** You can load several `.zim` files in Kiwix at once
  (e.g. English + German + a medicine subset) and search across them.
- **No LLM chat.** Kiwix is a *reader + search engine*, not a chatbot. If you
  later want natural-language Q&A over Wikipedia, that requires the RAG
  approach (vector DB + local LLM) — a separate project.

---

## Disk space summary

| What you want | Total disk needed |
|---|---|
| Test run (top-mini, 284 MB) | ~0.4 GB |
| Essentials (top-nopic, 2.6 GB) | ~3 GB |
| Top articles + images (top-maxi, 6.6 GB) | ~7 GB |
| Full English, no images (all-nopic, 50 GB) | ~52 GB |
| Full English + images (all-maxi, 119 GB) | ~120 GB |
| + Kiwix app itself | ~0.3 GB |

You currently have **249 GB free** — enough for any variant including the full
119 GB English with images.
