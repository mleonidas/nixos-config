{ pkgs, ... }:

{

  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/zsh" ];

  users.users.mleone = {
    isNormalUser = true;
    home = "/home/mleone";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$PmPEpsEJ.V.Fial5$b70x7sYfU/vRdDHF4zMImVVPMZw9p1EzE9LpFblT8y5OJfkEhP0FHpXRnEW3oWIxndX1K5H1YZ7i29EucOjI30";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLsQtK/XeDVd3PRNrPLogYYw+6Sjub+7FiPaAsZloCQ mleone@flowcode.com"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
