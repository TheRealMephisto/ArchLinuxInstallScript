#!/bin/bash

# Willkommensgruß, Erklärungen und Abfragen einer Bestätigung zum Ausführen
echo 'Willkommen zum Installations-Skript eines einfach Arch-Linux-Systems für USB-Sticks!'
echo 'Es wird vorausgesetzt, dass du bereits den folgenden Befehl (vor dem Wechsel auf den Stick mithilfe von arch-chroot) ausgeführt hast:'
echo '	pacstrap /PfadZumUSBStick base base-devel vim'
echo 'Stelle sicher, dass du...'
echo '...root bist.'
echo '...Zugriff zum Internet hast.'
echo 'Kann es losgehen? (Ja)/(Nein)'
while read inputline
do
	antwort="$inputline"
	if [ $antwort == "Nein" ];
		then
		exit 0
	fi
	if [ $antwort == "Ja" ];
		then
		break;
	fi
	echo 'Das ist eine Ja-Nein-Frage!'
done


# Lade das deutsche Tastaturlayout
loadkeys de-latin1
echo 'Soeben wurde das folgende Tastaturlayout geladen: de-latin1'

# Setze Uhrzeit und Sprache (Deutschland)
echo 'Uhrzeit und Sprache werden nun passend zu Deutschland gesetzt'
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
cp /root/preconfigured/locale.gen /etc/locale.gen
locale-gen
echo 'LANG=de_DE.UTF-8' > /etc/locale.conf
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf

# Setze ein neues root Passwort
echo 'Bitte setze ein neues Passwort für root:'
passwd 

# Dem USB Stick evtl. ein neues Label geben...
echo 'Willst du dem USB Stick ein Label geben? Ich empfehle es dir. (Ja)/(Nein):'
while read inputline
do
	antwort="$inputline"
	if [ $antwort == "Nein" ] || [ $antwort == "Ja" ];
		then
		break;
	fi
	echo 'Das ist eine Ja-Nein-Frage!'
done

# Wenn mit "Ja" geantwortet wurde, führe den folgenden Abschnitt aus.
# Wenn mit "Nein" geantwortet wurde, überspringe ihn.
if [ $antwort == "Ja" ];
	then
	
	echo 'Gib die Partition des USB Sticks ein (Standard ist /dev/sdb1):'
	read partition
	if [ -z "${partition}" ];
		then
		partition="/dev/sdb1"
	fi

	echo 'Gib das neue Label für den USB Stick ein:'
	while read inputline
	do
		label="$inputline"
		if ! [ -z "${label}" ];
			then
			break;
		fi
	done
	e2label $partition $label
fi

# Lege den Hostnamen des Systems fest
echo 'Gib den Hostnamen des Systems ein:'
read neuer_hostname
echo $neuer_hostname > /etc/hostname

# Lege den neuen Administrator User an
echo 'Nun wird ein neuer User angelegt, welcher später anstelle von root benutzt werden soll.'
echo 'Gib nun seinen Namen ein: '
read nutzername
useradd -m -g users -G wheel -s /bin/bash $nutzername
echo 'Setze das Passwort: '
passwd $nutzername

# Manuelle Rechte Vergabe des neuen Nutzers
echo 'Nimm die visudo Konfiguration vor.'
echo 'D.h. kommentiere die entsprechende Zeile aus, sodass Nutzer in der Gruppe wheel sudo ausführen dürfen.'
visudo

# Installiere ein paar Pakete
echo 'Es werden nun einige Pakete installiert.'
pacman -S git rsync mlocate bash-completion wireless_tools wpa_supplicant dialog --noconfirm
updatedb
#pacman -S ttf-dejavu alsa-utils xorg-server xorg-xinit xorg-twm xterm xorg-server-devel --noconfirm
#pacman -S xf86-video-vesa xf86-video-ati xf86-video-intel xf86-video-nouveau --noconfirm
#pacman -S networkmanager network-manager-applet --noconfirm
pacman -S dosfstools ntfs-3g gvfs --noconfirm
#systemctl enable NetworkManager
#pacman -S xfce4 --noconfirm

# mkinitcpio
echo 'Führe nochmals mkinitcpio aus...'
mkinitcpio -p linux

# Installiere GRUB2
echo 'Installiere GRUB2...'
pacman -S grub --noconfirm
echo 'Gib nochmal das Laufwerk ein (Standard /dev/sdb):'
read laufwerk
	if [ -z "${laufwerk}" ];
		then
		laufwerk="/dev/sdb"
	fi
grub-install --target=i386-pc --removable $laufwerk
cp /root/preconfigured/grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Richte xfce4 ein
#path_user_xinitrc="/home/${nutzername}/.xinitrc"
#cp /root/preconfigured/xinitrc $path_user_xinitrc

# Abschließende Meldung
echo 'Herzlichen Glückwunsch zum mobilen Arch Linux!'
echo 'Starte einfach neu mit dem Befehl "reboot" und logge dich mit dem neuen Benutzer ein.'

