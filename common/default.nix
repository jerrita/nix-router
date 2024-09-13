{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./shell.nix
    ./programs.nix
  ];

  environment.shellAliases = {
    vim = "nvim";
    lg = "lazygit";
  };
}
