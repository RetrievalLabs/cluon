#!/usr/bin/env bash
# Starts the cluon-mcp harness server for one project and waits until it serves MCP.
#   start-server.sh start --target-version N [--project-path P]   launch it (or detect it running), report within ~20s
#   start-server.sh wait  [--project-path P]                      block until the MCP port accepts connections
# Split in two so the caller can show the sign-in link to the user while login is still pending.
set -euo pipefail

MCP_PORT="${CLUON_MCP_PORT:-8000}"
UI_PORT="${CLUON_UI_PORT:-8001}"
START_WINDOW=20     # seconds `start` waits for a sign-in link or readiness before returning
WAIT_LIMIT=330      # the harness gives the browser login 300 s, plus startup time
SIGN_IN_PREFIX="Sign in to connect this project:"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command_name="${1:-}"
[ "$command_name" = start ] || [ "$command_name" = wait ] || die "usage: start-server.sh start --target-version N [--project-path P] | wait [--project-path P]"
shift

target=""
project="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    --target-version) target="${2:-}"; shift 2 ;;
    --project-path) project="${2:-}"; shift 2 ;;
    *) die "unknown argument $1" ;;
  esac
done

[ -d "$project" ] || die "project path not found: $project"
project="$(cd "$project" && pwd)"

# Per-project log and pid file, so two projects do not overwrite each other's state.
state_dir="$HOME/.cluon/logs"
key="$(printf '%s' "$project" | cksum | cut -d' ' -f1)"
log_file="$state_dir/$key.log"
pid_file="$state_dir/$key.pid"

port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
server_alive() { [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; }
sign_in_line() { grep -m1 -F "$SIGN_IN_PREFIX" "$log_file" 2>/dev/null || true; }
ready_line() { printf 'ready mcp=http://127.0.0.1:%s/mcp ui=http://127.0.0.1:%s\n' "$MCP_PORT" "$UI_PORT"; }
fail_with_log() { printf 'error: cluon-mcp %s\n--- last log lines (%s) ---\n' "$1" "$log_file" >&2; tail -n 20 "$log_file" >&2 2>/dev/null || true; exit 1; }

# Watch the server until it is ready, dies, or the time limit passes. Prints the sign-in link once.
watch_server() {
  local limit="$1" shown="" line elapsed=0
  while [ "$elapsed" -lt "$limit" ]; do
    if port_open "$MCP_PORT"; then ready_line; return 0; fi
    if ! server_alive; then fail_with_log "exited before it was ready"; fi
    line="$(sign_in_line)"
    if [ -n "$line" ] && [ -z "$shown" ]; then printf 'login-required: %s\n' "${line#"$SIGN_IN_PREFIX" }"; shown=1; [ "$command_name" = start ] && return 0; fi
    sleep 1; elapsed=$((elapsed + 1))
  done
  return 1
}

if [ "$command_name" = wait ]; then
  watch_server "$WAIT_LIMIT" || fail_with_log "was not ready after ${WAIT_LIMIT}s"
  exit 0
fi

# --- start ---
case "$target" in ''|*[!0-9]*) die "--target-version must be a whole number between 9 and 25" ;; esac
{ [ "$target" -ge 9 ] && [ "$target" -le 25 ]; } || die "--target-version must be between 9 and 25"
git -C "$project" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "$project is not a git checkout"

# Setup installs the JDKs and JDTLS the stages depend on; it is a separate command and never run from here.
[ -f "$HOME/.cluon/env.sh" ] && . "$HOME/.cluon/env.sh"
if [ ! -x "$HOME/local/jdks/jdk25/bin/java" ] || [ ! -x "$HOME/local/jdtls/bin/jdtls" ]; then
  printf 'error: developer environment is not set up (need ~/local/jdks/jdk25 and ~/local/jdtls). Run /cluon:setup first.\n' >&2
  exit 2
fi
command -v npx >/dev/null || die "npx not found; install Node.js 18 or newer"

if port_open "$MCP_PORT"; then
  printf 'already running; its target version is the one it was started with. Stop it and run again to change it.\n'
  ready_line
  exit 0
fi

mkdir -p "$state_dir"
: > "$log_file"
launch=(npx -y @retrievallabs/cluon-mcp --project-path "$project" --target-version "$target" --port "$MCP_PORT" --ui-port "$UI_PORT")
# setsid detaches the server from the caller's process group so it outlives this script; macOS has none.
if command -v setsid >/dev/null; then launch=(setsid "${launch[@]}"); fi
nohup "${launch[@]}" > "$log_file" 2>&1 < /dev/null &
echo $! > "$pid_file"

watch_server "$START_WINDOW" || echo "starting: no sign-in link or MCP port yet; run the wait step"
