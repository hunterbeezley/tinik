# Tinik System Context

Tinik is a private, local AI setup running entirely on this Mac (no cloud).

## Layout
- **Tinik control dir:** `__TINIK_HOME__` — configs, scripts, harness settings, docs.
- **Notes vault (optional, Obsidian):** `__VAULT__` — central content source and project hub.
- **Ollama endpoint:** `http://127.0.0.1:11434`

## Models & Tools
- **Open WebUI + `qwen3:14b`:** high-level reasoning, planning, architecture, searching the notes vault.
- **Aider CLI + `qwen2.5-coder:14b`:** code execution, multi-file refactoring, git commits, file writes.
- **Embeddings:** `nomic-embed-text` via local Ollama.

## Standard Workflow
1. **Plan (Open WebUI, `tinik plan`):** brainstorm with `qwen3:14b`; save the final spec as `PLAN.md` in the project folder.
2. **Execute (Aider, `tinik`):** run inside the project folder containing `PLAN.md`. Work through the checklist in order, with small, clean git commits.
3. **Sync:** keep `PLAN.md` and project notes up to date as tasks complete.
