import subprocess
import sys
import os

# --- Настройки ---
# Укажи свои реальные данные для подключения к PostgreSQL
DB_HOST = "localhost"
DB_PORT = "5432" # Порт, который ты указал при установке
DB_NAME = "restaurant_network"
DB_USER = "postgres" # Имя пользователя, под которым будем подключаться (обычно postgres)
# ПАРОЛЬ НЕ УКАЗЫВАЕТСЯ В КОДЕ ДЛЯ БЕЗОПАСНОСТИ!
# Его нужно будет ввести при запуске скрипта или указать в переменной окружения PGPASSWORD

# --- Список SQL-файлов в нужном порядке ---
SQL_SCRIPTS = [
    "01_create_db.sql",
    "02_create_tables_and_indexes.sql",
    "03_insert_data.sql",
    "04_create_views.sql",
    "05_create_audit.sql",
    "06_create_encryption.sql",
    "07_create_roles_and_users.sql",
]

def run_sql_script(script_path, db_name):
    """Выполняет команды из SQL-файла с помощью psql."""
    # Команда psql
    # -h host -p port -U user -d database -f file
    # -v ON_ERROR_STOP=1 останавливает выполнение при ошибке
    cmd = [
        "psql",
        "-h", DB_HOST,
        "-p", DB_PORT,
        "-U", DB_USER,
        "-d", db_name,
        "-v", "ON_ERROR_STOP=1",
        "-f", script_path
    ]
    try:
        # subprocess.run выполнит команду в системной оболочке
        # check=True вызывает исключение, если psql вернёт ненулевой код возврата (ошибка)
        subprocess.run(cmd, check=True, shell=False)
        print(f"OK: {script_path}")
    except subprocess.CalledProcessError as e:
        print(f"ОШИБКА при выполнении {script_path}: {e}")
        sys.exit(1) # Завершаем скрипт с ошибкой
    except FileNotFoundError:
        print("Ошибка: psql не найден. Убедитесь, что PostgreSQL установлен и его bin-директория добавлена в PATH.")
        sys.exit(1)

def main():
    print("Начинаю настройку БД...")

    # 1. Выполнить скрипт создания БД (он использует дефолтную БД postgres)
    print("Создаю базу данных...")
    cmd_create_db = [
        "psql",
        "-h", DB_HOST,
        "-p", DB_PORT,
        "-U", DB_USER,
        "-d", "postgres", # Подключаемся к дефолтной БД postgres
        "-v", "ON_ERROR_STOP=1",
        "-f", "01_create_db.sql"
    ]
    try:
        subprocess.run(cmd_create_db, check=True, shell=False)
        print("OK: 01_create_db.sql")
    except subprocess.CalledProcessError as e:
        print(f"ОШИБКА при создании БД или БД уже существует: {e}")
        # Продолжаем, считая, что БД уже создана
        print("Продолжаю выполнение остальных скриптов...")

    # 2. Выполнить остальные скрипты в нужной БД
    for script in SQL_SCRIPTS[1:]: # Пропускаем 01_create_db.sql
        if not os.path.exists(script):
            print(f"Файл {script} не найден. Пропускаю.")
            continue
        print(f"Выполняю {script}...")
        run_sql_script(script, DB_NAME)

    print("Настройка БД завершена!")

if __name__ == "__main__":
    main()

