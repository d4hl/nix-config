{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix

    ../../users/dahl.nix
    ../../modules
  ];

  options.deviceName = lib.mkOption { type = lib.types.str; };

  config = {
    deviceName = "nix-machine";
    networking.hostName = config.deviceName;

    system.stateVersion = "24.11";
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
      trusted-users = [
        "dahl"
      ];
    };

    time.timeZone = "Asia/Yekaterinburg";

    localModules = {
      pipewire.enable = true;
      keyd.enable = true;
      home-manager.enable = true;
      rocm = {
        enable = true;
        hsaOverrideGfxVersion = "10.3.0";
      };
      i18n.enable = true;
      nix-ld.enable = true;
      agenix = {
        enable = true;
        secrets = {
          node-token = ../../../secrets/k3s/node-token.age;
        };
      };
    };

    ##### NETWORKING #####
    networking = {
      networkmanager.enable = true;
      firewall.enable = false;

      extraHosts = "";
    };

    ##### BOOT #####
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General.Experimental = true;
        };
      };

      alsa.enablePersistence = true;
    };

    ##### SERVICES #####
    security = {
      rtkit.enable = true;
    };

    services = {
      displayManager.ly.enable = true;

      fwupd.enable = true;
      gvfs.enable = true;
      tumbler.enable = true; # превью файлов для thunar

      openssh = {
        enable = true;
        settings = {
          GatewayPorts = "yes";
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        rocmOverrideGfx = "10.3.0";
      };

      spice-vdagentd.enable = true;

      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
      '';

      sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
      };

      tailscale.enable = true;
      resolved.enable = true;
    };

    ##### VIRTUALIZATION #####
    virtualisation = {
      docker.enable = true;
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };
      podman = {
        enable = true;
        extraPackages = with pkgs; [ podman-compose ];
      };
      waydroid = {
        enable = true;
        package = pkgs.waydroid-nftables;
      };
    };

    ##### HOME MANAGER #####
    home-manager.users.dahl = {
      imports = [
        ../../../home/modules
      ];

      config = {
        home.stateVersion = "25.05";
        targets.genericLinux.enable = true;

        localModules = {
          anki.enable = true;
          bitwarden.enable = true;
          firefox.enable = true;
          fish.enable = true;
          ghostty.enable = true;
          git.enable = true;
          hyprland.enable = true;
          kitty.enable = true;
          neovim.enable = true;
          # noctalia-shell.enable = true;
          dms.enable = true;
          spicetify.enable = true;
          theme.enable = true;
          theme.name = "orchis";
          tmux.enable = true;
          xdg.enable = true;
          programCategories = [
            "cli"
            "programming"
            "networking"
            "desktop-essentials"
            "desktop"
            "creation"
            "games"
            "virtualization"
          ];
        };

        fonts.fontconfig.enable = true;

        programs = {
          nix-index.enable = true;
          nix-index.enableFishIntegration = true;
        };
      };
    };

    ##### PROGRAMS #####
    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-40.10.5"
      ];
    };

    documentation.man.cache.enable = false; # disable fish cache generation
    programs = {
      fish.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      steam.enable = true;
      xfconf.enable = true;

      throne = {
        enable = true;
        tunMode.enable = true;
      };
      happ = {
        enable = true;
        tunMode.enable = true;
      };
      corectrl.enable = true;
    };

    environment.systemPackages = with pkgs; [ ];
  };
}

