{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;   # komenda `y`, po wyjściu zmienia katalog w shellu

    settings = {
      mgr = {
        ratio = [ 1 3 4 ];          # proporcje kolumn: rodzic / obecny / podgląd
        sort_by = "natural";        # file2 przed file10
        sort_dir_first = true;
        show_hidden = false;
        linemode = "size";
      };
      preview = {
        max_width = 1200;
        max_height = 1200;
      };
    };
  };

  # Narzędzia, z których yazi korzysta do podglądów i wyszukiwania
  home.packages = with pkgs; [
    ffmpeg          # miniatury wideo
    _7zz            # zawartość archiwów (zip/rar/7z)
    jq              # podgląd JSON
    poppler-utils   # podgląd PDF
    fd              # wyszukiwanie plików
    ripgrep         # wyszukiwanie treści
    fzf             # skok do pliku (Ctrl+F w yazi)
    zoxide          # skok do często używanych katalogów (Z w yazi)
    imagemagick     # HEIC, fonty i inne obrazki
    resvg           # podgląd SVG
    file            # wykrywanie typów plików
  ];
}
