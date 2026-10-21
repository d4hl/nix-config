# Общий Nix binary cache между нодами флота.
#
# Идея:
#   * каждая нода поднимает nix-serve (порт 5000) и подписывает отдаваемые
#     пути общим ключом (приватная часть — secrets/nix-cache-key.age);
#   * в локалке ноды видят друг друга по mDNS как <node>.local (быстро);
#   * вне локалки — по Tailscale MagicDNS как <node>.hs;
#   * в substituters перечислены оба адреса, Nix сам берёт доступный,
#     а если ни один не ответил — падает на https://cache.nixos.org.
#
# Добавить ноду: дописать её hostName в cfg.nodes и выдать ей
# secrets/nix-cache-key.age в secrets.nix.
{
  config,
  lib,
  ...
}:
let
  cfg = config.localModules.nix-cache;

  # Публичная часть общего ключа подписи кэша.
  cachePublicKey = "nix-cache.hs-1:fVKkhjjcUaEMciRc5aZxu2CFOkmUPzbcLQ4s44LHWDg=";

  # self = networking.hostName == short-имя в Tailscale MagicDNS.
  self = config.networking.hostName;
  others = builtins.filter (n: n != self) cfg.nodes;

  portStr = toString cfg.port;

  # Сначала локалка, потом tailnet. Nix пробует по порядку и уходит
  # на следующий адрес, если предыдущий недоступен/не ответил.
  nodeUrls = lib.concatMap (n: [
    "http://${n}.local:${portStr}"
    "http://${n}.hs:${portStr}"
  ]) others;
in
{
  options.localModules.nix-cache = {
    enable = lib.mkEnableOption "общий Nix binary cache между нодами";

    serve = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Поднимать nix-serve на этой машине.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Порт nix-serve.";
    };

    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "kitayoza"
        "nix-machine"
        "nix-book"
      ];
      description = "Ноды-участники кэша (их networking.hostName / MagicDNS).";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- node discovery в локалке: <host>.local через mDNS ---
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # --- общий ключ подписи ---
    age.secrets.nix-cache-key.file = ../../../secrets/nix-cache-key.age;

    # --- серверная часть ---
    services.nix-serve = lib.mkIf cfg.serve {
      enable = true;
      port = cfg.port;
      bindAddress = "0.0.0.0";
      openFirewall = true;
      secretKeyFile = config.age.secrets.nix-cache-key.path;
    };

    # Если agenix ставит секреты отдельным сервисом (sysusers) — ждём его.
    systemd.services.nix-serve = lib.mkIf cfg.serve {
      after = [ "agenix-install-secrets.service" ];
      wants = [ "agenix-install-secrets.service" ];
    };

    # --- клиентская часть: тянем с соседей, потом с cache.nixos.org ---
    nix.settings = {
      substituters = nodeUrls ++ [ "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        cachePublicKey
      ];
      connect-timeout = 2;
      fallback = true;
    };
  };
}
