{
  config,
  lib,
  pkgs,
  flakePath,
  configurationName,
  ...
}:
{
  options.localModules.hyprland.enable = lib.mkEnableOption "Enable configuration linking and programs heavily related to Hyprland WM";

  config = lib.mkIf config.localModules.hyprland.enable {
    home.packages = with pkgs; [
      kitty
      ghostty
      hyprsome
      playerctl
      wl-clipboard
      brightnessctl
      xdg-desktop-portal-hyprland

      # screenshots
      grim
      hyprshot
      jq
      libnotify
      satty
      slurp
      tesseract

      # connections
      networkmanagerapplet
      blueman

      # music
      pulseaudio
      alsa-utils
      pwvucontrol
    ];

    services.hypridle.enable = true;

    home.file = {
      ".config/hypr/" = {
        source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/home/modules/hyprland/src";
        recursive = true;
      };
      "Pictures/Wallpapers/" = {
        source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/wallpapers";
        recursive = true;
      };
    };
  };
}
