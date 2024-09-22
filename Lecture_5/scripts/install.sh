#!/bin/bash
#!/bin/bash

# Назва лог-файлу
LOG_FILE="/vagrant/install.log"

# Масив пакетів для встановлення
packages=(vim htop git)

# Встановлення пакетів
for package in "${packages[@]}"; do
    echo "Початок встановлення $package..." >> "$LOG_FILE"
    if ! command -v "$package" &> /dev/null; then
        sudo apt update >> "$LOG_FILE" 2>&1
        sudo apt install -y "$package" >> "$LOG_FILE" 2>&1
        echo "$package успішно встановлено." >> "$LOG_FILE"
    else
        echo "$package вже встановлено." >> "$LOG_FILE"
    fi

    # Виведення версії пакета (якщо можливо)
    case "$package" in
        vim)
            vim --version | head -n 1 >> "$LOG_FILE"
            ;;
        htop)
            htop --version >> "$LOG_FILE"
            ;;
        git)
            git --version >> "$LOG_FILE"
            ;;
        *)
            echo "Не знайдено команду для виведення версії $package" >> "$LOG_FILE"
            ;;
    esac