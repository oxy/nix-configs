{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, ... }@attrs : {
    nixosConfigurations.carmine = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./hosts/carmine/configuration.nix ];
    };
  };
}
