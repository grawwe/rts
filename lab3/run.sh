#!/usr/bin/expect -f

# === Параметры ===
set SFTP_HOST "192.168.0.105"         ;# IP-адрес удаленного хоста
set SFTP_USER "egor"               ;# Имя пользователя для подключения
set SFTP_PASS "1234"                  ;# Пароль пользователя для подключения
set REMOTE_DIR "/home/egor/"       ;# Директория на удаленном сервере
set LOCAL_FILE "/home/egor/sftp.txt"            ;# Путь к локальному файлу для загрузки

# === Проверка прав ===
if {[catch {exec whoami} result]} {
    puts "Этот скрипт нужно запускать с правами sudo!"
    exit 1
}

# === Подключение через SFTP ===
spawn sftp $SFTP_USER@$SFTP_HOST

# Ожидание запроса на ввод пароля
expect "password: "
send "$SFTP_PASS\r"

# Ожидание приглашения sftp
expect "sftp> "

# Загрузка файла на удаленный сервер
send "put $LOCAL_FILE $REMOTE_DIR\r"

# Завершение сессии
expect "sftp> "
send "exit\r"

# Завершение скрипта
expect eof
puts "Файл успешно загружен через SFTP!"
