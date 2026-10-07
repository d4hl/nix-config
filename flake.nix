{
  description = "dahl NixOS configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    caelestia.url = "github:caelestia-dots/shell";
    caelestia.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager?ref=master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    milk-grub-theme.url = "github:gemakfy/MilkGrub";
    milk-grub-theme.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia-shell/v4.7.7";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    polyMc.url = "github:PolyMC/PolyMC";
    polyMc.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    helium.url = "github:schembriaiden/helium-browser-nix-flake";
    helium.inputs.nixpkgs.follows = "nixpkgs";

    happ.url = "github:d4hl/happ-nix";
    happ.inputs.nixpkgs.follows = "nixpkgs";

    pw-looper.url = "github:d4hl/pw-looper";
    pw-looper.inputs.nixpkgs.follows = "nixpkgs";

    affinity-nix.url = "github:mrshmllow/affinity-nix";
    affinity-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      flakePath = "/home/dahl/Documents/nix-config/";
      system = "x86_64-linux";

      localUtils = import ./utils.nix { lib = nixpkgs.lib; };
      openldapOverlay = _: prev: {
        openldap = prev.openldap.overrideAttrs {
          doCheck = !prev.stdenv.hostPlatform.isi686;
        };
      };

      overlays = [
        openldapOverlay
        inputs.affinity-nix.overlays.default
      ];

      pkgs = import nixpkgs { inherit system overlays; };

      makeSystem =
        { deviceName }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs flakePath localUtils;
            configurationName = deviceName;
          };
          modules = [
            ./nixos/configurations/${deviceName}
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.milk-grub-theme.nixosModule
            inputs.disko.nixosModules.disko
            inputs.happ.nixosModules.default
            {
              nixpkgs.overlays = overlays;
            }
          ];
        };

      makeHome =
        { username, deviceName }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs flakePath localUtils;
            configurationName = deviceName;
          };
          modules = [
            ./home/configurations/dahl-cli.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        b550m = makeSystem { deviceName = "b550m"; };
        latitude = makeSystem { deviceName = "latitude"; };
        lenovo = makeSystem { deviceName = "lenovo"; };
      };

      nixosModules = (import ./nixos/modules) { inherit localUtils; };
      homeManagerModules = (import ./home/modules) { inherit localUtils; };

      homeConfigurations = builtins.listToAttrs (
        map
          (
            { username, deviceName }:
            {
              name = "${username}@${deviceName}";
              value = makeHome { inherit username deviceName; };
            }
          )
          (
            nixpkgs.lib.cartesianProduct {
              username = [ "dahl" ];
              deviceName = [
                "server"
                "b550m"
                "latitude"
              ];
            }
          )
      );
    };
}
