# Tinik

A private AI assistant that runs entirely on your Mac. No accounts, no cloud, nothing leaves your computer.

- **Web chat** (Open WebUI + Qwen3 14B): planning, writing, questions
- **Coding assistant** (Aider + Qwen 2.5 Coder 14B): builds and edits project files
- **Terminal chat**: quick questions from the command line

## Requirements
- A Mac with **16 GB+ RAM** (Apple Silicon recommended) and **~20 GB free disk**
- An internet connection for the one-time install

## Install

Open **Terminal** (press Cmd+Space, type "Terminal", press Enter) and paste:

```bash
git clone https://github.com/YOUR-USERNAME/tinik.git ~/tinik && ~/tinik/install.sh
```

If macOS offers to install "command line developer tools", click **Install**, wait, then paste the line again.
The install takes a while (about 20 GB of models). When it finishes, open a **new** Terminal window.

## Use

| Command | What it does |
|---|---|
| `tinik plan` | Opens the web interface (first launch takes a minute or two) |
| `tinik chat` | Chat in the terminal |
| `tinik` | Coding assistant. Run it inside a project folder |
| `tinik list` | Show installed models |
| `tinik stop` | Stop the web interface |
| `tinik update` | Get the latest version of Tinik |

You can also double-click **Tinik** in your `~/Applications` folder (drag it to the Dock). It opens the web interface.

The first time you open the web interface it asks you to create an account. That account lives only on your Mac.

## Notes (optional)

To let Tinik know about an Obsidian vault: `TINIK_VAULT="/path/to/vault" ~/tinik/install.sh`
(the installer also asks for it when run interactively). Then, in the web interface, add the vault under Workspace > Knowledge.

## Suggested workflow
1. **Plan** in `tinik plan` with Qwen3. Ask it to write the final plan as `PLAN.md` and save it in your project folder.
2. **Build** by running `tinik` inside that folder: "Read PLAN.md and do step 1". Aider makes small git commits; `/undo` reverts one. See [docs/aider-cheatsheet.md](docs/aider-cheatsheet.md).

## How it's put together
- `install.sh` installs Homebrew, Ollama, uv, Aider, Open WebUI, pulls the models and sets up the `tinik` command. Safe to re-run.
- `bin/tinik` is the command; `config/` holds the Aider settings and the context file Aider reads at startup.
- Per-machine settings live in `~/.config/tinik/`; web interface data in `~/.open-webui/`.

## Troubleshooting
- `command not found: tinik`: open a new Terminal window (or run `source ~/.zshrc`).
- Web interface won't open: check `~/.config/tinik/webui.log`.
- Slow or out-of-memory: close other apps; 14B models need plenty of RAM.
