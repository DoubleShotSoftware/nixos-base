{pkgs, ...}: {
  packages = with pkgs; [
    gradle
    gradle-completion
    maven
    mill
    kotlin
    ktor-cli
    ktlint
  ];
  sessionVariables = {
    JAVA_HOME = "${pkgs.jdk25_headless}";
    JDK_HOME = "${pkgs.jdk25_headless}";
    IDEA_JDK = "${pkgs.jetbrains.jdk}";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
  };
  shellPlugins = {
    zsh = ["gradle" "mvn"];
    fish = []; # TODO: Add fish Kotlin/Gradle completions if available
    bash = []; # TODO: Add bash Kotlin/Gradle completions if available
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [
  ];
  homeManager = {
    home.file = {
      ".jdks/openjdk11".source = pkgs.jdk11_headless;
      ".jdks/openjdk17".source = pkgs.jdk17_headless;
      ".jdks/openjdk21".source = pkgs.jdk21_headless;
      ".jdks/openjdk25".source = pkgs.jdk25_headless;
      ".jdks/jetbrains".source = pkgs.jetbrains.jdk;
    };
  };
}
