{ nixpkgs, ... }:
{
  nixpkgs = {
    crossSystem = {
      config = "riscv64-unknown-linux-gnu";
      gcc.arch = "rv64gc";
      gcc.abi = "lp64d";
    };
  };
}
