#!/bin/bash

# Устанавливаем knockd
sudo apt update && sudo apt install -y knockd

# Настраиваем /etc/default/knockd
echo -e "START_KNOCKD=1\nKNOCKD_OPTS=\"-i enp0s3\"" | sudo tee /etc/default/knockd > /dev/null

# Создаем /etc/systemd/system/knockd.service
sudo tee /etc/systemd/system/knockd.service > /dev/null <<EOF
[Unit]
Description=Port-Knock Daemon
After=network.target
Requires=network.target
Documentation=man:knockd(1)

[Service]
EnvironmentFile=-/etc/default/knockd
ExecStartPre=/usr/bin/sleep 1
ExecStart=/usr/sbin/knockd $KNOCKD_OPTS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
Restart=always
SuccessExitStatus=0 2 15
ProtectSystem=full
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN

[Install]
WantedBy=multi-user.target
EOF

# Применяем изменения systemd
sudo systemctl daemon-reload
sudo systemctl enable knockd

# Копируем knockd.conf
SCRIPT_DIR="$(dirname "$0")"
sudo cp "$SCRIPT_DIR/knockd.conf" /etc/knockd.conf

# Запускаем knockd
sudo systemctl start knockd

echo "knockd установлен и запущен успешно!"

mv /home/egor/rts/lab2 /home/lab2

# Создаем новую директорию /home/lab2/results
mkdir -p /home/lab2/results

# Меняем владельца директории results на root
chown root:root /home/lab2/results

echo "Проект успешно загружен и настроен!"
