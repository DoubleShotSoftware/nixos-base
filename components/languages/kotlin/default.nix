{ config, options, pkgs, ... }: {
  home.packages = with pkgs; [ kotlin ktlint gradle gradle-completion maven ];
  home.file = {
    ".jdks/openjdk8".source = pkgs.jdk8;
    ".jdks/openjdk11".source = pkgs.jdk11;
    ".jdks/openjdk17".source = pkgs.jdk;
    ".jdks/graalvm17-ce".source = pkgs.graalvm17-ce;
    ".jdks/graalvm11-ce".source = pkgs.graalvm11-ce;
    ".jdks/jetbrains".source = pkgs.jetbrains.jdk;
    ".ideavimrc".source = ./.ideavimrc;
    ".local/share/applications/IntellijEAP.desktop".source =
      ./IntellijEAP.desktop;
    ".local/share/applications/GatewayEAP.desktop".source =
      ./GateweayEAP.desktop;
  };
  programs.zsh = {
    initExtra = ''
      export JAVA_HOME=${pkgs.jdk11}
      export PATH=$JAVA_HOME/bin:$PATH
    '';
    oh-my-zsh = { plugins = [ "gradle" "mvn" ]; };
  };
  systemd.user.sessionVariables = {
    IDEA_JDK = "$HOME/.jdks/jetbrains";
    JAVA_HOME = "$HOME/.jdks/graalvm17-ce";
    JDK_HOME = "$HOME/.jdks/graalvm17-ce";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
  };
}
