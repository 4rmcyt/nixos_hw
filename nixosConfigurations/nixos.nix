{ inputs, ... } @flakeContext:
let
  nixosModule = { config, lib, pkgs, ... }: {
    config = {
    boot.kernelPackages = pkgs.linuxPackages_5_15;
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
    virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
      virtualisation = {
        memorySize = 2048; # Use 2048MiB memory.
        cores = 3;
        graphics = false;
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
            hashedPassword = "$y$j9T$Re9qbSfnwAT6A15oKUUIp/$/DvuyZzBWr9NV7fMi2T.ZmoeCgkjmYJ.30ydcrm5jB7";
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