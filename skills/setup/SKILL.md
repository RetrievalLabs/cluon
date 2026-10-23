---
name: setup
description: One-time machine setup for cluon. Installs git, JDK 8, 11, 17, 21 and 25 under /opt/jdks, Apache Maven, Gradle, the japicmp jar and Eclipse JDTLS, and points JAVA_HOME at JDK 25. Run only when the user asks, for /cluon:setup or "set up cluon"; never as part of working on a project.
disable-model-invocation: true
---

# Setup

Run this once per machine, not per project: everything it installs is shared by all projects. Run the bundled script. It supports Linux and macOS on x64 and arm64. Once a run completes it records that, and later runs print "already set up" and exit; pass `--force` only when the user asks to repair or update the environment. Components already present at the pinned version are never downloaded, with or without `--force`; the script prints which are present and which it will install, and does nothing else when all are present.

```sh
bash <this skill's directory>/scripts/setup.sh [--force]
```

It installs:

- git
- JDK 8, 11, 17, 21 and 25 in `/opt/jdks/jdk8`, `jdk11`, `jdk17`, `jdk21` and `jdk25`
- Apache Maven 3.9.16 in `/opt/maven`
- Gradle 9.7.0 in `/opt/gradle`
- japicmp 0.26.5 at `/opt/jars/japicmp.jar`
- Eclipse JDTLS 1.54.0 (pinned build 202511200503) in `/opt/jdtls`, with `jdtls` on `PATH`

It writes `~/.cluon/env.sh` and sources it from `~/.bashrc`, `~/.zshrc` and `~/.profile`. That file sets `JAVA_HOME` to JDK 25 and `GLUON_JDTLS_JAVA_HOME` to JDK 25, so JDTLS keeps running on JDK 25 when a migration switches `JAVA_HOME` to the project's JDK. The harness reads `/opt/jdks` by default; set `GLUON_JDK_ROOT` only to use another location.

## Notes

- Creating `/opt` directories and installing OS packages needs `sudo`. If sudo asks for a password you cannot enter, tell the user to run the script in their own terminal.
- Run it before starting `cluon-mcp`. Already-open shells and a running `cluon-mcp` do not see the new environment: tell the user to open a new shell or run `. ~/.cluon/env.sh`, then restart `cluon-mcp`.
- Finish by reporting the version lines the script prints, and any step that failed.
