#!/bin/sh
# Durmem standing-context hook. Runs the Durmem command-line tool's own installed
# runtime; downloads nothing and never falls back to fetching code at run time.
# With the tool missing it prints one line and exits 0 so the session carries on.
H="${HOME:-}/.loom"
V="$H/venv/bin/python"
[ -x "$V" ] || V="$H/venv/Scripts/python.exe"
S="$H/cli/loom_coding_inject.py"
if [ -f "$H/venv/.loom-ready" ] && [ -x "$V" ] && [ -f "$S" ]; then
    exec "$V" "$S"
fi
echo 'Durmem is not installed. Install it with: curl -fsSL https://durmem.ai/.well-known/cli/install.sh | sh (Windows PowerShell: irm https://durmem.ai/.well-known/cli/install.ps1 | iex), then run: durmem setup. More at https://durmem.ai/install' >&2
exit 0
