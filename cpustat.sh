#!/bin/sh

(while true; do date +'ts %s'; cat /proc/stat; sleep 1; done) | awk -f cpustat.awk
