{ lib, config, pkgs, ... } :

{
  services.jellyfin.enable = true;

  environment.persistence."/nix/persist".directories = [
    "/var/lib/jellyfin"
    "/var/cache/jellyfin"
  ];

  systemd.services.jellyfin.path = with pkgs; [
    jellyfin-ffmpeg
  ];

  # hardware decoding requires opengl to be enabled
  # (because /run/opengl-drivers/ needs it)
  hardware.opengl.enable = lib.mkDefault true;

  # HACK: this uses the intel-ucode flag, which is janky
  # but all my systems with intel-ucode have intel GPUs so :)
  hardware.opengl.extraPackages = with pkgs; lib.mkIf config.hardware.cpu.intel.updateMicrocode [
    intel-media-driver
    intel-media-sdk
    intel-compute-runtime
    # TODO: package oneapi-vpl
    intel-ocl
  ];
}
