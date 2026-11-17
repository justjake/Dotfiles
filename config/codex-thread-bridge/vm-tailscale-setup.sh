#!/bin/sh
# Optional guest networking. Never enroll the macOS host or copy its node keys.
set -eu
[ "$(uname -s)" = Linux ] && [ "$(uname -m)" = aarch64 ] || {
    echo "This bootstrap requires the Linux ARM64 guest" >&2
    exit 1
}
command="${1:-install}"
version=1.104.7
case "$command" in
    install)
        state="$(dpkg-query -W -f='${db:Status-Status}:${Version}' tailscale 2>/dev/null || true)"
        case "$state" in
            installed:*) installed="${state#installed:}" ;;
            *) installed="" ;;
        esac
        if [ -n "$installed" ] && [ "$installed" != "$version" ]; then
            echo "Preserving existing Tailscale $installed; resolve the version change explicitly" >&2
            exit 1
        fi
        if [ "$installed" != "$version" ]; then
            temporary="$(mktemp -d)"
            trap 'rm -r "$temporary"' EXIT
            curl --fail --location --retry 3 \
                "https://pkgs.tailscale.com/stable/ubuntu/pool/tailscale_${version}_arm64.deb" \
                --output "$temporary/tailscale.deb"
            printf '%s  %s\n' eed8d2dd9cdc17b2c49581e3c9b5e3a951f3d8ef7202a42fbaf351ac6ec5039f \
                "$temporary/tailscale.deb" | sha256sum --check
            chmod 755 "$temporary"
            sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                "$temporary/tailscale.deb"
        fi
        sudo systemctl enable --now tailscaled
        echo "Tailscale installed. Run this script with 'login' to enroll this guest."
        ;;
    login)
        sudo tailscale up --hostname=personal-codex --accept-dns=false --accept-routes=false \
            --advertise-exit-node=false --advertise-routes= --exit-node= \
            --advertise-connector=false --ssh=false --timeout=10s
        ;;
    status)
        tailscale status
        ;;
    *)
        echo "Usage: $0 [install|login|status]" >&2
        exit 2
        ;;
esac
