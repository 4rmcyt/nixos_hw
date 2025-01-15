{ inputs, ... } @flakeContext:
let
  nixosModule = { config, lib, pkgs, ... }: {
    config = {
      boot = {
        growPartition = true;
        kernelParams = [ "console=ttyS0" ];
        loader.grub = {
          device = lib.mkDefault (
            if (hasNoFsPartition || supportBios) then
              "/dev/sda"
            else
              "nodev"
          );
          efiSupport = lib.mkDefault supportEfi;
          efiInstallAsRemovable = lib.mkDefault supportEfi;
        };

        loader.timeout = 0;
        initrd.availableKernelModules = [
          "uas"
          "virtio_blk"
          "virtio_pci"
        ];
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        autoResize = true;
        fsType = "ext4";
      };
      fileSystems."/boot" = lib.mkIf hasBootPartition {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
      networking = {
        enableIPv6 = true;
        firewall = {
          allowedTCPPorts = [
            80
            22
          ];
          enable = true;
        };
        useDHCP = true;
      };
      security = {
        sudo = {
          wheelNeedsPassword = true;
        };
      };
      services = {
        fail2ban = {
          enable = true;
          maxretry = 3;
        };
        nginx = {
          enable = true;
          virtualHosts = {
            nixos = {
              default = true;
              root = builtins.fetchTarball {
                url = "https://storage.mynixos.com/1499/resources/36039c27-7f93-4a38-ac38-fa4f01717caa/3ef8cd170e51cb28478a49013f62f3b4.jpg.tar.gz";
                sha256 = "8lwb9lZSPGLACg9IJtaRGqmcoCffiZ3GxM9MHN0SolY=";
              } + "/3ef8cd170e51cb28478a49013f62f3b4.jpg";
            };
          };
        };
        openssh = {
          enable = true;
          settings = {
            AllowUsers = [
              "nixos"
            ];
          };
        };
      };
      system = {
        autoUpgrade = {
          enable = true;
        };
        stateVersion = "24.11";
      };
      users = {
        extraGroups = {
          nixos = {
            name = "wheel systemd-journal";
          };
        };
        users = {
          nixos = {
            hashedPassword = "$y$j9T$P1v6RUEKYIfi04PQdHN1r.$.jeqXdBx5L32T60NGZyvU1Q/.sXmDyO/ZOMPVEb3AB/";
            isNormalUser = true;
          };
        };
      };
    };
  };
in
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    nixosModule
  ];
  system = "x86_64-linux";
}