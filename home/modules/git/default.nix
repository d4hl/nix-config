{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.localModules.git.enable = lib.mkEnableOption "Just git n smthn";

  config = lib.mkIf config.localModules.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        init.defaultBranch = "main";
        user = {
          name = "d4hl";
          email = "8tima18@gmail.com";
        };

        core = {
          compression = 9;
          whitespace = "error";
          preloadindex = true;
        };

        advice = {
          addEmpryPathspec = false;
          pushNonFastForward = false;
          statusHints = false;
        };

        url = {
          "git@github.com:" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
          "git@gitlab.com:" = {
            insteadOf = [
              "gl:"
              "gitlab:"
            ];
          };
        };

        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };

        merge = {
          tool = "diffview";
        };

        mergetool = {
          prompt = false;
          keepBackup = false;
          diffview.cmd = "nvim -n -c \"DiffviewOpen\" \"$MERGE\"";
          nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED";
        };

        diff = {
          tool = "nvimdiff";
        };

        difftool = {
          prompt = false;
          nvimdiff.cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };

        alias = {
          dt = "! args=$@; shift $#; nvim -c \"DiffviewOpen $args\"";
        };
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
      };
    };

    # programs.delta ={
    #   enable = true;
    #   options = {
    #     side-by-side = true;
    #     line-numbers = true;
    #     syntax-theme = "Dracula";
    #   };
    # };

    home.packages = with pkgs; [
      gh
      lazygit
    ];
  };
}
