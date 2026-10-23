# cluon

Cluon is an agentic legacy code modernization tool built by RetrievalLabs. This plugin migrates Java 9 applications to Java 25 with migration skills and the `cluon-mcp` analysis server, preserving existing behavior. It is packaged for Claude Code, Codex, Antigravity and Cursor.

The repository root is a single plugin. Every agent reads the same `skills/` directory; each agent has its own manifest and MCP config file:

| Agent | Manifest | MCP config |
| --- | --- | --- |
| Claude Code | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | `.mcp.json` |
| Codex | `plugin.json`, `.agents/plugins/marketplace.json` | `mcp.json` |
| Cursor | `.cursor-plugin/plugin.json`, `.cursor-plugin/marketplace.json` | `mcp.json` |
| Antigravity | `plugin.json` | `mcp_config.json` |

Skills are copied from `gluon/app/harness/skills`.

## Set up the machine

Run the `setup` skill once per machine, not per project. In Claude Code:

```
/cluon:setup
```

It installs git, JDK 8, 11, 17, 21 and 25 under `/opt/jdks/jdkN`, Maven 3.9.16, Gradle 9.7.0, japicmp 0.26.5 at `/opt/jars/japicmp.jar` and Eclipse JDTLS 1.54.0 (`jdtls` on `PATH`). It sets `JAVA_HOME` and `GLUON_JDTLS_JAVA_HOME` to JDK 25 through `~/.cluon/env.sh`, which it sources from `~/.bashrc`, `~/.zshrc` and `~/.profile`. Linux and macOS are supported. Creating `/opt` directories needs `sudo`; if it needs a password, run `skills/setup/scripts/setup.sh` yourself in a terminal. Later runs do nothing unless you pass `--force`. Open a new shell afterwards.

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
