#!/bin/bash

DATE=`date '+%Y-%m-%d %H:%M:%S'` >>IPChecker.log
echo "-----------------------------------------" >> IPChecker.log
echo "| IP Checker - ${DATE} " >> IPChecker.log
echo "-----------------------------------------" >> IPChecker.log

restartHA="0"

echo "RM Kitchen"  >> IPChecker.log
currentIP=$(</home/homeassistant/.homeassistant/IP/rmKitchenIP.txt)
echo ".$currentIP." >> IPChecker.log

sudo cp /home/homeassistant/.homeassistant/configuration.yaml /home/homeassistant/.homeassistant/configuration.yaml.backup
sudo cp /home/homeassistant/.homeassistant/scripts.yaml /home/homeassistant/.homeassistant/scripts.yaml.backup

newIP=`sudo nmap -sP --disable-arp-ping 192.168.1.0/24 >/dev/null && arp -an | grep 34:ea:34:58:a9:67 | awk '{print $2}' | sed 's/[()]//g'`
echo ".$newIP." >> IPChecker.log

if [[ "$newIP" != "" ]]; then
 if [[ "$newIP" == "$currentIP" ]]; then
  echo "equal" >> IPChecker.log
 else
  echo " not equal" >> IPChecker.log
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/IP/rmKitchenIP.txt
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/configuration.yaml
  currentIP2=$( echo "$currentIP" | tr . _ )
  newIP2=$( echo "$newIP" | tr . _ )
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/scripts.yaml
  
  restartHA="1"
 fi
else
  echo "IP not found" >> IPChecker.log
fi



echo "RM Pro" >> IPChecker.log
currentIP=$(</home/homeassistant/.homeassistant/IP/rmProIP.txt)
echo ".$currentIP." >> IPChecker.log

newIP=`sudo nmap -sP --disable-arp-ping 192.168.1.0/24 >/dev/null && arp -an | grep b4:43:0d:fc:1e:71 | awk '{print $2}' | sed 's/[()]//g'`
echo ".$newIP." >> IPChecker.log
 
if [[ "$newIP"  != "" ]]; then 
 if [[ "$currentIP" == "$newIP" ]]; then
  echo "equal" >> IPChecker.log
 else 
  echo "not equal" >> IPChecker.log
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/IP/rmProIP.txt  
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/configuration.yaml
  currentIP2=$(echo "$currentIP" | tr . _ )
  newIP2=$(echo "$newIP" | tr . _ )
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/scripts.yaml
  restartHA=1
 fi
else
 echo "IP not found" >> IPChecker.log
fi


if [[ "$restartHA" == "1" ]]; then
 echo "restart = $restartHA" >> IPChecker.log
 sudo systemctl stop home-assistant@homeassistant
 sudo systemctl start home-assistant@homeassistant
else
 echo "Restart not required" >> IPChecker.log
fi
