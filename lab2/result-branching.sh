#!/bin/bash
# Разбор аргументов
while getopts "e:" opt; do
  case $opt in
    e) expression="$OPTARG" ;;
    *) echo "Использование: $0 -e \"<выражение типа 5+5>\""; exit 1 ;;
  esac
done
# Проверка ввода
if [[ -z "$expression" ]]; then
  echo "Ошибка: Введите арифметическое выражение." > /home/lab2/results/result_branching.txt
  exit 1
fi
# Вычисление выражения
result=$(echo "$expression" | bc -l 2>/dev/null)
# Проверка на ошибку вычисления
if [[ -z "$result" ]]; then
  echo "Ошибка: Некорректное выражение." > /home/lab2/results/result_branching.txt
  exit 1
fi
# Запись в файл
echo "Результат вычисления $expression = $result" > /home/lab2/results/result_branching.txt
echo "Результат сохранен в /home/lab2/results/result_branching.txt"
