# Security
<!-- loom-onboarding-surface: security -->

## Protect your store definition

`~/.loom/stores.toml` contains the connection details for your hosted stores.
Treat it as a credential file:

- never commit it to Git;
- never paste it into an issue, chat, screenshot, or log;
- do not share it between unrelated users;
- let `durmem setup` write it; do not assemble it by hand.

Email codes, magic links, enrollment grants, store keys, store credentials, and
other secrets are short-lived or sensitive authentication material. Never place
them on the command line, in command arguments, shell history, issue reports,
screenshots, or logs.

Before entering a code or following a sign-in link, confirm you started the
request at `https://durmem.ai/` and that the destination uses the
`durmem.ai` domain over HTTPS. Do not use a forwarded sign-in message or share
one with another person.

If you believe a store credential was exposed, stop using it and contact
[info@durmem.ai](mailto:info@durmem.ai).

## Protect your browser session

Durmem keeps you signed in with a secure browser session. On a shared or
public computer, sign out when you finish and close the browser window. Do not
copy browser cookies or session data between devices, and do not treat access to
your email inbox as a substitute for signing out of Durmem.

## Report a security issue privately

Please do not open a public issue for a vulnerability or credential exposure.
Email [info@durmem.ai](mailto:info@durmem.ai) with a concise description and a
reproduction that contains no live keys or personal data.

Service use is governed by the Durmem
[Terms](https://durmem.ai/terms) and
[Privacy Policy](https://durmem.ai/privacy).
