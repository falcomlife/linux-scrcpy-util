#!/bin/bash
ps -ef | grep scrcpy | grep -v grep | awk '{print $2}' | xargs -r sudo kill -9
nohup /home/sorawingwind/.scrcpy/scrcpyd.sh > /home/sorawingwind/.scrcpy/daemon.log 2>&1 &
