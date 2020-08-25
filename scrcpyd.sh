#!/bin/bash
version=""
mac=""
ip=""
connect=false
display=false
while true
do
  echo "start" >> /home/sorawingwind/.scrcpy/daemon.log
  sleep 10s


  # update ip tables in network
  mac=`cat /home/sorawingwind/.scrcpy/phone | grep mac | awk -F = '{print $2}'`
  netenvironmenttmp=$(ifconfig | grep wlp3s0 -A 7 | grep inet | grep -v inet6 | awk -v OFS="/" '{print $2,$4}')
  netenvironment=$(netmask $netenvironmenttmp)
  echo "scan phone ip in $netenvironment" >> /home/sorawingwind/.scrcpy/daemon.log


  # get the phone ip in net
  ip=$(sudo nmap --max-retries=0 -p 8888 -sA $netenvironment | grep $mac -B 5 | egrep -o '[0-9]+.[0-9]+.[0-9]+.[0-9]+')
  if [[ "$ip" != "" ]] ; then
    echo "get phone ip successed: $ip" >> /home/sorawingwind/.scrcpy/daemon.log
  else
    echo "get phone ip fail" >> /home/sorawingwind/.scrcpy/daemon.log
    echo "end" >> /home/sorawingwind/.scrcpy/daemon.log
    continue
  fi
  device=`adb devices | grep 8888`
  displaycount=$(ps -ef | grep scrcpy | grep -v scrcpyd | grep -v grep | wc -l)

  
  # if there isnot scrcpy process execute, start a new connect to phone
  if [[ "$device" = "" && $displaycount < 1 ]] ; then
    echo "no device is connected, and no scrcpy process running" >> /home/sorawingwind/.scrcpy/daemon.log
    display=false
  elif [[ "$device" != "" && $displaycount < 1 ]] ; then
    echo "device is connected, but no scrcpy process running" >> /home/sorawingwind/.scrcpy/daemon.log
    display=false
  fi
  # if there is scrcpy process execute, enter next turn
  if [ $display = true ] ; then 
    echo "device "$device" is already connected" >> /home/sorawingwind/.scrcpy/daemon.log
    continue
  fi


  # connect to phone
  echo "ready to run command adb connect $ip:8888" >> /home/sorawingwind/.scrcpy/daemon.log
  if [ "$device" != "" ] ; then
    connect=true
  else
    adb start-server
    # use adb util connect to phone
    result=`adb connect $ip:8888 | grep connected | wc -l`
    if [ $result -eq 1 ] ; then
      echo "adb connect successed" >> /home/sorawingwind/.scrcpy/daemon.log
      connect=true
    fi
  fi
  # open scrcpy 
  echo "ready to connect scrcpy" >> /home/sorawingwind/.scrcpy/daemon.log
  if [ $connect = true ] ; then
    nohup scrcpy --bit-rate 2M --max-size 800 --window-x 1550 --window-y 250 --window-borderless >> /home/sorawingwind/.scrcpy/daemon.log 2>&1 &
    display=true
    connect=false
  fi
  end:
  echo "end" >> /home/sorawingwind/.scrcpy/daemon.log
done

