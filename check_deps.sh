#!/bin/bash

set -e

# parse args
START_DOCKER=false
while [ $# -gt 0 ]; do
    case "$1" in
        --start|-s)
            START_DOCKER=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# detect package manager
detect_pkg_mgr() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew"
    else
        echo "unknown"
    fi
}

PKG_MGR=$(detect_pkg_mgr)

prompt_yesno() {
    local msg="$1"
    read -r -p "$msg [Y/n]: " ans
    ans="${ans:-Y}"
    case "$ans" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

install_with_pkgmgr() {
    local pkg="$1"
    case "$PKG_MGR" in
        apt)
            sudo apt-get update -y
            if [ "$pkg" = "docker" ]; then
                sudo apt-get install -y docker.io docker-compose-plugin
            else
                sudo apt-get install -y "$pkg"
            fi
            ;;
        dnf)
            if [ "$pkg" = "docker" ]; then
                sudo dnf install -y docker docker-compose-plugin
            else
                sudo dnf install -y "$pkg"
            fi
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$pkg"
            ;;
        apk)
            sudo apk add --no-cache "$pkg"
            ;;
        brew)
            if [ "$pkg" = "docker" ]; then
                brew install --cask docker || true
            else
                brew install "$pkg" || true
            fi
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

ensure_command() {
    local cmd="$1"
    local pkgname="${2:-$cmd}"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi

    echo "[WARN] '$cmd' not found."
    if [ "$PKG_MGR" = "unknown" ]; then
        echo "[ERROR] No supported package manager detected. Please install '$pkgname' manually."
        return 1
    fi

    if prompt_yesno "Install '$pkgname' using $PKG_MGR?"; then
        if install_with_pkgmgr "$pkgname"; then
            echo "[INFO] Installed $pkgname (or attempted)."
            if ! command -v "$cmd" >/dev/null 2>&1; then
                echo "[WARN] '$cmd' still not found after install. You may need to log out/in or follow manual install steps."
                return 1
            fi
        else
            echo "[ERROR] Failed to install '$pkgname' via $PKG_MGR. Install it manually."
            return 1
        fi
    else
        echo "[ERROR] Required command '$cmd' not installed. Aborting."
        return 1
    fi
    return 0
}

echo "[INFO] Checking system commands..."

# Commands required by the Makefile / project (Docker only)
REQUIRED_CMDS=(docker make git)

for cmd in "${REQUIRED_CMDS[@]}"; do
    # special-case: if docker-compose missing but 'docker compose' exists (modern docker), treat as present
    if [ "$cmd" = "docker-compose" ]; then
        if command -v docker-compose >/dev/null 2>&1; then
            continue
        fi
        if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
            echo "[INFO] 'docker compose' subcommand detected; skipping separate docker-compose binary."
            continue
        fi
        ensure_command "docker-compose" "docker-compose" || exit 1
        continue
    fi

    # For docker specifically, verify it's actually working
    if [ "$cmd" = "docker" ]; then
        if command -v docker >/dev/null 2>&1; then
            # Docker binary exists, check if it works
            if ! sudo docker version >/dev/null 2>&1 && ! docker version >/dev/null 2>&1; then
                echo "[WARN] 'docker' command found but not functional."
                if prompt_yesno "Reinstall docker using $PKG_MGR?"; then
                    if install_with_pkgmgr "docker"; then
                        echo "[INFO] Docker reinstalled (or attempted)."
                        # Verify again
                        if ! sudo docker version >/dev/null 2>&1 && ! docker version >/dev/null 2>&1; then
                            echo "[ERROR] Docker still not working after reinstall. Please install manually: https://docs.docker.com/engine/install/"
                            exit 1
                        fi
                    else
                        echo "[ERROR] Failed to reinstall Docker."
                        exit 1
                    fi
                else
                    echo "[ERROR] Docker is required but not working. Aborting."
                    exit 1
                fi
            fi
            continue
        fi
    fi

    ensure_command "$cmd" "$cmd" || exit 1
done

# If docker is installed, check if the current user can run it (no permission error).
if command -v docker >/dev/null 2>&1; then
    if ! docker version >/dev/null 2>&1; then
        echo "[WARN] 'docker' is installed but the current user can't run the daemon without sudo or it's not running."
        echo "       If you want to run docker as your user, consider: sudo usermod -aG docker \$USER && newgrp docker"
        echo "       Or run the Makefile targets with sudo as required."
    fi
fi

echo "[OK] Dependency check complete (Docker only)."

# If requested, attempt to ensure docker daemon is running and bring up the compose stack.
if [ "$START_DOCKER" = true ]; then
    echo "[INFO] --start provided: attempting to start docker daemon (if needed) and run 'docker compose up -d'"

    start_docker_service() {
        if command -v systemctl >/dev/null 2>&1; then
            # Check if docker.service exists before trying to enable/start
            if systemctl list-unit-files | grep -q '^docker\.service'; then
                echo "[INFO] Trying to start docker via systemctl..."
                sudo systemctl enable --now docker || true
                return 0
            else
                echo "[WARN] systemctl is present but docker.service is not installed or available."
                return 1
            fi
        fi

        # macOS: try to open Docker.app (may prompt user)
        if command -v open >/dev/null 2>&1; then
            echo "[INFO] Trying to start Docker.app (macOS)..."
            open --background -a Docker || true
            return 0
        fi

        # Fallback: nothing we can do
        return 1
    }

    # If docker binary missing but package manager may have installed it above, re-check
    if ! command -v docker >/dev/null 2>&1; then
        echo "[ERROR] 'docker' binary is not available after install attempts. Please install Docker manually."
        exit 1
    fi

    # Try to start docker if not responsive
    if ! docker info >/dev/null 2>&1; then
        echo "[INFO] Docker daemon not responding. Attempting to start it..."
        if start_docker_service; then
            # wait for docker to be ready
            MAX_WAIT=20
            i=0
            until docker info >/dev/null 2>&1 || [ $i -ge $MAX_WAIT ]; do
                printf '.'
                sleep 1
                i=$((i+1))
            done
            echo
            if docker info >/dev/null 2>&1; then
                echo "[INFO] Docker daemon is up."
            else
                echo "[WARN] Docker did not become ready within $MAX_WAIT seconds. You may need to start it manually."
            fi
        else
            echo "[WARN] Could not start docker automatically on this system. Start Docker manually and re-run 'make up'."
        fi
    else
        echo "[INFO] Docker daemon is already running."
    fi

    # Check again before running docker compose
    if ! command -v docker >/dev/null 2>&1; then
        echo "[ERROR] 'docker' command is still not available. Aborting."
        exit 1
    fi

    # Verify sudo docker works before proceeding
    if ! sudo docker version >/dev/null 2>&1; then
        echo "[ERROR] 'sudo docker' command is not working. Docker may not be installed correctly."
        echo "       Please install Docker manually following: https://docs.docker.com/engine/install/"
        exit 1
    fi

    echo "[INFO] Running: sudo docker compose up -d"
    sudo docker compose up -d
    echo "[SUCCESS] Docker Compose stack started (or attempted)."
fi
