{
  config,
  lib,
  pkgs,
  ...
}:
let
  browser = "helium.desktop";
  editor = "nvim.desktop";
  fileManager = "thunar.desktop";
  imageViewer = "imv.desktop";
  mailClient = "HEY.desktop";
  pdfViewer = "sioyek.desktop";
  terminal = "com.mitchellh.ghostty.desktop";
  videoPlayer = "vlc.desktop";
  audioPlayer = "org.gnome.Rhythmbox3.desktop";
in
{
  options.localModules.xdg.enable = lib.mkEnableOption "";

  config = lib.mkIf config.localModules.xdg.enable {
    xdg = {
      enable = true;

      terminal-exec = {
        enable = true;
        settings.default = [ terminal ];
      };

      mimeApps = {
        enable = true;

        defaultApplications = {

          # file manager
          "inode/directory" = fileManager;

          # browser
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;

          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";

          # mail
          "x-scheme-handler/mailto" = mailClient;

          # images
          "image/png" = imageViewer;
          "image/jpeg" = imageViewer;
          "image/gif" = imageViewer;
          "image/webp" = imageViewer;
          "image/bmp" = imageViewer;
          "image/tiff" = imageViewer;

          # pdf
          "application/pdf" = pdfViewer;

          # video
          "video/mp4" = videoPlayer;
          "video/x-msvideo" = videoPlayer;
          "video/x-matroska" = videoPlayer;
          "video/x-flv" = videoPlayer;
          "video/x-ms-wmv" = videoPlayer;
          "video/mpeg" = videoPlayer;
          "video/ogg" = videoPlayer;
          "video/webm" = videoPlayer;
          "video/quicktime" = videoPlayer;
          "video/3gpp" = videoPlayer;
          "video/3gpp2" = videoPlayer;
          "video/x-ms-asf" = videoPlayer;
          "video/x-ogm+ogg" = videoPlayer;
          "video/x-theora+ogg" = videoPlayer;
          "application/ogg" = videoPlayer;

          # audio
          "audio/vnd.wave" = audioPlayer;

          # text
          "text/plain" = editor;
          "text/markdown" = editor;
          "text/english" = editor;
          "text/x-makefile" = editor;
          "text/x-c++hdr" = editor;
          "text/x-c++src" = editor;
          "text/x-chdr" = editor;
          "text/x-csrc" = editor;
          "text/x-java" = editor;
          "text/x-moc" = editor;
          "text/x-pascal" = editor;
          "text/x-tcl" = editor;
          "text/x-tex" = editor;
          "application/x-shellscript" = editor;
          "text/x-c" = editor;
          "text/x-c++" = editor;
          "application/xml" = editor;
          "text/xml" = editor;
        };
      };
    };

    home.sessionVariables = {
      TERMINAL = "ghostty";
      BROWSER = "helium";
      XCURSOR_THEME = "Bibata-Modern-Classic";
    };
    systemd.user.sessionVariables = {
      TERMINAL = "ghostty";
      BROWSER = "helium";
      XCURSOR_THEME = "Bibata-Modern-Classic";
    };
  };
}
