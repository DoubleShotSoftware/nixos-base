# nixcats/languages/kotlin.nix - Kotlin/JVM language support
{pkgs, ...}: let
  kotlinLspPkg = pkgs."kotlin-lsp";
in {
  lspsAndRuntimeDeps = with pkgs; [
    jbang
    kotlinLspPkg
    jdk25_headless
    gradle
    maven
    kotlin
    ktlint
    # easy-kotlin's jar:// URI BufReadCmd shells out to `unzip -p` to
    # extract source files from src.zip / *-sources.jar so goto-def into
    # JDK and library symbols actually opens the source. Without unzip on
    # PATH the handler errors out and goto-def silently does nothing.
    unzip
  ];

  startupPlugins = [
    pkgs.easy-kotlin
  ];

  optionalPlugins = [];

  extra = {
    kotlinLspBinary = "${kotlinLspPkg}/bin/kotlin-lsp";
    kotlinSidecarBinary = "${pkgs.easy-kotlin-sidecar}/bin/easy-kotlin-sidecar";

    # JDK introspected by kotlin-lsp's IntelliJ analyzer for completion,
    # hover, and goto-definition. MUST ship lib/src.zip — without it, JDK
    # method docstrings render blank. Wired into easy-kotlin via
    # `init_options.defaultSdk` (mirrors kotlin-vscode's
    # `intellij.jdkForSymbolResolution`). The JBR bundled with kotlin-lsp
    # has no src.zip, which is why we point at a real nixpkgs JDK here.
    kotlinSymbolSdkHome = "${pkgs.jdk25_headless.home}";

    # JDK handed to kotlin-lsp's bundled Gradle Tooling API import via
    # -Dcom.jetbrains.ls.imports.gradle.java.home, short-circuiting
    # IntelliJ's JavaHomeFinder. `.home` resolves to lib/openjdk where
    # the `release` file sits at the root, so the finder accepts it
    # without the JBR workaround we previously relied on.
    kotlinGradleJdkHome = "${pkgs.jdk25_headless.home}";

    kotlinKtLintBinary = "${pkgs.unstable.ktlint}/bin/ktlint";
  };
}
