# Personal OpenCodex

This directory owns portable defaults and the pinned OpenCodex/Bun versions.
It runs independently of CorpusLens. The CLI is `~/.local/bin/ocx`.

On another machine, clone these dotfiles, install mise, then:

```sh
mise trust ~/.dotfiles/config/opencodex/mise.toml
mise -C ~/.dotfiles/config/opencodex install
~/.dotfiles/bin/ocx-setup
```

Put `SYNTHETIC_API_KEY=...` in `~/.local/state/opencodex/secrets.env` with
mode `0600`. This is outside the public dotfiles repository. OpenAI credentials
are forwarded by the calling Codex client, rather than stored here.
Run `ocx start` in the foreground, or install the Mac login service:

```sh
ocx-setup --service
ocx ready --wait
```

The LaunchAgent is `com.dotfiles.opencodex`; it listens on loopback 10101.
Credentials, history, ledgers, generated catalogs and other mutable state live in
`~/.opencodex`; logs and the provider environment live in
`~/.local/state/opencodex`. `OPENCODEX_HOME`, `XDG_STATE_HOME`, and
`OPENCODEX_ENV_FILE` can override these local paths. The isolated catalog workspace
is `$OPENCODEX_HOME/codex`, never the real `~/.codex` profile.

The tracked config seeds new homes. Setup preserves an existing runtime config,
including changes made in the OpenCodex dashboard. To apply changed tracked defaults,
drain requests, stop the proxy, back up the private runtime config, and copy
`config.json` to `$OPENCODEX_HOME/config.json`. Never symlink that mutable file into
Git: OpenCodex may write resolved credentials and machine state into it.

For upgrades or service reconfiguration, drain requests and run
`launchctl bootout gui/$(id -u)/com.dotfiles.opencodex` first, update the pin/lockfile,
then rerun `ocx-setup --service`. Only these files belong in public Git; never add
runtime configs or environment files. Automatic Codex/Claude/Grok client injection,
history synchronization, and shim restoration are disabled in the portable defaults.

The separate legacy Linux Synthetic Codex deployment remains in CorpusLens. Its
package pin is independent; do not run its updater against this host service.
