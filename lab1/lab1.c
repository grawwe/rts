#include <stdio.h>
#include <stdlib.h>
// Функция для вычисления факториала
unsigned long long factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
// Функция для вычисления суммы цифр числа
int sum_of_digits(int n) {
    int sum = 0;
    while (n > 0) {
        sum += n % 10;
        n /= 10;
    }
    return sum;
}
int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Использование: %s <число1> <число2>\n", argv[0]);
        return 1;
    }
    int num1 = atoi(argv[1]);
    int num2 = atoi(argv[2]);
    // Определяем максимум и минимум
    int max = (num1 > num2) ? num1 : num2;
    int min = (num1 < num2) ? num1 : num2;
    // Вычисляем факториал и сумму цифр
    unsigned long long fact = factorial(max);
    int sum = sum_of_digits(min);
    // Выводим результаты
    printf("Максимальное число: %d, минимальное число: %d\n", max, min);
    printf("Факториал %d: %llu\n", max, fact);
    printf("Сумма цифр %d: %d\n", min, sum);
    return 0;
}

