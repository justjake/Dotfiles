# Codex workers

The bridge uses its own Codex home at `config/codex-thread-bridge/home/` in
this checkout, also linked as `~/.codex-bridge`. Git ignores everything in
that home except its ignore file. Sessions, databases, installation identity,
remote-control registration, logs, credentials, and operation receipts never
belong in commits.

Install Codex CLI, mise, and the default profile's login on each machine, then:

```sh
mise trust ~/.dotfiles/config/codex-thread-bridge/mise.toml
mise -C ~/.dotfiles/config/codex-thread-bridge install
~/.dotfiles/bin/codex-bridge-setup --service --project "$PWD"
```

`--project` updates that project's `codex-threads` MCP entry in
`~/.claude.json`; with `--service`, it also registers the folder as a project
on the worker server. Other projects and MCP servers are preserved. Reload that
MCP server in existing Claude Code sessions; new sessions use the new endpoint.
Already running bridge processes keep their original endpoint and workers.

Setup installs a pinned commit of
[`justjake/codex-thread-bridge`](https://github.com/justjake/codex-thread-bridge),
selected by `source.json`. The fork records the ancestor Claude session that
owns each worker, so completion hooks can notify it through launcher processes.
Its source and Python environment are under `~/.local/share/codex-thread-bridge/`;
mise and uv manage dependencies. Changes to the bridge are committed in the fork.

The worker `config.toml` is generated from the default profile plus
`defaults.toml`. Setup refreshes that snapshot. Desktop UI preferences and
desktop notification commands are omitted. Hook trust records retain their
configuration path in the worker home. Machine paths remain in ignored local
files. User skills, AGENTS.md, rules, installed plugins, and the login file
are symlinked to the default home. Login refreshes are shared; the bridge has
an independent installation ID and independent databases.

The two skills in dotfiles are linked individually into the default profile,
preserving its installed system and custom skills. The bridge then sees that
same directory. `meta/install.sh codex-skills` uses the same arrangement.

On macOS, launchd supervises the server directly as
`com.dotfiles.codex-thread-bridge`, including restart after an exit and login
startup. Repeating setup preserves a running service; stop it before changing
its launch definition. Configuration refreshes take effect on its next start.

```sh
codex-bridge status       # Remote registration and connection status
codex-bridge check        # Read one page of worker history; starts no model turn
codex-bridge pair         # Generate a short-lived code for another client
codex-bridge cli agents   # Browse workers from the terminal
launchctl print "gui/$(id -u)/com.dotfiles.codex-thread-bridge"
```

Use the app's pairing flow to connect to the worker instance. Its initial
display name is the Mac's hostname, as determined by Codex itself. Setup does
not migrate or archive existing threads in the default profile.

`CODEX_THREAD_BRIDGE_HOME`, `CODEX_THREAD_BRIDGE_DEFAULT_HOME`, and
`CODEX_THREAD_BRIDGE_CODEX` override the worker home, personal home, and CLI
binary. `XDG_DATA_HOME` changes the bridge installation directory. The generated
LaunchAgent records resolved paths so it does not depend on an interactive shell.

Focused checks:

```sh
mise -C ~/.dotfiles/config/codex-thread-bridge exec -- uv run --locked \
  --project ~/.dotfiles/config/codex-thread-bridge python -m unittest discover \
  -s ~/.dotfiles/config/codex-thread-bridge -p 'test_*.py'
```
