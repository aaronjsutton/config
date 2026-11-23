{
  description = "Empty stand-in for config-private";

  outputs = _: {
    stub = true;
    homeManagerModules.default = { };
  };
}
