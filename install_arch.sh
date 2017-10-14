#!/bin/bash

# Willkommensgruß, Erklärungen und Abfragen einer Bestätigung zum Ausführen
echo 'Willkommen zum Installations-Skript einer Grundkonfiguration eines Arch-Linux-Systems!'

# Lade das deutsche Tastaturlayout
loadkeys de-latin1

# Setze Uhrzeit und Sprache (Deutschland)
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
cp /root/preconfigured/locale.gen /etc/locale.gen
locale-gen
echo 'LANG=de_DE.UTF-8' > /etc/locale.conf
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf

echo 'Im folgenden wirst du nach ein paar Einstellungen gefragt.'
echo 'Doch zunächst stelle sicher, dass du...'
echo '...dich bereits um die Partitionierung gekümmert hast (nur eine Partition wird von diesem Skript unterstützt!).'
echo '...bereits das Paket base installiert hast.'
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

# Setze ein neues root Passwort
echo 'Bitte setze ein neues Passwort für root:'
passwd 

# Dem USB Stick evtl. ein neues Label geben...
echo 'Willst du dem Speichermedium ein Label geben? Ich empfehle es dir. (Ja)/(Nein):'
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
	
	echo 'Gib die Laufswerkbezeichnung des Speichermediums ein (Standard ist /dev/sdb):'
	read laufwerk
	if [ -z "${laufwerk}" ];
		then
		laufwerk="/dev/sdb"
	fi
	partition="${laufwerk}1$"

	echo 'Gib das neue Label für das Speichermedium ein:'
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
echo 'Setze nun das Passwort.'
echo 'Nimm anschließend die visudo Konfiguration vor.'
echo 'D.h. kommentiere die entsprechende Zeile aus, sodass Nutzer in der Gruppe wheel sudo ausführen dürfen.'
passwd $nutzername
# Manuelle Rechte Vergabe des neuen Nutzers
visudo

# Installiere ein paar Pakete
echo 'Es werden nun einige Pakete installiert.'
pacman -S git rsync mlocate bash-completion wireless_tools wpa_supplicant dialog lynx --noconfirm
updatedb
pacman -S ttf-dejavu alsa-utils xorg-server xorg-xinit xorg-twm xterm xorg-server-devel --noconfirm
pacman -S xf86-video-vesa xf86-video-ati xf86-video-intel xf86-video-nouveau --noconfirm
pacman -S dosfstools ntfs-3g gvfs --noconfirm
pacman -S xfce4 --noconfirm
pacman -S geany firefox --noconfirm

# mkinitcpio
echo 'Führe nochmals mkinitcpio aus...'
mkinitcpio -p linux

# Installiere GRUB2
echo 'Installiere GRUB2...'
pacman -S grub intel-ucode --noconfirm
grub-install --target=i386-pc --removable $laufwerk
cp /root/preconfigured/grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Richte xfce4 ein
echo 'Richte xfce4 ein...'
path_user_xinitrc="/home/${nutzername}/.xinitrc"
cp /root/preconfigured/xinitrc $path_user_xinitrc
chown $nutzername:$nutzername $path_user_xinitrc

# Abschließende Meldung
echo 'Herzlichen Glückwunsch zum mobilen Arch Linux mit dem xfce-Desktop!'
echo 'Starte einfach neu mit dem Befehl "reboot", logge dich mit dem neuen Benutzer ein und führe "startx" aus.'

