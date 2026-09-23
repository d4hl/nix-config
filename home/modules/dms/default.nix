{
  config,
  lib,
  pkgs,
  flakePath,
  ...
}:
{
  options.localModules.dms.enable = lib.mkEnableOption "";

  config = lib.mkIf config.localModules.dms.enable {
    home.packages = [
      pkgs.dms-shell
      pkgs.quickshell
    ];

    home.file = {
      ".config/DankMaterialShell/" = {
        source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/home/modules/dms/src";
        recursive = true;
      };
    };
  };
}
