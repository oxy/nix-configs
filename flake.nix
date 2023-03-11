{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, ... }@attrs : {
    nixosConfigurations.carmine = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = attrs; # pass the inputs to the configuration
      modules = [ ./hosts/carmine/configuration.nix ];
    };
  };
}
