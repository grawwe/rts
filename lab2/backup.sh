#!/bin/bash 
backup_dir="/home/lab2/results"
mkdir -p $backup_dir
date_str=$(date +"%Y%m%d_%H%M%S")
tar -czf "$backup_dir/backup_$date_str.tar.gz" /etc/network
# Удаление старых бэкапов, оставляя только 10 последних
ls -t $backup_dir/backup_*.tar.gz | tail -n +11 | xargs rm -f
