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
    deviceName = "kitayoza";

    networking.hostName = config.deviceName;

    system.stateVersion = "24.11";
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };

    time.timeZone = "Asia/Yekaterinburg";

    systemd.services = {
      NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
      docker.wantedBy = lib.mkForce [ ];
    };

    localModules = {
      pipewire.enable = true;
      keyd.enable = true;
      home-manager.enable = true;
      i18n.enable = true;
      rocm = {
        enable = true;
        hsaOverrideGfxVersion = "11.0.0";
      };
      nix-ld.enable = true;
    };

    ##### NETWORKING #####
    networking = {
      networkmanager.enable = true;
      firewall.enable = false;
    };

    ##### BOOT #####

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          ControllerMode = "bredr";
          Disable = "Headset,Handsfree,Gateway";
        };
      };
    };

    ##### SERVICES #####
    security = {
      rtkit.enable = true;
    };

    services = {
      upower = {
        enable = true;
      };

      fwupd.enable = true;
      gvfs.enable = true;
      tumbler.enable = true; # превью файлов для thunar

      displayManager = {
        ly.enable = true;
      };
      desktopManager = {
        plasma6.enable = true;
      };

      ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        rocmOverrideGfx = "11.0.0";
      };

      openssh = {
        enable = true;
        settings = {
          GatewayPorts = "yes";
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      logind = {
        settings.Login = {
          HandleLidSwitch = "suspend";
          HandlePowerKey = "suspend-then-hibernate";
        };
      };

      tailscale = {
        enable = true;
      };
      resolved.enable = true;

      tlp = {
        enable = true;
        settings = {
          # Процессор и платформа
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          # Экономия энергии на шине PCIe (Критично!)
          # PCIE_ASPM_ON_BAT = "powersave";

          # Графика AMD: уровень 3 — золотая середина
          AMDGPU_ABM_LEVEL_ON_BAT = 3;

          # Диски
          DISK_IOSCHED = "none"; # Для NVMe планировщик не нужен

          # Радиомодули (отключаем Bluetooth, если не нужен в пути)
          # DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
        };
      };
      tlp.pd.enable = true;
      power-profiles-daemon.enable = false;

      nix-serve.enable = true;

      immich = {
        enable = true;
        host = "0.0.0.0";
      };
    };

    virtualisation = {
      docker.enable = true;
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
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
          dms.enable = true;
          firefox.enable = true;
          fish.enable = true;
          ghostty.enable = true;
          git.enable = true;
          hyprland.enable = true;
          kitty.enable = true;
          neovim.enable = true;
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

        programs = {
          nix-index.enable = true;
          nix-index.enableFishIntegration = true;
        };

        fonts.fontconfig.enable = true;

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
      corectrl.enable = true;
      fish.enable = true;
      happ = {
        enable = true;
        tunMode = {
          enable = true;
        };
      };
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      kdeconnect.enable = true;
      steam.enable = true;
      throne = {
        enable = true;
        tunMode.enable = true;
      };
      xfconf.enable = true;
    };

    environment.systemPackages = with pkgs; [ ];
  };
}
