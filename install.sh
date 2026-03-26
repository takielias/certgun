#!/bin/sh
set -e

# certgun installer
# Usage: curl -fsSL https://raw.githubusercontent.com/takielias/certgun/main/install.sh | sh

VERSION="0.2.0"
REPO="takielias/certgun"
BINARY="certgun"
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { printf "${CYAN}[certgun]${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}[certgun]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[certgun]${NC} %s\n" "$1"; }
error() { printf "${RED}[certgun]${NC} %s\n" "$1" >&2; exit 1; }

# Detect OS
detect_os() {
    OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$OS" in
        linux*)  OS="linux" ;;
        darwin*) OS="darwin" ;;
        *)       error "Unsupported OS: $OS" ;;
    esac
}

# Detect architecture
detect_arch() {
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64)  ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *)             error "Unsupported architecture: $ARCH" ;;
    esac
}

# Download and install
install_binary() {
    ARCHIVE="${BINARY}-${VERSION}-${OS}-${ARCH}.tar.gz"
    URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ARCHIVE}"

    info "Downloading certgun v${VERSION} for ${OS}/${ARCH}..."

    TMPDIR="$(mktemp -d)"
    trap 'rm -rf "$TMPDIR"' EXIT

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$URL" -o "${TMPDIR}/${ARCHIVE}" || error "Download failed. Check https://github.com/${REPO}/releases"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$URL" -O "${TMPDIR}/${ARCHIVE}" || error "Download failed. Check https://github.com/${REPO}/releases"
    else
        error "curl or wget required"
    fi

    info "Extracting..."
    tar -xzf "${TMPDIR}/${ARCHIVE}" -C "$TMPDIR"

    info "Installing to ${INSTALL_DIR}/${BINARY}..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "${TMPDIR}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
    else
        sudo mv "${TMPDIR}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
    fi
    chmod +x "${INSTALL_DIR}/${BINARY}"

    # Verify
    if command -v certgun >/dev/null 2>&1; then
        ok "Installed successfully: $(certgun --version 2>&1 | head -1)"
    else
        warn "Installed to ${INSTALL_DIR}/${BINARY}"
        warn "Make sure ${INSTALL_DIR} is in your PATH"
    fi
}

# Build from source as fallback
install_from_source() {
    if ! command -v go >/dev/null 2>&1; then
        error "Go is not installed. Install Go from https://go.dev/dl/ or download a pre-built binary from https://github.com/${REPO}/releases"
    fi

    info "Building from source..."
    go install -ldflags "-s -w -X 'github.com/taki/certgun/cmd.Version=${VERSION}'" github.com/taki/certgun@latest

    if command -v certgun >/dev/null 2>&1; then
        ok "Installed successfully: $(certgun --version 2>&1 | head -1)"
    else
        GOPATH="$(go env GOPATH)"
        warn "Installed to ${GOPATH}/bin/certgun"
        warn "Add this to your shell profile: export PATH=\$PATH:${GOPATH}/bin"
    fi
}

main() {
    printf "\n${CYAN}╔════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║   certgun — Origin Cert Installer       ║${NC}\n"
    printf "${CYAN}╚════════════════════════════════════════╝${NC}\n\n"

    detect_os
    detect_arch
    info "Detected: ${OS}/${ARCH}"

    # Try binary download first, fall back to source
    install_binary 2>/dev/null || {
        warn "Binary download failed, building from source..."
        install_from_source
    }

    printf "\n${GREEN}Get started:${NC}\n"
    printf "  certgun init\n"
    printf "  certgun setup\n\n"
}

main
