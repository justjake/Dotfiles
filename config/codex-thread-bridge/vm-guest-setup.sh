#!/bin/sh
# Run inside the isolated Ubuntu ARM64 guest, never on the macOS host.
set -eu
[ "$(uname -s)" = Linux ] && [ "$(uname -m)" = aarch64 ] || {
    echo "This bootstrap requires an isolated Linux ARM64 guest" >&2
    exit 1
}
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin"
config_dir="${DOTFILES:-$HOME/.dotfiles}/config/codex-thread-bridge"
mkdir -p "$HOME/.local/bin"
if [ ! -x "$HOME/.local/bin/mise" ]; then
    temporary="$(mktemp -d)"
    trap 'rm -r "$temporary"' EXIT
    curl --fail --location --retry 3 \
        https://github.com/jdx/mise/releases/download/v2026.8.3/mise-v2026.8.3-linux-arm64.tar.xz \
        --output "$temporary/mise.tar.xz"
    printf '%s  %s\n' 3a6f03a30168c68a384c366d023f6b0daacdb11bfafeebe18caa0f1870616a91 \
        "$temporary/mise.tar.xz" | sha256sum --check
    tar -xJf "$temporary/mise.tar.xz" -C "$temporary" mise/bin/mise
    install -m 755 "$temporary/mise/bin/mise" "$HOME/.local/bin/mise"
fi
mise trust "$config_dir/mise.toml"
mise -C "$config_dir" install
mise install codex@0.160.1
codex="$(mise where codex@0.160.1)/bin/codex"
primary="${CODEX_THREAD_BRIDGE_DEFAULT_HOME:-$HOME/.codex-personal}"
mkdir -p "$primary"
chmod 700 "$primary"
if [ ! -e "$primary/config.toml" ]; then
    (umask 077; printf 'cli_auth_credentials_store = "file"\n' > "$primary/config.toml")
fi
CODEX_THREAD_BRIDGE_DEFAULT_HOME="$primary" CODEX_THREAD_BRIDGE_CODEX="$codex" \
    "$config_dir/../../bin/codex-bridge-setup" --service --no-remote --project "$HOME/.dotfiles"
if CODEX_HOME="$primary" "$codex" login status >/dev/null 2>&1; then
    echo "Personal source is already authenticated."
else
    echo "Authenticate with: CODEX_HOME=\"$primary\" \"$codex\" login --device-auth"
fi
echo "Then run: ~/.local/bin/codex-bridge enable-remote"
