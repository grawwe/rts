#!/bin/bash
# Разбор аргументов
while getopts "n:" opt; do
  case $opt in
    n) number="$OPTARG" ;;
    *) echo "Использование: $0 -n <число>"; exit 1 ;;
  esac
done
# Проверка ввода
if ! [[ "$number" =~ ^[0-9]+$ ]]; then
  echo "Ошибка: Введите неотрицательное целое число." > /home/lab2/results/result_functions.txt
  exit 1
fi
# Функция конвертации в 16-ричную систему
to_hex() {
  printf "%X\n" "$1"
}
# Конвертация и запись в файл
hex_value=$(to_hex "$number")
echo "Число $number в шестнадцатеричной системе: $hex_value" > /home/lab2/results/result_functions.txt
echo "Результат сохранен в /home/lab2/results/result_functions.txt"
