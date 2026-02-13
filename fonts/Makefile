SHELL := /bin/bash

ZIP_FILES := $(wildcard *.zip)

DEST_DIR  := $(HOME)/.local/share/fonts
CACHE_CMD := fc-cache -f -v

BUILD_DIR   := build
EXTRACT_DIR := $(BUILD_DIR)/fonts_extract

# ---- dedupe duplicate font files (by content hash) ----
DUP_DIR := $(BUILD_DIR)/duplicate_fonts
.PHONY: all install clean list dedupe dedupe-dry

all: install

install:
	@set -euo pipefail; \
	if [[ -z "$(ZIP_FILES)" ]]; then \
		echo "No zip files found in current directory."; \
		exit 0; \
	fi; \
	echo "Installing fonts into subfolders under: $(DEST_DIR)"; \
	mkdir -p "$(DEST_DIR)"; \
	rm -rf "$(EXTRACT_DIR)"; \
	mkdir -p "$(EXTRACT_DIR)"; \
	for z in $(ZIP_FILES); do \
		name="$$(basename "$$z" .zip)"; \
		echo "==> $$z  ->  $(DEST_DIR)/$$name/"; \
		rm -rf "$(EXTRACT_DIR)/$$name"; \
		mkdir -p "$(EXTRACT_DIR)/$$name"; \
		unzip -o -q "$$z" -d "$(EXTRACT_DIR)/$$name"; \
		mkdir -p "$(DEST_DIR)/$$name"; \
		cnt=0; \
		while IFS= read -r -d '' f; do \
			cp -f "$$f" "$(DEST_DIR)/$$name/"; \
			cnt=$$((cnt+1)); \
		done < <(find "$(EXTRACT_DIR)/$$name" -type f \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) -print0); \
		if [[ $$cnt -eq 0 ]]; then \
			echo "   (no font files found in $$z)"; \
		else \
			echo "   copied $$cnt font file(s)"; \
		fi; \
	done; \
	echo "==> Rebuilding font cache for $(DEST_DIR)"; \
	$(CACHE_CMD) "$(DEST_DIR)"; \
	echo "Done."

list:
	@echo "Zip files:"; \
	ls -1 *.zip 2>/dev/null || echo "(none)"

clean:
	@rm -rf "$(BUILD_DIR)"

define PY_DEDUPE
import os, hashlib, shutil, sys

dest = os.environ["DEST_DIR"]
dup_dir = os.environ["DUP_DIR"]
dry = os.environ.get("DRY_RUN") == "1"
exts = {".ttf", ".otf", ".ttc"}

def sha256(path, chunk=1024*1024):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()

seen = {}   # hash -> kept_path
dupes = []  # (dup_path, kept_path)

for root, _, files in os.walk(dest):
    for fn in files:
        p = os.path.join(root, fn)
        if os.path.splitext(fn)[1].lower() not in exts:
            continue
        try:
            h = sha256(p)
        except Exception as e:
            print(f"[WARN] cannot read: {p} ({e})", file=sys.stderr)
            continue

        if h in seen:
            dupes.append((p, seen[h]))
        else:
            seen[h] = p

if not dupes:
    print("No duplicate-by-content fonts found.")
    raise SystemExit(0)

print("Duplicate files (same SHA-256 content):")
for p, keep in dupes:
    print(f"- {p}\n  keep: {keep}")

if dry:
    raise SystemExit(0)

os.makedirs(dup_dir, exist_ok=True)
moved = 0
for p, keep in dupes:
    base = os.path.basename(p)
    target = os.path.join(dup_dir, base)
    i = 1
    while os.path.exists(target):
        stem, ext = os.path.splitext(base)
        target = os.path.join(dup_dir, f"{stem}.{i}{ext}")
        i += 1
    shutil.move(p, target)
    moved += 1
    print(f"moved: {p} -> {target}\n  keep: {keep}")

print(f"Done. Moved {moved} duplicate font file(s).")
endef
export PY_DEDUPE

dedupe-dry:
	@set -euo pipefail; \
	DEST_DIR="$(DEST_DIR)" DUP_DIR="$(DUP_DIR)" DRY_RUN=1 python3 -c "$$PY_DEDUPE"

dedupe:
	@set -euo pipefail; \
	mkdir -p "$(DUP_DIR)"; \
	DEST_DIR="$(DEST_DIR)" DUP_DIR="$(DUP_DIR)" DRY_RUN=0 python3 -c "$$PY_DEDUPE"; \
	echo "==> Rebuilding font cache for $(DEST_DIR)"; \
	$(CACHE_CMD) "$(DEST_DIR)"