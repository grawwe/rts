#!/bin/bash
password="1234"
remote_server="egor@192.168.0.105:/home/egor/results"
local_dir="/home/lab2/results/*"
sshpass -p "$password" scp $local_dir "$remote_server"
echo "Файлы успешно перенесены на сервер!"
