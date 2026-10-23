#!/usr/bin/env bash
# Sets up the cluon developer environment: git, JDK 8/11/17/21/25, Maven, Gradle, japicmp and JDTLS.
# Idempotent: every component that is already installed is skipped.
set -euo pipefail

OPT="${CLUON_OPT_ROOT:-/opt}"
JDKS="$OPT/jdks"
MAVEN_VERSION=3.9.16
GRADLE_VERSION=9.7.0
# Exact JDTLS build the harness is verified against; do not float to the latest, newer builds can change behavior.
JAPICMP_VERSION=0.26.5
JDTLS_BUILD=1.54.0-202511200503
JDK_VERSIONS=(8 11 17 21 25)
ENV_FILE="$HOME/.cluon/env.sh"
DONE_FILE="$HOME/.cluon/setup-complete"

# Setup is per machine, not per project, so a finished run makes later runs a no-op.
if [ -f "$DONE_FILE" ] && [ "${1:-}" != "--force" ]; then
  printf 'cluon is already set up on this machine (run with --force to repair or update it)\n'
  exit 0
fi

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in
  Linux) ADOPTIUM_OS=linux ;;
  Darwin) ADOPTIUM_OS=mac ;;
  *) die "unsupported OS $(uname -s); only Linux and macOS are supported" ;;
esac
case "$(uname -m)" in
  x86_64|amd64) ADOPTIUM_ARCH=x64 ;;
  aarch64|arm64) ADOPTIUM_ARCH=aarch64 ;;
  *) die "unsupported architecture $(uname -m)" ;;
esac

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

# Run a package manager command as root; installs of OS packages are the only thing that always needs it.
install_packages() {
  if command -v apt-get >/dev/null; then $SUDO apt-get update -qq && $SUDO apt-get install -y "$@"
  elif command -v dnf >/dev/null; then $SUDO dnf install -y "$@"
  elif command -v yum >/dev/null; then $SUDO yum install -y "$@"
  elif command -v zypper >/dev/null; then $SUDO zypper install -y "$@"
  elif command -v pacman >/dev/null; then $SUDO pacman -S --noconfirm "$@"
  elif command -v apk >/dev/null; then $SUDO apk add "$@"
  elif command -v brew >/dev/null; then brew install "$@"
  else die "no supported package manager found to install: $*"
  fi
}

for tool in git curl tar unzip python3; do
  if ! command -v "$tool" >/dev/null; then
    log "installing $tool"
    install_packages "$tool"
  fi
done

# Create a directory under the install root and hand it to the current user so later steps need no sudo.
own_dir() {
  if ! mkdir -p "$1" 2>/dev/null; then $SUDO mkdir -p "$1"; fi
  if [ ! -w "$1" ]; then $SUDO chown -R "$(id -un)" "$1"; fi
}

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

download() { curl -fsSL --retry 3 -o "$2" "$1" || die "download failed: $1"; }

# Unpack an archive into $2, stripping the single top-level directory.
extract_into() {
  local archive="$1" dest="$2" work
  work="$(mktemp -d "$SCRATCH/x.XXXXXX")"
  case "$archive" in
    *.zip) unzip -q "$archive" -d "$work" ;;
    *) tar -xzf "$archive" -C "$work" ;;
  esac
  rm -rf "$dest"
  mv "$work"/* "$dest"
}

install_jdk() {
  local version="$1" dest="$JDKS/jdk$1" archive home
  if [ -x "$dest/bin/java" ]; then log "JDK $version already installed"; return; fi
  log "installing JDK $version"
  archive="$SCRATCH/jdk$version.tar.gz"
  download "https://api.adoptium.net/v3/binary/latest/$version/ga/$ADOPTIUM_OS/$ADOPTIUM_ARCH/jdk/hotspot/normal/eclipse" "$archive"
  extract_into "$archive" "$SCRATCH/jdk$version"
  # macOS archives nest the JDK under Contents/Home; the /opt/jdks/jdkN layout must expose bin/ directly.
  home="$SCRATCH/jdk$version"
  if [ -d "$home/Contents/Home" ]; then home="$home/Contents/Home"; fi
  [ -x "$home/bin/java" ] || die "JDK $version archive has no bin/java"
  rm -rf "$dest"
  mv "$home" "$dest"
}

own_dir "$JDKS"
for version in "${JDK_VERSIONS[@]}"; do install_jdk "$version"; done

if [ ! -x "$OPT/maven/bin/mvn" ] || ! "$OPT/maven/bin/mvn" -v 2>/dev/null | grep -q "Apache Maven $MAVEN_VERSION"; then
  log "installing Maven $MAVEN_VERSION"
  download "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" "$SCRATCH/maven.tar.gz"
  own_dir "$OPT/maven"
  extract_into "$SCRATCH/maven.tar.gz" "$OPT/maven"
else log "Maven $MAVEN_VERSION already installed"; fi

if [ ! -x "$OPT/gradle/bin/gradle" ] || ! "$OPT/gradle/bin/gradle" -v 2>/dev/null | grep -q "Gradle $GRADLE_VERSION"; then
  log "installing Gradle $GRADLE_VERSION"
  download "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" "$SCRATCH/gradle.zip"
  own_dir "$OPT/gradle"
  extract_into "$SCRATCH/gradle.zip" "$OPT/gradle"
else log "Gradle $GRADLE_VERSION already installed"; fi

japicmp_installed() {
  unzip -p "$OPT/jars/japicmp.jar" META-INF/maven/com.github.siom79.japicmp/japicmp/pom.properties 2>/dev/null | grep -qx "version=$JAPICMP_VERSION"
}
if ! japicmp_installed; then
  log "installing japicmp $JAPICMP_VERSION"
  own_dir "$OPT/jars"
  # The jar-with-dependencies build is the one that runs with `java -jar`.
  download "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/$JAPICMP_VERSION/japicmp-$JAPICMP_VERSION-jar-with-dependencies.jar" "$OPT/jars/japicmp.jar"
else log "japicmp $JAPICMP_VERSION already installed"; fi

if ! ls "$OPT/jdtls/plugins" 2>/dev/null | grep -q "^org.eclipse.jdt.ls.core_${JDTLS_BUILD/-/.}.jar$"; then
  log "installing JDTLS $JDTLS_BUILD"
  download "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-$JDTLS_BUILD.tar.gz" "$SCRATCH/jdtls.tar.gz"
  own_dir "$OPT/jdtls"
  # JDTLS tarballs have no top-level directory, so unpack in place.
  rm -rf "${OPT:?}/jdtls"/*
  tar -xzf "$SCRATCH/jdtls.tar.gz" -C "$OPT/jdtls"
  [ -e "$OPT/jdtls/bin/jdtls" ] || die "JDTLS archive has no bin/jdtls"
  chmod +x "$OPT/jdtls/bin/jdtls"
else log "JDTLS $JDTLS_BUILD already installed"; fi

# JDK 25 is the default JAVA_HOME. JDTLS gets its own variable so it keeps running on JDK 25
# even when a migration switches JAVA_HOME to the project's JDK.
mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" <<ENV
export JAVA_HOME="$JDKS/jdk25"
export GLUON_JDTLS_JAVA_HOME="$JDKS/jdk25"
export PATH="\$JAVA_HOME/bin:$OPT/maven/bin:$OPT/gradle/bin:$OPT/jdtls/bin:\$PATH"
ENV

MARKER="# cluon environment"
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
  if ! grep -qF "$MARKER" "$rc" 2>/dev/null; then
    printf '\n%s\n[ -f "%s" ] && . "%s"\n' "$MARKER" "$ENV_FILE" "$ENV_FILE" >> "$rc"
  fi
done

log "verifying"
. "$ENV_FILE"
git --version
for version in "${JDK_VERSIONS[@]}"; do printf 'jdk%s: ' "$version"; "$JDKS/jdk$version/bin/java" -version 2>&1 | head -1; done
echo "JAVA_HOME=$JAVA_HOME"
mvn -v | head -1
gradle -v | grep '^Gradle'
ls -l "$OPT/jars/japicmp.jar"
ls "$OPT/jdtls/bin/jdtls"
touch "$DONE_FILE"
log "done. Open a new shell, or run: . $ENV_FILE"
