{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  options.localModules.spicetify.enable = lib.mkEnableOption "SPICEtify";

  config = lib.mkIf config.localModules.spicetify.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
        playNext
        playingSource
        spicyLyrics
      ];
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        marketplace
      ];
      enabledSnippets = with spicePkgs.snippets; [
        pointer
        # dynamicSearchBar
        thinLibrarySidebarRows
        # hideLyricsButton
      ];

      theme = spicePkgs.themes.defaultDynamic;
      # colorScheme = "mocha";
    };
  };
}
