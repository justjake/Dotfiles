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

If the default `~/.codex` belongs to another account (for example, work), create
an independent personal home and config first. Never copy the other account's
credentials or settings. Select the personal source before the first setup:

```sh
CODEX_THREAD_BRIDGE_DEFAULT_HOME="$HOME/.codex-personal" codex-bridge-setup --service
```

Setup saves the resolved source and worker homes in ignored `machine.local.json`.
Future setup and bridge commands reuse those homes without shell exports;
explicit environment overrides still take precedence. Authenticate the personal
source with `CODEX_HOME="$HOME/.codex-personal" codex login`, not the default app.

## Dedicated Linux VM on macOS

`vm.yaml` uses Lima 2.3+ and Apple Virtualization on ARM64 Macs. It has no
host filesystem mounts, forwarded SSH agent, container runtime, or automatic
application port forwarding. Host loopback access through Lima's gateway is
disabled; this is not a firewall against other LAN addresses. The 1 TiB disk
is sparse, not preallocated or a host-space reservation. Its actual writes
still consume host free space. The Mac must remain awake for remote access.
The guest hostname is `sr72-micro`, reapplied at boot. Its internal Lima
instance name remains `personal-codex` so existing wrappers continue to work.

Install the independent VM LaunchAgent (starts at user login, not before login):

```sh
brew install lima
python3 ~/.dotfiles/config/codex-thread-bridge/vm-host.py install
```

Inside the guest (`vm-host.py shell`), install `git`, `curl`, `xz-utils`,
`python3`, and `ca-certificates` using the guest package manager. Clone this
dotfiles branch into `~/.dotfiles` without linking any host files, then run:

```sh
sudo loginctl enable-linger "$USER"
sh ~/.dotfiles/config/codex-thread-bridge/vm-guest-setup.sh
```

The bootstrap verifies a pinned mise binary, installs Codex 0.160.1 and the
existing bridge dependencies, and reuses `codex-bridge-setup --service
--no-remote --project ~/.dotfiles`. Linux uses a systemd user service with
restart supervision; lingering keeps it running after SSH disconnects.
`--no-remote` allows independent provisioning before personal login.

Authenticate inside the guest using the source home and the Codex binary in
`machine.local.json`. The bootstrap prints the exact device-login command.
Never copy the host work credentials or managed settings into the guest.
Then run `~/.local/bin/codex-bridge enable-remote`, `status`, and `pair`.
Any applicable managed policy must still be respected.

```sh
python3 ~/.dotfiles/config/codex-thread-bridge/vm-host.py status
python3 ~/.dotfiles/config/codex-thread-bridge/vm-host.py shell
python3 ~/.dotfiles/config/codex-thread-bridge/vm-host.py stop
python3 ~/.dotfiles/config/codex-thread-bridge/vm-host.py start
```

Stopping Docker Desktop does not affect this VM. Stopping the VM LaunchAgent
with `vm-host.py stop` stops its supervision too; plain `limactl stop` does not.
The supervisor checks external power and the physical lid every five seconds.
It holds an idle/system sleep assertion only while on AC power with the lid
open. Battery power, a closed lid, an unreadable state, or VM exit releases it.
Display sleep and screen locking remain enabled. No global `pmset` settings
are changed. After updating the supervisor, stop/start the VM to refresh its
LaunchAgent definition.

After moving an existing personal instance, disable its outer LaunchAgent.
Set `"vm_instance": "personal-codex"` in the host's ignored
`machine.local.json` to route the existing `codex-bridge`, setup, CLI, and MCP
wrappers into the guest before accessing local homes. In this mode, setup's
`--project` paths must name guest directories, not host directories.
Transfer credentials only from an explicitly selected personal source, while
both personal services are stopped. Snapshot SQLite databases consistently,
remap project roots to guest paths, and regenerate the worker config there.
Do not migrate host-wide Claude backups, work credentials, or host settings.
Remove the old personal credential file only after guest login is verified.

### Optional guest Tailscale node

Inside the VM, run:

```sh
sh ~/.dotfiles/config/codex-thread-bridge/vm-tailscale-setup.sh install
sh ~/.dotfiles/config/codex-thread-bridge/vm-tailscale-setup.sh login
```

The installer verifies the pinned ARM64 Tailscale 1.104.7 Debian package against
the SHA-256 published in Tailscale's Ubuntu package index. It enables the
packaged `tailscaled` system service, including guest boot startup. Repeating
installation preserves node identity and login; an installed different version
requires explicit resolution instead of an automatic downgrade.

Login prints a browser approval URL. Its ten-second timeout only stops waiting;
the daemon can finish enrollment after browser approval. The node is named
`sr72-micro`. It does not accept subnet routes, change guest DNS, advertise
an exit node or subnet routes, or enable Tailscale SSH. Access follows the
tailnet's existing policy; joining does not create a restrictive tailnet ACL.
The guest's ordinary SSH daemon remains subject to its existing key auth.
No host Tailscale keys or configuration are imported.

State and private node keys remain in guest `/var/lib/tailscale`, never in
dotfiles. Rebuilds require approval again; reusing a VM disk preserves identity.
This pins installation, not all future security updates: bump the package
version and checksum together when updating. Node-key expiry and tailnet ACLs
remain managed through Tailscale, not silently weakened by setup.

Focused checks:

```sh
mise -C ~/.dotfiles/config/codex-thread-bridge exec -- uv run --locked \
  --project ~/.dotfiles/config/codex-thread-bridge python -m unittest discover \
  -s ~/.dotfiles/config/codex-thread-bridge -p 'test_*.py'
```
