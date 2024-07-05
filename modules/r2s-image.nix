{ config, lib, pkgs, ... }:
with lib;
let
  rootfsTarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" ({
    compressCommand = "";
    compressionExtension = "";
    extraInputs = [ ];
    contents = [ ];
    storeContents = [{
      object = config.system.build.toplevel;
      symlink = "/run/current-system";
    }];
  });
in
{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
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
    environment.systemPackages = [ pkgs.f2fs-tools ];
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-label/NIXOS_BOOT";
        fsType = "ext4";
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "f2fs";
        options = [ "compress_algorithm=lz4" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
      };
    };

    sdImage.storePaths = [ config.system.build.toplevel ];

    system.build.sdImage = pkgs.callPackage ({ stdenv, dosfstools, e2fsprogs,
    mtools, libfaketime, util-linux, zstd, f2fs-tools }: stdenv.mkDerivation {
      name = config.sdImage.imageName;

      nativeBuildInputs = [ dosfstools e2fsprogs libfaketime mtools util-linux f2fs-tools ]
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

        root_fs=${rootfsTarball}  # xxx.tar
        tarballSize=$(stat -c %s $root_fs)
        rootfsSize=$($tarballSize + 32 * 1024 * 1024)

        # Create the image file
        fallocate -l $rootfsSize $img
        parted $img --script mklabel msdos
        parted $img --script mkpart primary 32768s 1081343s
        parted $img --script mkpart primary 1081344s 100%

        # Create the filesystems
        loop_dev=$(losetup -f)
        losetup $loop_dev $img
        partx -a $loop_dev
        mkfs.ext4 -L NIXOS_BOOT ''${loop_dev}p1
        mkfs.f2fs -l NIXOS_SD ''${loop_dev}p2

        # Mount the filesystems
        mkdir -p rootfs
        mount ''${loop_dev}p2 files
        mkdir -p rootfs/boot
        mount ''${loop_dev}p1 rootfs/boot

        # Extract the root filesystem
        tar -xf $root_fs -C rootfs

        # make system bootable
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./rootfs/boot

        # umount the filesystems
        umount rootfs/boot
        umount rootfs
        losetup -d $loop_dev

        # flash u-boot
        dd if=${./r2s-uboot}/idbloader.img of=$img conv=notrunc seek=64
        dd if=${./r2s-uboot}/u-boot.itb of=$img conv=notrunc seek=16384

        if test -n "$compressImage"; then
            zstd -T$NIX_BUILD_CORES --rm $img
        fi
      '';
    }) {};

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