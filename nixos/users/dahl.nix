{ pkgs, ... }:
{
  config = {
    users.users.dahl = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "networkmanager"
        "libvirtd"
        "input"
      ];
      shell = pkgs.fish;
    };
  };
}
