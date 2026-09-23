{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.localModules.nix-ld.enable = lib.mkEnableOption "";

  config = lib.mkIf config.localModules.nix-ld.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libGL
        libdrm
        libgbm
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        libxshmfence
        libz
        nspr
        nss
        pango
        stdenv.cc.cc.lib
        zlib
        zstd
      ];
    };
  };
}
