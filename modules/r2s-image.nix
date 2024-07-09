{ config, lib, pkgs, nixpkgs, ... }:
with lib;
let
  rootfsImage = pkgs.callPackage "${nixpkgs}/nixos/lib/make-ext4-fs.nix" ({
    inherit (config.sdImage) storePaths;
    compressImage = false;
    volumeLabel = "NIXOS_SD";
  });
in
{
  imports = [
    # "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
  ];

  options.sdImage = {
    imageName = mkOption {
      default = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
      description = ''
        Name of the generated image file.
      '';
    };

    imageBaseName = mkOption {
      default = "nix-router";
      description = ''
        Prefix of the name of the generated image file.
      '';
    };

    storePaths = mkOption {
      type = with types; listOf package;
      example = literalExpression "[ pkgs.stdenv ]";
      description = ''
        Derivations to be included in the Nix store in the generated SD image.
      '';
    };

    compressImage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether the SD image should be compressed using
        {command}`zstd`.
      '';
    };
  };

  config = {
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-label/NIXOS_BOOT";
        fsType = "ext4";
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4"; # f2fs
        # options = [ "compress_algorithm=lz4" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
      };
    };

    sdImage.storePaths = [ config.system.build.toplevel ];

    system.build.sdImage = pkgs.callPackage
      ({ stdenv
       , dosfstools
       , e2fsprogs
       , mtools
       , libfaketime
       , util-linux
       , zstd
       , parted
       }: stdenv.mkDerivation {
        name = config.sdImage.imageName;

        nativeBuildInputs = [ dosfstools e2fsprogs libfaketime mtools util-linux parted ]
          ++ lib.optional config.sdImage.compressImage zstd;

        inherit (config.sdImage) imageName compressImage;

        buildCommand = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}

          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          if test -n "$compressImage"; then
            echo "file sd-image $img.zst" >> $out/nix-support/hydra-build-products
          else
            echo "file sd-image $img" >> $out/nix-support/hydra-build-products
          fi

          # make boot image
          mkdir -p boot
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./boot

          # Make a crude approximation of the size of the target image.
          # If the script starts failing, increase the fudge factors here.
          numInodes=$(find ./boot | wc -l)
          numDataBlocks=$(du -s -c -B 4096 --apparent-size ./boot | tail -1 | awk '{ print int($1 * 1.10) }')
          bytes=$((2 * 4096 * $numInodes + 4096 * $numDataBlocks))
          echo "Creating an EXT4 image (boot) of $bytes bytes (numInodes=$numInodes, numDataBlocks=$numDataBlocks)"
          truncate -s $bytes boot.img
          mkfs.ext4 -L NIXOS_BOOT -d ./boot boot.img

          root_fs=${rootfsImage}
          rootSizeBlocks=$(du -B 512 --apparent-size $root_fs | awk '{ print $1 }')
          bootSizeBlocks=$(du -B 512 --apparent-size boot.img | awk '{ print $1 }')
          imageSize=$((rootSizeBlocks * 512 + 557056 * 512 + 32 * 1024 * 1024))
          echo "Root filesystem blocks: $rootSizeBlocks, boot filesystem blocks: $bootSizeBlocks, image size: $imageSize"

          # Create the image file
          truncate -s $imageSize $img
          parted $img --script mklabel msdos
          parted $img --script mkpart primary ext4 32768s 557056s
          parted $img --script mkpart primary ext4 557057s 100%

          dd if=boot.img of=$img conv=notrunc bs=512 seek=32768
          dd if=$root_fs of=$img conv=notrunc bs=512 seek=524289

          # flash u-boot
          dd if=${./r2s-uboot}/idbloader.img of=$img conv=notrunc seek=64
          dd if=${./r2s-uboot}/u-boot.itb of=$img conv=notrunc seek=16384

          if test -n "$compressImage"; then
              zstd -T$NIX_BUILD_CORES --rm $img
          fi
        '';
      })
      { };

    boot.postBootCommands = ''
      # On the first boot do some maintenance tasks
      if [ -f /nix-path-registration ]; then
        set -euo pipefail
        set -x

        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}