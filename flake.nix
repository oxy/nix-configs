{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, ... }@attrs : {
    nixosConfigurations.simple = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./hosts/simple/configuration.nix ];
    };
  };
}
