{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  # XXX: use this ONLY for hashed passwords
  inputs.secrets = {
    url = "github:oxy/nix-secrets";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }@attrs : {
    # carmine: Parallels vm (desktop)
    nixosConfigurations.carmine = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./hosts/carmine/configuration.nix ];
      specialArgs = attrs;
    };

    # garnet: tiger lake laptop (server)
    nixosConfigurations.garnet = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/garnet/configuration.nix ];
      specialArgs = attrs;
    };

    # zircon: dell xps 13 (desktop)
    nixosConfigurations.zircon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/zircon/configuration.nix ];
      specialArgs = attrs;
    };
  };
}
