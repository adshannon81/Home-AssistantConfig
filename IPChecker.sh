#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

DATE=`date '+%Y-%m-%d %H:%M:%S'` 
echo "-----------------------------------------" 
echo "| IP Checker - ${DATE} " 
echo "-----------------------------------------" 

restartHA="0"

echo "RM Kitchen"  
currentIP=$(</home/homeassistant/.homeassistant/IP/rmKitchenIP.txt)
echo ".$currentIP." 

sudo cp /home/homeassistant/.homeassistant/configuration.yaml /home/homeassistant/.homeassistant/configuration.yaml.backup
sudo cp /home/homeassistant/.homeassistant/scripts.yaml /home/homeassistant/.homeassistant/scripts.yaml.backup

newIP=`sudo nmap -sP --disable-arp-ping 192.168.1.0/24 >/dev/null && arp -an | grep 34:ea:34:58:a9:67 | awk '{print $2}' | sed 's/[()]//g'`
echo ".$newIP." 

if [[ "$newIP" != "" ]]; then
 if [[ "$newIP" == "$currentIP" ]]; then
  echo "equal" 
 else
  echo " not equal"
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/IP/rmKitchenIP.txt
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/configuration.yaml
  currentIP2=$( echo "$currentIP" | tr . _ )
  newIP2=$( echo "$newIP" | tr . _ )
  sudo sed -i -e "s/${currentIP2}/${newIP2}/g" /home/homeassistant/.homeassistant/scripts.yaml
  
  restartHA="1"
 fi
else
  echo "IP not found" 
fi



echo "RM Pro" 
currentIP=$(</home/homeassistant/.homeassistant/IP/rmProIP.txt)
echo ".$currentIP." 

newIP=`sudo nmap -sP --disable-arp-ping 192.168.1.0/24 >/dev/null && arp -an | grep b4:43:0d:fc:1e:71 | awk '{print $2}' | sed 's/[()]//g'`
echo ".$newIP." 
 
if [[ "$newIP"  != "" ]]; then 
 if [[ "$currentIP" == "$newIP" ]]; then
  echo "equal" 
 else 
  echo "not equal" 
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/IP/rmProIP.txt  
  sudo sed -i -e "s/${currentIP}/${newIP}/g" /home/homeassistant/.homeassistant/configuration.yaml
  currentIP2=$(echo "$currentIP" | tr . _ )
  newIP2=$(echo "$newIP" | tr . _ )
  sudo sed -i -e "s/${currentIP2}/${newIP2}/g" /home/homeassistant/.homeassistant/scripts.yaml
  restartHA=1
 fi
else
 echo "IP not found" 
fi


if [[ "$restartHA" == "1" ]]; then
 echo "restart = $restartHA" 
 sudo systemctl stop home-assistant@homeassistant
 sudo systemctl start home-assistant@homeassistant
else
 echo "Restart not required" 
fi
