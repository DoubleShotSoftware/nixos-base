{...}: {
programs = {
    starship.enable = true;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha.rosewater = "#f5e0dc";
      palettes.catppuccin_mocha.flamingo = "#f2cdcd";
      palettes.catppuccin_mocha.pink = "#f5c2e7";
      palettes.catppuccin_mocha.mauve = "#cba6f7";
      palettes.catppuccin_mocha.red = "#f38ba8";
      palettes.catppuccin_mocha.maroon = "#eba0ac";
      palettes.catppuccin_mocha.peach = "#fab387";
      palettes.catppuccin_mocha.yellow = "#f9e2af";
      palettes.catppuccin_mocha.green = "#a6e3a1";
      palettes.catppuccin_mocha.teal = "#94e2d5";
      palettes.catppuccin_mocha.sky = "#89dceb";
      palettes.catppuccin_mocha.sapphire = "#74c7ec";
      palettes.catppuccin_mocha.blue = "#89b4fa";
      palettes.catppuccin_mocha.lavender = "#b4befe";
      palettes.catppuccin_mocha.text = "#cdd6f4";
      palettes.catppuccin_mocha.subtext1 = "#bac2de";
      palettes.catppuccin_mocha.subtext0 = "#a6adc8";
      palettes.catppuccin_mocha.overlay2 = "#9399b2";
      palettes.catppuccin_mocha.overlay1 = "#7f849c";
      palettes.catppuccin_mocha.overlay0 = "#6c7086";
      palettes.catppuccin_mocha.surface2 = "#585b70";
      palettes.catppuccin_mocha.surface1 = "#45475a";
      palettes.catppuccin_mocha.surface0 = "#313244";
      palettes.catppuccin_mocha.base = "#1e1e2e";
      palettes.catppuccin_mocha.mantle = "#181825";
      palettes.catppuccin_mocha.crust = "#11111b";
    };
};

}
