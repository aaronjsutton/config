{ ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg -l .";
    defaultOptions = [
      "--height=10%"
      "--layout=reverse"
    ];
  };
}
