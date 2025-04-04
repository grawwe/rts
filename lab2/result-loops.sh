#!/bin/bash
# Разбор аргументов
while getopts "n:" opt; do
  case $opt in
    n) number="$OPTARG" ;;
    *) echo "Использование: $0 -n <число>"; exit 1 ;;
  esac
done
# Проверка ввода
if ! [[ "$number" =~ ^[0-9]+$ ]] || [ "$number" -lt 2 ]; then
  echo "Ошибка: Введите целое число больше 1." > /home/lab2/results/result_loops.txt
  exit 1
fi
# Функция проверки простого числа
is_prime() {
  local num=$1
  for ((i = 2; i * i <= num; i++)); do
    if ((num % i == 0)); then
      return 1
    fi
  done
  return 0
}

# Вывод всех простых чисел до N
primes=""
for ((i = 2; i <= number; i++)); do
  if is_prime "$i"; then
    primes+="$i "
  fi
done
# Запись в файл
echo "Простые числа до $number: $primes" > /home/lab2/results/result_loops.txt
echo "Результат сохранен в /home/lab2/results/result_loops.txt"
