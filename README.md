<p align="center">
  <img src="assets/gray-logo.svg" alt="gray" width="96">
</p>
<h1 align="center">gray-lens</h1>
<p align="center">Post-edit lint diagnostics, appended to the tool result the moment a write lands.</p>
<p align="center">
  <a href="https://github.com/vstaln/gray-lens/blob/main/LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="gray plugin" src="https://img.shields.io/badge/gray-plugin-7aa2f7.svg">
  <img alt="rust" src="https://img.shields.io/badge/built%20with-rust-orange.svg">
</p>

Post-edit diagnostics for file tools. After a write/edit-shaped tool call
succeeds, gray-lens runs the right checker for the file's language and
appends the findings to the tool result — the model sees problems the moment
it makes them.

A sidecar plugin for [gray](https://github.com/vstaln/gray).

## How it works

`tool/after` carries no args, so `tool/before` stashes the file path per
(session, tool). After the call, the extension of that path picks a checker:

| extension | checker |
|---|---|
| `.ts` `.tsx` `.js` `.jsx` | `tsc --noEmit` when a `tsconfig.json` is found walking up; else `npx eslint <file>` when an eslint config is found |
| `.py` | `ruff check <file>`, else `python3`/`python -m pyflakes <file>` |
| `.rs` | skipped by default — `cargo clippy` only when `rust_clippy` is enabled |
| `.go` | `gofmt -l <file>` + `go vet` on the package |
| `.sh` `.bash` | `shellcheck -f gcc <file>` |
| anything else | `ast-grep scan <file>` only when `fallback_ast_grep` is enabled |

Findings are appended as `--- lens: <tool> ---` blocks; the original result
is kept intact. Missing tools, timeouts and clean runs are silent. Every
failure path keeps the original tool result — lens never eats a result.

## Config

`~/.gray/lens/config.json`:

```json
{
  "enabled": true,
  "timeout_ms": 8000,
  "max_issues": 20,
  "fallback_ast_grep": false,
  "rust_clippy": false,
  "per_lang": {".py": "ruff check --select ALL", ".rs": {"enabled": false}}
}
```

`per_lang` values are command lines; the file path is appended, or placed
where `{file}` appears. `{"enabled": false}` disables a language.

## Commands

- `/lens` or `/lens status` — state, config path, tools found on PATH
- `/lens on` / `/lens off`
- `/lens lang` — list overrides
- `/lens lang <ext> <cmd…>` — set a checker override (`{file}` or appended path)
- `/lens lang <ext> off` / `/lens lang <ext> default` — disable / clear override

## Wire

- claims: `tool/before` (stash path, always allow), `tool/after` (append
  findings), `command/run` (`/lens`), `plugin/manifest`, `plugin/shutdown`
- protocol `2.0`, no capabilities, no tools

## Install

```sh
gray plugin install lens
```

No capabilities to grant.

---

Part of the [gray](https://github.com/vstaln/gray) plugin ecosystem —
the open-source AI agent harness. <https://gray.alignment.id>
