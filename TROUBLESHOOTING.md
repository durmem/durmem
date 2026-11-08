# Troubleshooting
<!-- loom-onboarding-surface: troubleshooting -->

## The `durmem` command is not found

Re-run the secure installer for your operating system from
[INSTALL.md](INSTALL.md), open a new terminal, and run `durmem setup`.
Do not guess or copy a harness plugin-cache path.

## No supported harness is detected

Install or repair at least one currently supported harness: Claude Code, Codex,
or OpenCode. Confirm its executable is available in a new terminal, then rerun
`durmem setup`. Zero-detected setup makes no integration changes.

## One harness fails while another succeeds

Use the per-harness result summary: successful integrations remain installed,
and the failed row carries its actionable error and restart state. Correct that
harness, rerun setup, keep all detected harnesses selected by default, and opt
out of any you deliberately do not want changed.

## Existing configuration conflicts

Setup preserves unknown configuration and existing named store bindings. Read
the conflict shown for that harness and choose an explicit disposition; do not
delete `stores.toml`, replace it with another user's copy, or silently overwrite
the conflicting file.

## Authentication, consent, or provisioning fails

Start `durmem setup` again. Use only the newest email challenge, review the
displayed Terms and Privacy versions, and enter sensitive values only at the
hidden prompt. Do not put codes, links, grants, credentials, `stores.toml`, or
screenshots containing them in a GitHub issue -- it is public. See
[Still blocked](#still-blocked) before posting anything.

## Still blocked

Open a [GitHub issue](https://github.com/durmem/durmem/issues) with your
operating system, harness name and version, durmem version, and exact redacted
error message.

GitHub issues are public. Deleting one does not reliably erase it: the content
may persist in search engine caches, third-party archives or bots that scrape
public activity, and notification emails already sent. Before posting, remove every code, link, grant, credential,
`stores.toml` value, and screenshot containing them. Report security
vulnerabilities privately as described in [SECURITY.md](SECURITY.md), never in a
public issue.
