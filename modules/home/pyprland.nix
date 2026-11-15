{ pkgs, ... }:
{
  home.packages = [ pkgs.pyprland ];

  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads"]

    [scratchpads.yazi]
    command = "ghostty --class=com.yazi.app -e yazi"
    class = "com.yazi.app"
    animation = "fromTop"
    size = "70% 70%"
    position = "15% 15%"
    unfocus = "hide"
    pinned = true
    lazy = true

    [scratchpads.term]
    command = "ghostty --class=com.term.drop"
    class = "com.term.drop"
    animation = "fromTop"
    size = "70% 45%"
    margin = 50
    unfocus = "hide"
    pinned = true
    lazy = true
  '';
}
