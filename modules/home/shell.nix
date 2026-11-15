{ pkgs, ... }:
let
  srw-ip = "100.95.221.38";

  rs = pkgs.writeShellScriptBin "rs" ''
    cd ~/NixOS-config
    git add .
    if ! git diff --staged --quiet; then
      git commit -m "Aktualizacja: $(date '+%Y-%m-%d %H:%M:%S')" && git push
    fi
    nh os switch
  '';

  rs-srw = pkgs.writeShellScriptBin "rs-srw" ''
    cd ~/NixOS-config
    git add .
    if ! git diff --staged --quiet; then
      git commit -m "Aktualizacja serwera: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    nixos-rebuild switch --flake ~/NixOS-config#DCSRW \
      --target-host damian2120@${srw-ip} --build-host damian2120@${srw-ip} \
      --sudo --ask-sudo-password
  '';
in
{
  home.packages = [ rs rs-srw ];

  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "╭─$directory$git_branch$git_status\n╰─$character";

      directory = {
        style = "bold blue";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "";
        format = "[on $branch]($style) ";
        style = "bold purple";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold yellow";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  home.shellAliases = {
    r = "git -C ~/NixOS-config add . && nh os test";
    ssh-srw = ''ssh -t damian2120@${srw-ip} "TERM=xterm-256color bash -l"'';
    mount-srw = "mkdir -p ~/Serwer && sshfs damian2120@${srw-ip}:/ ~/Serwer";
    umount-srw = "fusermount -u ~/Serwer";
  };
}
