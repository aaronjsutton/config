{ pkgs-unstable, ... }:
{

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      aliases = {
        a = [
          "log"
          "-r"
          "all()"
        ];
        g = [ "git" ];
        sync = [
          "git"
          "fetch"
          "--all-remotes"
        ];
      };

      user.name = "Aaron Sutton";
      user.email = "aaron@aaron.as";

      git.private-commits = "description(glob:'private:*')";

      ui = {
        conflict-marker-style = "git";
        default-command = [ "log" ];
        diff-editor = [
          "nvim"
          "-c"
          "DiffEditor $left $right $output"
        ];
        diff-formatter = ":git";
        merge-editor = [
          "nvim"
          "-d"
          "$left"
          "$base"
          "$right"
          "$output"
        ];
      };

      templates = {
        git_push_bookmark = ''"aaron/push-" ++ change_id.short()'';
        log_node = ''
          coalesce(
            if(!self, "🮀"),
            if(current_working_copy, "◎"),
            if(root, "┴"),
            if(immutable, "●", "○"),
          )
        '';
        op_log_node = ''if(current_operation, "◎", "○")'';
      };

      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };

      template-aliases = {
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };
    };
  };
}
