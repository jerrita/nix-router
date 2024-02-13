{ config, pkgs, ... }:
{
    programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        ohMyZsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "sonicradish";
        };
    };
    users.defaultUserShell = pkgs.zsh;
}