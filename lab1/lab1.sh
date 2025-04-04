#!/bin/bash

LOG_FILE="/var/log/setup_script.log"

require_root() {
  [[ "$EUID" -ne 0 ]] && echo "Ошибка: Требуются права суперпользователя" && exit 1
}

log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

configure_network() {
  log_message "Конфигурируем сетевые интерфейсы..."
  cat > /etc/network/interfaces <<EOF
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
  address 192.168.1.1
  netmask 255.255.255.0
  network 192.168.1.0
  dns-nameservers 8.8.8.8 1.1.1.1
EOF
  ifup enp0s8 &>> "$LOG_FILE"
}

install_dependencies() {
  log_message "Устанавливаем требуемые пакеты..."
  apt update 
  apt install -y iptables-persistent netfilter-persistent gcc bind9 isc-dhcp-server 
}

setup_nat_rules() {
  log_message "Настраиваем NAT..."
  iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
  iptables-save > /etc/iptables/rules.v4
  netfilter-persistent save &>> "$LOG_FILE"
}

enable_packet_forwarding() {
  log_message "Включаем пересылку пакетов..."
  echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forwarding.conf
  sysctl --system &>> "$LOG_FILE"
}

configure_dhcp() {
  log_message "Настраиваем DHCP-сервер..."
  echo 'INTERFACESv4="enp0s8"' > /etc/default/isc-dhcp-server
  
  cat > /etc/dhcp/dhcpd.conf <<EOF
option domain-name "local";
option domain-name-servers 8.8.8.8;
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.50 192.168.1.100;
    option routers 192.168.1.1;
    option broadcast-address 192.168.1.255;
}
EOF
  
  systemctl restart isc-dhcp-server &>> "$LOG_FILE"
  systemctl enable isc-dhcp-server &>> "$LOG_FILE"
}

compile_c_program() {
  log_message "Компиляция и запуск программы..."
  SRC_FILE="lab1.c"
  OUT_FILE="program"
  
  [[ ! -f "$SRC_FILE" ]] && log_message "Ошибка: $SRC_FILE не найден" && exit 1
  
  gcc "$SRC_FILE" -o "$OUT_FILE" &>> "$LOG_FILE"
  chmod +x "$OUT_FILE"
  
  read -p "Введите число 1: " num1
  read -p "Введите число 2: " num2
  
  ./$OUT_FILE "$num1" "$num2"
}

main() {
  log_message "=== Запуск настройки ==="
  require_root
  configure_network
  install_dependencies
  setup_nat_rules
  enable_packet_forwarding
  configure_dhcp
  compile_c_program
  log_message "=== Настройка завершена ==="
}

main
