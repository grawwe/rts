#!/bin/bash

LOG_FILE="/var/log/script.log"

check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "Ошибка: Скрипт требует права root." >&2
    exit 1
  fi
}

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

setup_network() {
  log "Настройка сетевых параметров..."
  cat > /etc/network/interfaces <<EOL
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

allow-hotplug enp0s3
iface enp0s3 inet dhcp

allow-hotplug enp0s8
iface enp0s8 inet static
  address 192.168.1.1
  netmask 255.255.255.0
  network 192.168.1.0
  dns-nameservers 77.88.8.1 8.8.8.8
EOL
  ifup enp0s8 &>> "$LOG_FILE"
}

install_packages() {
  log "Установка необходимых пакетов..."
  apt-get update 
  apt-get install -y iptables-persistent netfilter-persistent gcc bind9 bind9utils swaks isc-dhcp-server
}

configure_nat() {
  log "Настройка NAT..."
  iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
  iptables-save > /etc/iptables/rules.v4
  netfilter-persistent save &>> "$LOG_FILE"
}

enable_ip_forwarding() {
  log "Включение пересылки пакетов..."
  sysctl -w net.ipv4.ip_forward=1 &>> "$LOG_FILE"
  sysctl -p &>> "$LOG_FILE"
}

setup_dhcp_server() {
  log "Настройка DHCP-сервера..."
  cat > /etc/default/isc-dhcp-server <<EOL
INTERFACESv4="enp0s8"
INTERFACESv6=""
EOL
  
  cat > /etc/dhcp/dhcpd.conf <<EOL
option domain-name "WORKGROUP";
option domain-name-servers 8.8.8.8;
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.20;
    option broadcast-address 192.168.1.255;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8;
}
EOL
  
  systemctl restart isc-dhcp-server &>> "$LOG_FILE"
  systemctl enable isc-dhcp-server &>> "$LOG_FILE"
}

compile_and_run_c_program() {
  log "Компиляция и запуск программы на C..."
  local src_file="lab1.c"
  local bin_file="app"
  
  if [[ ! -f "$src_file" ]]; then
    log "Ошибка: Файл $src_file не найден!"
    exit 1
  fi
  
  gcc -o "$bin_file" "$src_file" &>> "$LOG_FILE"
  chmod +x "$bin_file"
  
  read -p "Введите первое число: " num1
  read -p "Введите второе число: " num2
  
  ./$bin_file "$num1" "$num2"
}

main() {
  log "=== Запуск скрипта ==="
  check_root
  setup_network
  install_packages
  configure_nat
  enable_ip_forwarding
  setup_dhcp_server
  compile_and_run_c_program
  log "=== Скрипт завершён ==="
}

main
