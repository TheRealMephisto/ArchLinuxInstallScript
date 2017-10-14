# ArchLinuxInstallScript

## Description
An install script for a basic arch linux installation.
At this time, it should only be used for installation on USB drives.<br>
Remember: I'm not responsible for what you do to your computer! If anything bad happens, do not blame me!<br>
I'd advice you to not use this script unless you need a real quick installation.
Better use the official [Arch Linux Installation Guide](https://www.archlinux.org/index.php/Installation_guide).

## Preparation

Create a Linux ext4 filesystem on your usb - don't forget to disable journaling.
Use only one partition!<br>
Mount the device (e.g. /dev/sdb1) and pacstrap the packages base and base-devel onto it.
Change root to the usb.

#### Example
--> wipefs -a /dev/sdb<br>
--> fdisk /dev/sdb<br>
--> mkfs.ext4 -O "^has_journal" /dev/sdb1<br>
--> mount /dev/sdb1 /mnt<br>
--> pacstrap base base-devel<br>
--> arch-chroot /mnt<br>

## Usage

Choose your version.
The script install_arch.sh will install the xfce4 desktop environment, the script install_arch_cmd.sh will leave you only with the command line.
The last option is especially useful for usb drives with small size.<br>
Make the install script executable and execute it. It will guide you through the installation.

--> chmod +x /root/install_arch.sh<br>
--> /root/install_arch.sh<br>
