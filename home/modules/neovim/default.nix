{
  config,
  lib,
  pkgs,
  flakePath,
  ...
}:
{
  options.localModules.neovim.enable = lib.mkEnableOption "Neovim and all it deps";

  config = lib.mkIf config.localModules.neovim.enable {
    home.packages = with pkgs; [
      clang
      ripgrep
      tree-sitter

      # cpp
      llvmPackages_20.clang-tools
      # docker
      docker-language-server
      docker-compose-language-service
      # html + css + js + ts
      vscode-langservers-extracted
      tailwindcss-language-server
      typescript
      typescript-language-server
      # lua
      lua-language-server
      # nix
      nil
      nixfmt
      # python
      basedpyright
      ruff
      # qml
      kdePackages.qtdeclarative
      # terraform
      terraform-ls
      # typst
      tinymist
      typst
      # yaml
      yaml-language-server
    ];

    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      sideloadInitLua = true;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.file.".config/nvim/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/home/modules/neovim/src";
      recursive = true;
    };
  };
}
