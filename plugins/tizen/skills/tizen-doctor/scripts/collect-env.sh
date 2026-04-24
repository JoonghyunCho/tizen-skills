#!/usr/bin/env bash
# collect-env.sh — snapshot a Tizen .NET development environment on Linux / macOS / WSL2.
#
# Output is a single YAML-ish block on stdout so the calling agent can parse it.
# All probes degrade gracefully: missing commands print `not-found` instead of failing.
#
# Usage: bash collect-env.sh

set -u

have() { command -v "$1" >/dev/null 2>&1; }

print_kv() {
  # $1 = key, $2 = value (may contain newlines — will be indented under the key)
  local key="$1"
  local value="${2:-not-found}"
  if [[ "$value" == *$'\n'* ]]; then
    echo "${key}: |"
    printf '%s\n' "$value" | sed 's/^/  /'
  else
    echo "${key}: ${value}"
  fi
}

# --- Host ---------------------------------------------------------------------
echo "host:"
echo "  os: $(uname -s)"
echo "  kernel: $(uname -r)"
echo "  arch: $(uname -m)"
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "  distro: ${PRETTY_NAME:-unknown}"
fi
if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "  wsl: true"
else
  echo "  wsl: false"
fi

# --- .NET ---------------------------------------------------------------------
echo "dotnet:"
if have dotnet; then
  echo "  path: $(command -v dotnet)"
  echo "  version: $(dotnet --version 2>/dev/null || echo not-found)"
  echo "  sdks:"
  dotnet --list-sdks 2>/dev/null | sed 's/^/    - /' || echo "    - not-found"
  echo "  runtimes:"
  dotnet --list-runtimes 2>/dev/null | sed 's/^/    - /' || echo "    - not-found"
  echo "  workloads:"
  # `dotnet workload list` requires SDK 6+; swallow errors
  dotnet workload list 2>/dev/null | sed 's/^/    /' || echo "    not-found"
else
  echo "  status: not-found"
fi

# --- Tizen Studio / sdb -------------------------------------------------------
echo "tizen_studio:"
if [[ -n "${TIZEN_STUDIO:-}" ]]; then
  echo "  env_TIZEN_STUDIO: ${TIZEN_STUDIO}"
else
  echo "  env_TIZEN_STUDIO: not-set"
fi
if have sdb; then
  echo "  sdb_path: $(command -v sdb)"
  echo "  sdb_version: $(sdb version 2>&1 | head -n1)"
else
  echo "  sdb_path: not-found"
fi
if have tizen; then
  echo "  tizen_cli_path: $(command -v tizen)"
  echo "  tizen_cli_version: $(tizen version 2>&1 | head -n1)"
else
  echo "  tizen_cli_path: not-found"
fi

# --- Java (needed by Tizen Studio signer) -------------------------------------
echo "java:"
if have java; then
  echo "  path: $(command -v java)"
  # java -version writes to stderr
  echo "  version: $(java -version 2>&1 | head -n1)"
else
  echo "  status: not-found"
fi

# --- Certificate profiles -----------------------------------------------------
echo "tizen_certificates:"
PROFILES_XML="${TIZEN_STUDIO_DATA:-$HOME/tizen-studio-data}/profile/profiles.xml"
if [[ -r "$PROFILES_XML" ]]; then
  echo "  profiles_xml: $PROFILES_XML"
  # shellcheck disable=SC2016
  grep -oE 'profile name="[^"]+"' "$PROFILES_XML" 2>/dev/null | sed 's/^/  - /' || true
else
  echo "  profiles_xml: not-found"
fi

# --- TizenFX repo hints -------------------------------------------------------
echo "repo:"
if [[ -f build.sh && -d src ]]; then
  echo "  looks_like_tizenfx: true"
  echo "  build_sh_executable: $([[ -x build.sh ]] && echo yes || echo no)"
else
  echo "  looks_like_tizenfx: false"
fi

# --- PATH hygiene -------------------------------------------------------------
echo "path_hygiene:"
echo "  dotnet_on_path: $(have dotnet && echo yes || echo no)"
echo "  sdb_on_path: $(have sdb && echo yes || echo no)"
echo "  multiple_dotnet_binaries:"
# Find every `dotnet` binary reachable via PATH; useful when user has both
# the Microsoft install and a Homebrew / snap copy.
( IFS=:; for p in $PATH; do [[ -x "$p/dotnet" ]] && echo "    - $p/dotnet"; done ) | sort -u
