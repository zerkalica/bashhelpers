#!/bin/sh

#Fix cyrilic characters in ubuntu 15.04, 15.10 console

sudo sed 's/CODESET=.*/CODESET="CyrSlav"/;
s/FONTFACE=.*/FONTFACE="VGA"/;
s/FONTSIZE=.*/FONTSIZE="16"/' -i /etc/default/console-setup


sudo setupcon --save
sudo cp /usr/share/consolefonts/CyrSlav-VGA16.psf.gz /etc/console-setup
sudo gunzip /etc/console-setup/CyrSlav-VGA16.psf.gz
sudo update-initramfs -u
