{ pkgs ? import <nixpkgs> {} }:

with pkgs.beam.packages.erlang;

pkgs.mkShell {
  buildInputs = [ elixir ];
}
