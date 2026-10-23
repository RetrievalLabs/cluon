---
name: analyze
description: Analyze a legacy Java project for migration to a target Java version. Starts the cluon-mcp harness server for the project, signs the user in to the cluon platform on first use, then runs every analysis stage through the harness MCP tools and reports progress. Run only when the user asks, for /cluon:analyze or "analyze this project for Java N".
argument-hint: <target-java-version> [project-path]
disable-model-invocation: true
---

# Analyze

Analysis only: do not edit the project's source files. Run `/cluon:setup` first on a new machine; this skill never runs it.

Inputs: the target Java major version (9 to 25) and the project path (default: the current directory). If the target version was not given, ask for it.

## 1. Start the server

```sh
bash <this skill's directory>/scripts/start-server.sh start --target-version <N> --project-path <path>
```

It launches `npx @retrievallabs/cluon-mcp` for the project in the background and returns within about 20 seconds. Read its output:

- `error: developer environment is not set up` (exit 2): tell the user to run `/cluon:setup`, then stop.
- `login-required: <url>`: first run for this project, or the stored login expired. The harness already tried to open the browser. Give the user the link right away and ask them to open it if no browser window appeared. It must be opened on this machine. Then run step 2.
- `ready mcp=... ui=...`: the server is up and signed in. Go to step 3.
- `already running`: a server for another run is already listening. It keeps the target version it started with; tell the user, and if that is wrong, ask them to stop it and run this skill again.
- `starting`: nothing to show yet. Run step 2.
- Any other error: show the log lines the script printed and stop.

## 2. Wait for login

```sh
bash <this skill's directory>/scripts/start-server.sh wait --project-path <path>
```

This blocks until the server accepts MCP connections (up to about 5.5 minutes, the harness login timeout) and prints `ready mcp=... ui=...`. If it fails, show the log lines it printed and stop.

## 3. Connect the MCP tools

Tell the user the dashboard is at the `ui` URL. The cluon MCP server was not running when this session started, so its tools may not be connected yet. If `next_stage_unit` is not available, ask the user to reconnect the `cluon` MCP server (Claude Code: `/mcp`; other agents: reload or restart their MCP servers) and wait for them to confirm. A session whose connection was refused at startup does not retry on its own, so if reconnecting does not restore the tools, ask the user to start a new session and run this skill again.

## 4. Run every stage

Repeat until done:

1. Call `next_stage_unit`.
2. `status: pending`: call the tool named in `item.tool`, passing `item.unit_id` when present, and follow the instructions the tool returns. For architecture units, give the returned prompt to a fresh subagent, then call `complete_architecture_report_unit` with its summary and labels, as the tool says.
3. `status: in_progress`: something is already running. Call `status`, then call `next_stage_unit` again. If `status` shows no change after several checks, report that the stage looks stuck and stop.
4. `status: complete`: all stages are done.

A stage that failed comes back as `pending` and is retried. If the same stage fails three times in a row, stop and report the error. After each finished stage, give the user one line of progress from `status`.

The stage order comes from the harness, so follow `next_stage_unit` rather than a fixed list.

## 5. Finish

Summarize which stages completed and any that failed. Give the dashboard link. Leave the server running so the dashboard stays available.
