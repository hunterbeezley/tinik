#!/usr/bin/env bash
# Tinik installer for macOS. Safe to re-run.
#   Optional: TINIK_VAULT="/path/to/Obsidian/vault" ./install.sh
set -euo pipefail

TINIK_HOME="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config/tinik"
BIN_DIR="$HOME/.local/bin"
MODELS=(qwen2.5-coder:14b qwen3:14b nomic-embed-text)

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
die()  { printf '\n\033[31mError:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname)" = Darwin ] || die "Tinik's installer supports macOS only."
export PATH="$BIN_DIR:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "=========================================="
echo "        Installing Tinik (local AI)       "
echo "=========================================="

mem_gb=$(( $(sysctl -n hw.memsize) / 1073741824 ))
if [ "$mem_gb" -lt 16 ]; then
  echo "Warning: this Mac has ${mem_gb} GB RAM. The 14B models want 16 GB+ and may be slow."
  echo "(~20 GB of disk is needed for the models.)"
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
fi
command -v brew >/dev/null 2>&1 || die "Homebrew install failed."

step "Ollama + uv"
for f in ollama uv; do brew list --formula "$f" >/dev/null 2>&1 || brew install "$f"; done
brew services start ollama >/dev/null 2>&1 || (nohup ollama serve >/dev/null 2>&1 &)
for _ in $(seq 1 30); do curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break; sleep 1; done
curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1 || die "Ollama isn't responding on :11434."

step "Models (large download, be patient)"
installed="$(ollama list)"
for m in "${MODELS[@]}"; do
  if grep -q "^$m" <<<"$installed"; then echo "have $m"; else ollama pull "$m"; fi
done

step "Aider + Open WebUI"
command -v aider >/dev/null 2>&1      || uv tool install --python 3.12 aider-chat
command -v open-webui >/dev/null 2>&1 || uv tool install --python 3.11 open-webui

step "Tinik command"
mkdir -p "$BIN_DIR" "$CFG"
chmod +x "$TINIK_HOME/bin/tinik"
ln -sf "$TINIK_HOME/bin/tinik" "$BIN_DIR/tinik"
RC="$HOME/.zshrc"; [ "${SHELL:-}" = /bin/bash ] && RC="$HOME/.bashrc"
if ! grep -qs '\.local/bin' "$RC"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
  echo "Added ~/.local/bin to PATH in $RC"
fi

step "Context + settings"
VAULT="${TINIK_VAULT:-}"
[ -z "$VAULT" ] && [ -f "$CFG/config.env" ] && VAULT="$(. "$CFG/config.env"; echo "${TINIK_VAULT:-}")"
if [ -z "$VAULT" ] && [ -t 0 ]; then
  read -r -p "Obsidian vault path (press Enter to skip): " VAULT
fi
printf 'TINIK_VAULT=%q\n' "$VAULT" > "$CFG/config.env"
ctx="$(<"$TINIK_HOME/config/context.template.md")"
ctx="${ctx//__TINIK_HOME__/$TINIK_HOME}"
ctx="${ctx//__VAULT__/${VAULT:-not configured}}"
printf '%s\n' "$ctx" > "$CFG/context.md"
echo "Wrote $CFG/context.md"

step "Tinik.app launcher"
APP="$HOME/Applications/Tinik.app"
mkdir -p "$HOME/Applications"; rm -rf "$APP"
osacompile -o "$APP" \
  -e 'display notification "Starting Tinik... your browser will open shortly." with title "Tinik"' \
  -e 'do shell script "\"$HOME/.local/bin/tinik\" plan >/dev/null 2>&1 &"' \
  && echo "Created $APP (drag it to your Dock)" || echo "Skipped launcher app (osacompile failed)."

cat <<DONE

==========================================
   Tinik installed!
==========================================
Open a NEW terminal window, then:
  tinik plan    Open the web interface (or double-click Tinik in ~/Applications)
  tinik chat    Chat in the terminal
  tinik         Coding assistant (run inside a project folder)
  tinik help    All commands
DONE
