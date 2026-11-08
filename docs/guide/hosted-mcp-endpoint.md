# Connect an MCP client over the web

<!-- loom-doc: slug=hosted-mcp-endpoint; audience=hosted; section=guide -->
Use this reference when your MCP client can only connect to a web address and cannot run the
Durmem plugin on your computer. Durmem offers a hosted MCP endpoint that gives such a client the
core memory tools for one store.

The Durmem plugin remains the recommended way to use Durmem: it gives your agent every Durmem
tool and the guidance that goes with them. Use the web endpoint only when the plugin is not an option.

## Connect

The endpoint is `https://durmem.ai/api/mcp`. It accepts MCP requests over HTTPS and answers with
JSON. Listing the tools needs no key. Calling a tool needs your store key, sent as a bearer token:

```text
Authorization: Bearer YOUR_STORE_KEY
```

Replace `YOUR_STORE_KEY` with the `store_key` of the store you want to open. Each key opens only its
own store. See [Local Durmem configuration](../reference/stores-toml.md) for where the key is kept.
Anyone who holds the key can read and change that store, so keep it out of chats, tickets and
public repositories, and send it only in the header of the request.

### Add it to your client

Do not paste the store key into a command line, chat, issue or tracked file. Put it in an
environment variable named `DURMEM_STORE_KEY`, set from the `store_key` in your local
configuration without echoing it (for example, read it with an editor or a command that does not
print it), and have each client read that variable. See
[Local Durmem configuration](../reference/stores-toml.md) for where the key is stored.

Claude Code (`.mcp.json` in the project or user scope; Claude Code expands `${VAR}`):

```json
{
  "mcpServers": {
    "durmem": {
      "type": "http",
      "url": "https://durmem.ai/api/mcp",
      "headers": { "Authorization": "Bearer ${DURMEM_STORE_KEY}" }
    }
  }
}
```

Codex (keep `--bearer-token-env-var`; do not paste the key into the command):

```sh
codex mcp add durmem --url https://durmem.ai/api/mcp --bearer-token-env-var DURMEM_STORE_KEY
```

OpenCode: `durmem setup` configures OpenCode for you. To add the endpoint by hand, follow
OpenCode's MCP documentation with these values: type `remote`, URL `https://durmem.ai/api/mcp`,
OAuth disabled, and the header `Authorization: Bearer {env:DURMEM_STORE_KEY}`. Keep the key in
the environment; never write it into a project file.

Claude Code's `${VAR}` expansion and Codex's `--bearer-token-env-var` follow those clients'
current configuration references. OpenCode's configuration layout differs by version, so use its
current MCP documentation rather than copying a JSON shape from this page.

The six tools listed below are what this endpoint can do from those clients.

## Tools

The endpoint offers six tools:

- `whoami` shows which store your key opens.
- `loom_describe_store` describes what the store holds.
- `loom_query` looks things up in the store: facts by type or label, a fact's history, text search, and the shape of what the store holds. It only reads; anything else is refused.
- `loom_read_probe_bundle` finds the facts most relevant to a question.
- `loom_save` saves one fact. It cannot save Kanban or worker-fleet records; use the plugin or the `durmem` command for those.
- `loom_nearest_types` suggests existing types close to some text, so you can reuse one.

It does not create, delete or revoke stores, retract facts, change rules, or manage Kanban boards.
Use the plugin or the `durmem` command for those.

## Limits

Requests are limited in size, and each key and each address can make a limited number of
requests per minute. When you exceed the limit, the endpoint answers with a "rate limited" error;
wait a minute and retry. A missing or wrong key always gets the same "authentication required"
answer.

If a call cannot complete — for example the store is full, or the server has a temporary
problem — the endpoint answers with a generic failure message rather than a detailed one. Try
again later, or open your store in the web app to check its state.
