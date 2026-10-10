{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  selectedCategories = config.localModules.programCategories;

  categoryPackages = {
    cli = with pkgs; [
      bat
      cloc
      fastfetch
      file
      jq
      lsof
      tree

      #archiving
      bzip2
      gnutar
      gzip
      unzip
      xz
      zip

      #monitoring
      btop-rocm
      conntrack-tools
      sysstat
      iotop
      powertop
      smartmontools

      #encryption
      age
      sops

      comma
      tldr
      matugen
      vault-bin
      cava
    ];

    programming = with pkgs; [
      # guess it
      android-tools
      android-studio

      dbeaver-bin

      nodejs
      python3
      uv

      #devops
      terraform
      ansible

      #nix
      nix-index
      nix-search-cli
      nix-output-monitor

      #kubernetes
      k9s
      kubectl
      kubernetes-helm

      #ai
      opencode
      pi-coding-agent
    ];

    networking = with pkgs; [
      dig
      inetutils
      nftables
      openssl
      traceroute
      wget
      wireguard-tools

      bandwhich
      iperf3
      mtr
      nmap
      tcpdump
      termshark
    ];

    desktop-essentials = with pkgs; [
      file-roller
      imv
      inputs.helium.packages.${system}.default
      kdePackages.filelight
      localsend
      mission-center
      qalculate-qt
      rhythmbox
      sioyek
      thunar
      vlc
      wireshark
    ];

    desktop = with pkgs; [
      anki
      audacity
      discord
      google-chrome
      libreoffice-qt6
      onlyoffice-desktopeditors
      moonlight-qt
      obsidian
      qbittorrent
      super-productivity
      telegram-desktop
      thunderbird
      vesktop
      vscode

      inputs.pw-looper.packages.${system}.default
    ];

    creation = with pkgs; [
      blender
      gimp
      godot
      inkscape
      kdePackages.kdenlive
      krita
      obs-studio
      # affinity-v3
    ];

    games = with pkgs; [
      wineWow64Packages.waylandFull
      winetricks
      lutris
      hydralauncher
    ];

    virtualization = with pkgs; [
      qemu
      virt-manager
      virt-viewer
      virtio-win
      spice
      spice-gtk
      spice-protocol
      win-spice
    ];

    mandatory = with pkgs; [
      # fonts
      iosevka-bin
      ipafont
      jetbrains-mono
      kochi-substitute
      material-icons

      nordic
      nordzy-icon-theme
      nwg-look
    ];
  };
in
{
  options.localModules.programCategories = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (builtins.attrNames categoryPackages));
    default = [ ];
    description = "List of enabled program categories";
  };

  config = lib.mkIf (selectedCategories != [ ]) {
    home.packages = lib.mkMerge (
      map (name: categoryPackages.${name}) (selectedCategories ++ [ "mandatory" ])
    );
  };
}
