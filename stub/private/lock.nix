let
  lock = builtins.fromJSON (builtins.readFile ../../flake.lock);
in
{
  private = (builtins.fetchTree lock.nodes.private.locked).outPath;
  public = toString (builtins.filter (n: n != "private") (builtins.attrNames lock.nodes.root.inputs));
}
