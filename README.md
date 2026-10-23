# cluon

Java 9 to Java 25 modernization skills and the `cluon-mcp` harness MCP server, packaged for Claude Code, Codex, Antigravity and Cursor.

The repository root is a single plugin. Every agent reads the same `skills/` directory; each agent has its own manifest and MCP config file:

| Agent | Manifest | MCP config |
| --- | --- | --- |
| Claude Code | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | `.mcp.json` |
| Codex | `plugin.json`, `.agents/plugins/marketplace.json` | `mcp.json` |
| Cursor | `.cursor-plugin/plugin.json`, `.cursor-plugin/marketplace.json` | `mcp.json` |
| Antigravity | `plugin.json` | `mcp_config.json` |

Skills are copied from `gluon/app/harness/skills`.

## Start the MCP server

The plugins do not launch the server. `cluon-mcp` serves streamable HTTP for one project, so start it in the project checkout before using the agent:

```sh
npx cluon-mcp --project-path /path/to/project
```

The first run for a project opens the browser to sign in. The MCP endpoint is `http://127.0.0.1:8000/mcp` and the harness UI is `http://127.0.0.1:8001`. If you change `--port`, update the URL in the agent's MCP config.

## Install

### Claude Code

```
/plugin marketplace add RetrievalLabs/cluon
/plugin install cluon@cluon
```

### Codex

```sh
codex plugin marketplace add RetrievalLabs/cluon
codex plugin add cluon@cluon
```

### Antigravity

```sh
agy plugin install https://github.com/RetrievalLabs/cluon
```

For the app or IDE, clone this repository into `~/.gemini/config/plugins/cluon` (all workspaces) or `.agents/plugins/cluon` (one workspace).

### Cursor

Add `https://github.com/RetrievalLabs/cluon` as a marketplace (Dashboard, Plugins & MCPs, Add Marketplace) and install `cluon`. To test locally, clone or link this repository to `~/.cursor/plugins/local/cluon`.
