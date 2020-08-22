#!/bin/bash
processinfo=$(ps -ef | grep scrcpy | grep -v grep)
if [[ "$processinfo" != "" ]]; then
  awk '{print $2}' $processinfo | xargs sudo kill -9
fi
nohup /home/sorawingwind/.scrcpy/scrcpyd.sh > /home/sorawingwind/.scrcpy/daemon.log 2>&1 &
