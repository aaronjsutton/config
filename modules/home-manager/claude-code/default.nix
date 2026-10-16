{ pkgs-unstable, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;

    context = ./config/CLAUDE.md;

    settings = {
      awaySummaryEnabled = false;
      model = "claude-opus-5-5";
      spinnerTipsEnabled = false;
      theme = "auto";
      timeFormat = "24-hour";
      permissions = {
        deny = [
          "Read(./.env)"
          "Read(./.env.*)"
          "Read(./secrets/**)"
        ];
      };
    };
  };
}
