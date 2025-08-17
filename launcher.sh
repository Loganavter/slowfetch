#!/bin/bash

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CONFIG_DIR="$HOME/.config/fastfetch"
INSTALLED_FLAG="${CONFIG_DIR}/.installed"

CONFIG_FILE_NAME="config.jsonc"
SCRIPTS_DIR_NAME="scripts"
CONFIG_BACKUP_FILE_NAME="config.jsonc.bak"
DEFAULT_CONFIG_FILE_NAME="config.default.jsonc"
SUDOERS_FILE="/etc/sudoers.d/99-fastfetch-smartctl-permissions"
LAUNCHER_NAME="launcher.sh"

RESET='\033[0m'
BOLD='\033[1m'
FG_RED='\033[0;31m'
FG_GREEN='\033[0;32m'
FG_YELLOW='\033[0;33m'
FG_BLUE='\033[0;34m'

LANGUAGE="en"
if [[ "${LANG}" == "ru"* ]]; then
    LANGUAGE="ru"
fi

if [ "$LANGUAGE" = "ru" ]; then
    L_ERROR_PREFIX="Ошибка:"
    L_SUCCESS_PREFIX="Успех!"
    L_INFO_CANCEL="Отмена."
    L_ERROR_INVALID_CHOICE="Неверный выбор!"
    L_INFO_PRESS_ENTER="Нажмите Enter для продолжения..."

    L_INSTALL_WELCOME="${FG_BLUE}${BOLD}--- Добро пожаловать в конфигуратор slowfetch! ---${RESET}"
    L_INSTALL_FIRST_RUN="Обнаружен первый запуск. Сейчас мы настроим окружение для Fastfetch."
    L_INSTALL_DEP_CHECK="${FG_YELLOW}Шаг 1/4: Проверка зависимостей...${RESET}"
    L_INSTALL_ALIAS_SETUP="${FG_YELLOW}Шаг 2/4: Настройка основного alias'а 'slowfetch'...${RESET}"
    L_INSTALL_PERFORMING="${FG_YELLOW}Шаг 3/4: Установка файлов в ${BOLD}${CONFIG_DIR}${RESET}...${RESET}"
    L_INSTALL_BACKING_UP="Существующая конфигурация в ${CONFIG_DIR} будет перемещена в бэкап."
    L_INSTALL_CONFIG_ALIAS="${FG_YELLOW}Шаг 4/4: Создание alias'а для запуска конфигуратора...${RESET}"
    L_INSTALL_COMPLETE_HEADER="${FG_GREEN}${BOLD}--- Установка завершена! ---${RESET}"
    L_INSTALL_COMPLETE_BODY="Все файлы были установлены. Вы можете безопасно удалить исходную папку, откуда вы запустили скрипт."
    L_INSTALL_COMPLETE_ALIAS_SLOWFETCH="Для запуска Fastfetch используйте команду '${BOLD}slowfetch${RESET}'."
    L_INSTALL_COMPLETE_ALIAS_CONFIG="Для повторного запуска этого конфигуратора используйте команду '${BOLD}slowfetch-config${RESET}'."
    L_INSTALL_RESTARTING="Перезапускаем конфигуратор из нового местоположения..."
    L_PROMPT_CONTINUE_OR_EXIT="\nНажмите Enter для продолжения установки или введите 'exit' для выхода: "
    L_PROMPT_ALIAS_OPTION="Выберите опцию [1-4]: "
    L_PROMPT_RELOAD_SHELL="\n${BOLD}Запустить новую сессию оболочки, чтобы применить изменения сейчас? (y/N):${RESET} "
    L_INFO_RELOADING_SHELL="Запускаем новую сессию оболочки..."

    L_UNINSTALL_CONFIRM="Вы уверены, что хотите ${FG_RED}ПОЛНОСТЬЮ удалить${RESET} slowfetch? (y/N) "
    L_UNINSTALL_WARNING="Это действие удалит алиасы, правило sudoers и все конфигурационные файлы из ${CONFIG_DIR}."
    L_UNINSTALL_STARTED="${FG_YELLOW}Начинаем удаление...${RESET}"
    L_UNINSTALL_SUDOERS="Удаление правила sudoers..."
    L_UNINSTALL_ALIASES="Удаление алиасов из конфигов оболочки..."
    L_UNINSTALL_FILES="Удаление файлов проекта Fastfetch..."
    L_UNINSTALL_RESTORE="Восстановление из бэкапа..."
    L_UNINSTALL_NO_BACKUP="Бэкап не найден, просто удаляем."
    L_UNINSTALL_COMPLETE="${FG_GREEN}Удаление завершено.${RESET} Восстановлен предыдущий конфиг (если он был)."
    L_UNINSTALL_GOODBYE="Прощайте!"

    L_INFO_SAVING="Сохранение изменений..."
    L_INFO_BACKUP_SAVED_TO="Ваша предыдущая конфигурация сохранена в: ${BOLD}${user_backup_file}${RESET}"
    L_INFO_DEPENDENCIES_WARNING_HEADER="${FG_RED}${BOLD}Внимание:${RESET}${FG_RED} Не найдены следующие зависимости для используемых скриптов Fastfetch:${RESET}"
    L_INFO_DEPENDENCIES_WARNING_FOOTER="Некоторые модули могут не работать или вызывать ошибки при запуске Fastfetch."
    L_INFO_EXITING="Выход."
    L_INFO_EXITING_NO_SAVE="Выход без сохранения."
    L_INFO_MODULES_HEADER="--- Текущие модули в конфигурации ---"
    L_INFO_SEPARATOR="--- разделитель ---"
    L_INFO_MOVING_MODULE="Перемещаем модуль: ${BOLD}${module_name}${RESET}"
    L_INFO_MODULE_ALREADY_TOP="Модуль уже наверху!"
    L_INFO_MODULE_ALREADY_BOTTOM="Модуль уже внизу!"
    L_PROMPT_MOVE_MODULE_NUM="Введите номер модуля для перемещения: "
    L_PROMPT_MOVE_MODULE_DIR="Переместить вверх (u) или вниз (d)? "
    L_SUCCESS_MODULE_MOVED="Модуль успешно перемещен!"
    L_PROMPT_REMOVE_MODULE_NUM="Введите номер модуля для удаления: "
    L_PROMPT_REMOVE_MODULE_CONFIRM="Вы уверены, что хотите удалить этот модуль? (y/N) "
    L_SUCCESS_MODULE_REMOVED="Модуль успешно удален!"
    L_PROMPT_ADD_MODULE_KEY="Введите ключ для модуля (или Enter для пропуска): "
    L_PROMPT_ADD_MODULE_POS="Введите позицию для вставки (или Enter для добавления в конец): "
    L_SUCCESS_MODULE_ADDED="Модуль успешно добавлен!"
    L_INFO_ADD_MODULE_HEADER="--- Добавление кастомного модуля ---"
    L_INFO_NO_FREE_SCRIPTS="Свободных скриптов для добавления не найдено."
    L_INFO_ADD_MODULE_SELECT_SCRIPT="Выберите скрипт для добавления:"
    L_INFO_ADD_MODULE_CANCEL_OPTION="--[ Отмена ]--"
    L_INFO_ADD_MODULE_INVALID_CHOICE="Неверный выбор. Попробуйте еще раз."
    L_INFO_ADD_MODULE_CANCELED="Добавление отменено."
    L_INFO_ADD_MODULE_CHOOSE_POS="--- Выберите место для нового модуля ---"
    L_INFO_CONFIGURE_MODULES_HEADER="--- Настройка модулей ---"
    L_PROMPT_CONFIGURE_MODULE="Выберите модуль для настройки [1-3]: "
    L_INFO_CONFIGURE_GH_STARS="Настроить модуль ${BOLD}Github Stars${RESET}"
    L_INFO_CONFIGURE_NEWS_SOURCE="Настроить ${BOLD}Источник новостей${RESET}"
    L_INFO_CONFIGURE_CURRENCY_RATE="Настроить ${BOLD}Валютные курсы${RESET}"
    L_INFO_FETCHING_REPOS="Получение списка репозиториев..."
    L_INFO_GH_NO_REPOS="Не удалось найти репозитории для '$username'."
    L_INFO_GH_SELECT_REPOS="Выберите репозитории (${BOLD}пробел${RESET} - выбрать, ${BOLD}enter${RESET} - подтвердить)."
    L_INFO_DIALOG_NOT_FOUND="(Утилита 'dialog' не найдена, используется упрощенный выбор)"
    L_INFO_GH_NO_REPOS_SELECTED="Не выбрано ни одного репозитория. Отмена."
    L_INFO_GH_CLEAR_CACHE_HINT="Для немедленного обновления очистите кэш: ${BOLD}rm ~/.cache/fastfetch/github_stars.cache${RESET}"
    L_PROMPT_GH_LOGIN_NOW="Войти в GitHub сейчас? (y/N): "
    L_ERROR_GH_LOGIN_FAILED="Не удалось войти в GitHub."
    L_PROMPT_GH_USERNAME="Введите имя пользователя GitHub: "
    L_PROMPT_GH_TRACK_REPO="Отслеживать репозиторий '$repo'? (y/N): "
    L_ERROR_SCRIPT_NOT_FOUND="Скрипт не найден."
    L_ERROR_GH_CLI_REQUIRED="Требуется GitHub CLI (gh). Установите его для настройки модуля."
    L_SUCCESS_GH_STARS_CONFIGURED="Модуль GitHub Stars настроен!"
    L_INFO_CONFIGURE_NEWS_HEADER="--- Настройка источника новостей ---"
    L_INFO_NEWS_SELECT_SOURCE="Выберите новый источник новостей:"
    L_PROMPT_NEWS_SOURCE="Выберите источник [1-4]: "
    L_INFO_NEWS_SOURCE_1="OpenNet.ru (RU)"
    L_INFO_NEWS_SOURCE_2="Phoronix (EN)"
    L_INFO_NEWS_SOURCE_3="LWN.net (EN)"
    L_INFO_NEWS_SOURCE_4="Отмена"
    L_SUCCESS_NEWS_SOURCE_SAVED="Источник новостей сохранен!"
    L_INFO_NEWS_CHANGES_APPLIED="Изменения применятся при следующем запуске fastfetch."
    L_PROMPT_NEWS_SOURCE="Выберите источник [1-4]: "
    L_INFO_CONFIGURE_CURRENCY_HEADER="--- Настройка модуля валютных курсов ---"
    L_INFO_CURRENCY_SELECT_SOURCE="Выберите источник валютных курсов:"
    L_INFO_CURRENCY_SOURCE_1="Центральный Банк России (CBR)"
    L_INFO_CURRENCY_SOURCE_2="Европейский Центральный Банк (ECB)"
    L_INFO_CURRENCY_PROMPT_CBR="Введите код валюты (например, USD, EUR, CNY): "
    L_INFO_CURRENCY_PROMPT_ECB_FROM="Введите исходную валюту (например, USD): "
    L_INFO_CURRENCY_PROMPT_ECB_TO="Введите целевую валюту (например, EUR): "
    L_SUCCESS_CURRENCY_CONFIGURED="Настройки валютных курсов сохранены!"
    L_INFO_CONFIGURING_SUDOERS="\n${BOLD}Настройка беспарольного sudo для smartctl...${RESET}"
    L_INFO_SMARTCTL_NOT_FOUND="Ошибка: Утилита 'smartctl' не найдена. Установите 'smartmontools'."
    L_INFO_SUDOERS_DESC_1="Будет создана запись в sudoers, чтобы разрешить выполнение"
    L_INFO_SUDOERS_DESC_2="команды '${BOLD}smartctl -i ...${RESET}' без пароля для пользователя '${BOLD}$current_user${RESET}'."
    L_INFO_SUDOERS_DESC_3="Это будет сделано путем создания файла: ${BOLD}$SUDOERS_FILE${RESET}"
    L_INFO_SUDOERS_DESC_4="\nДля этого потребуется ваш пароль sudo один раз."
    L_INFO_SUDOERS_WORKS_NOW="Теперь скрипт disk_info.sh будет работать без запроса пароля."
    L_SUCCESS_SUDOERS_CREATED="Правило sudoers успешно создано!"
    L_ERROR_SUDOERS_FAILED="Не удалось создать правило sudoers."
    L_ERROR_SUDO_FAILED="Не удалось получить права sudo."
    L_PROMPT_RESET_CONFIRM="Вы уверены, что хотите сбросить конфигурацию к начальной? (y/N) "
    L_SUCCESS_CONFIG_RESET="Конфигурация сброшена к начальной!"
    L_ERROR_CONFIG_NOT_FOUND="Файл конфигурации не найден."
    L_ERROR_DEFAULT_CONFIG_NOT_FOUND="Файл конфигурации по умолчанию не найден."
    L_SUCCESS_CONFIG_SAVED="Конфигурация сохранена!"
    L_ERROR_JQ_NOT_FOUND="Утилита 'jq' не найдена."
    L_ERROR_JQ_INSTALL_HINT="Установите 'jq' для работы с JSON файлами."
    L_INFO_CREATING_ALIAS_HEADER="--- Создание Alias '${alias_name}' ---"
    L_INFO_ALIAS_CONFIG_CREATED="Создаем файл конфигурации: $config_file"
    L_INFO_ALIAS_APPLY_HINT="\nЧтобы изменения вступили в силу, выполните:"
    L_INFO_ALIAS_RESTART_HINT="Или просто перезапустите ваш терминал."
    L_INFO_ALIAS_DISK_INFO_DETECTED="Обнаружен модуль 'disk_info.sh', который использует 'smartctl'."
    L_INFO_ALIAS_SUDO_REQUIRED="Для работы 'smartctl' требуются права суперпользователя (sudo)."
    L_INFO_ALIAS_QUESTION="\n${BOLD}Как вы хотите решить эту проблему?${RESET}"
    L_INFO_ALIAS_OPTION_1_DESC="Настроить sudoers для беспарольного запуска ${BOLD}одной команды smartctl${RESET} (${BOLD}рекомендуемый, наиболее безопасный способ${RESET})."
    L_INFO_ALIAS_OPTION_1_PRINCIPLE="- ${BOLD}Принцип:${RESET} Дать минимально необходимые права только для чтения информации о диске."
    L_INFO_ALIAS_OPTION_1_RISK="- ${BOLD}Риск:${RESET} Минимальный. fastfetch и все остальные скрипты останутся от обычного пользователя."
    L_INFO_ALIAS_OPTION_2_DESC="Создать alias, который запускает ${BOLD}весь fastfetch через sudo${RESET} (${BOLD}не рекомендуется${RESET})."
    L_INFO_ALIAS_OPTION_2_EXAMPLE="- Alias будет выглядеть так: 'sudo fastfetch --logo none'."
    L_INFO_ALIAS_OPTION_2_RISK="- ${BOLD}Риск:${RESET} ${FG_RED}Высокий.${RESET} Все скрипты, включая те, что скачивают данные из сети, будут запущены от имени root."
    L_INFO_ALIAS_OPTION_3_DESC="Создать обычный alias (вы будете вводить 'sudo slowfetch' вручную)."
    L_INFO_ALIAS_OPTION_3_HINT="- Простой вариант, если вы не хотите менять настройки системы и готовы вводить пароль."
    L_INFO_ALIAS_OPTION_4="Отмена."
    L_INFO_ALIAS_SUDOERS_FAILED="Настройка sudoers не удалась. Создание alias отменено."
    L_INFO_ALIAS_SUDO_REMOVED="Из скрипта '${BOLD}disk_info.sh${RESET}' убрано 'sudo' для smartctl."
    L_SUCCESS_ALIAS_CREATED="Alias успешно создан!"
    L_ERROR_SHELL_NOT_SUPPORTED="Ваша оболочка не поддерживается. Поддерживаются только bash и zsh."
    L_ERROR_INVALID_INPUT="Неверный ввод!"
    L_ERROR_INVALID_MODULE_NUM="Неверный номер модуля!"
    L_ERROR_INVALID_DIRECTION="Неверное направление!"

    L_MAIN_MENU_TITLE="${BOLD}--- Конфигуратор Fastfetch ---${RESET}"
    L_MAIN_MENU_1="Показать/обновить список модулей"
    L_MAIN_MENU_2="Переместить модуль"
    L_MAIN_MENU_3="Удалить модуль"
    L_MAIN_MENU_4="Добавить модуль"
    L_MAIN_MENU_5="Настроить модуль"
    L_MAIN_MENU_R="Сбросить конфигурацию к начальной"
    L_MAIN_MENU_A="Перенастроить alias 'slowfetch'"
    L_MAIN_MENU_U="${FG_RED}u. Удалить slowfetch${RESET}"
    L_MAIN_MENU_S="${FG_GREEN}s. Сохранить изменения и выйти${RESET}"
    L_MAIN_MENU_Q="${FG_RED}q. Выйти БЕЗ сохранения${RESET}"
    L_PROMPT_CHOOSE_ACTION="Выберите действие: "
else
    L_ERROR_PREFIX="Error:"
    L_SUCCESS_PREFIX="Success!"
    L_INFO_CANCEL="Canceled."
    L_ERROR_INVALID_CHOICE="Invalid choice!"
    L_INFO_PRESS_ENTER="Press Enter to continue..."

    L_INSTALL_WELCOME="${FG_BLUE}${BOLD}--- Welcome to the slowfetch configurator! ---${RESET}"
    L_INSTALL_FIRST_RUN="First run detected. We will now set up the environment for Fastfetch."
    L_INSTALL_DEP_CHECK="${FG_YELLOW}Step 1/4: Checking dependencies...${RESET}"
    L_INSTALL_ALIAS_SETUP="${FG_YELLOW}Step 2/4: Setting up the main 'slowfetch' alias...${RESET}"
    L_INSTALL_PERFORMING="${FG_YELLOW}Step 3/4: Installing files to ${BOLD}${CONFIG_DIR}${RESET}...${RESET}"
    L_INSTALL_BACKING_UP="Existing configuration in ${CONFIG_DIR} will be backed up."
    L_INSTALL_CONFIG_ALIAS="${FG_YELLOW}Step 4/4: Creating an alias for the configurator...${RESET}"
    L_INSTALL_COMPLETE_HEADER="${FG_GREEN}${BOLD}--- Installation Complete! ---${RESET}"
    L_INSTALL_COMPLETE_BODY="All files have been installed. You can now safely delete the original folder you ran this script from."
    L_INSTALL_COMPLETE_ALIAS_SLOWFETCH="Use the '${BOLD}slowfetch${RESET}' command to run Fastfetch."
    L_INSTALL_COMPLETE_ALIAS_CONFIG="Use the '${BOLD}slowfetch-config${RESET}' command to run this configurator again."
    L_INSTALL_RESTARTING="Restarting the configurator from the new location..."
    L_PROMPT_CONTINUE_OR_EXIT="\nPress Enter to continue with the installation, or type 'exit' to quit: "
    L_PROMPT_ALIAS_OPTION="Select an option [1-4]: "
    L_PROMPT_RELOAD_SHELL="\n${BOLD}Start a new shell session to apply the changes now? (y/N):${RESET} " 
    L_INFO_RELOADING_SHELL="Starting new shell session..."                                             

    L_UNINSTALL_CONFIRM="Are you sure you want to ${FG_RED}COMPLETELY uninstall${RESET} slowfetch? (y/N) "
    L_UNINSTALL_WARNING="This will remove aliases, the sudoers rule, and all configuration files from ${CONFIG_DIR}."
    L_UNINSTALL_STARTED="${FG_YELLOW}Starting uninstallation...${RESET}"
    L_UNINSTALL_SUDOERS="Removing sudoers rule..."
    L_UNINSTALL_ALIASES="Removing aliases from shell configs..."
    L_UNINSTALL_FILES="Removing Fastfetch project files..."
    L_UNINSTALL_RESTORE="Restoring from backup..."
    L_UNINSTALL_NO_BACKUP="No backup found, proceeding with deletion."
    L_UNINSTALL_COMPLETE="${FG_GREEN}Uninstallation complete.${RESET} Your previous config (if any) has been restored."
    L_UNINSTALL_GOODBYE="Goodbye!"

    L_INFO_SAVING="Saving changes..."
    L_INFO_BACKUP_SAVED_TO="Your previous configuration has been saved to: ${BOLD}${user_backup_file}${RESET}"
    L_INFO_DEPENDENCIES_WARNING_HEADER="${FG_RED}${BOLD}Warning:${RESET}${FG_RED} The following dependencies for the used Fastfetch scripts were not found:${RESET}"
    L_INFO_DEPENDENCIES_WARNING_FOOTER="Some modules may not work or may cause errors when running Fastfetch."
    L_INFO_EXITING="Exiting."
    L_INFO_EXITING_NO_SAVE="Exiting without saving."
    L_INFO_MODULES_HEADER="--- Current modules in configuration ---"
    L_INFO_SEPARATOR="--- separator ---"
    L_INFO_MOVING_MODULE="Moving module: ${BOLD}${module_name}${RESET}"
    L_INFO_MODULE_ALREADY_TOP="Module is already at the top!"
    L_INFO_MODULE_ALREADY_BOTTOM="Module is already at the bottom!"
    L_PROMPT_MOVE_MODULE_NUM="Enter module number to move: "
    L_PROMPT_MOVE_MODULE_DIR="Move up (u) or down (d)? "
    L_SUCCESS_MODULE_MOVED="Module moved successfully!"
    L_PROMPT_REMOVE_MODULE_NUM="Enter module number to remove: "
    L_PROMPT_REMOVE_MODULE_CONFIRM="Are you sure you want to remove this module? (y/N) "
    L_SUCCESS_MODULE_REMOVED="Module removed successfully!"
    L_PROMPT_ADD_MODULE_KEY="Enter key for module (or Enter to skip): "
    L_PROMPT_ADD_MODULE_POS="Enter position for insertion (or Enter to add at the end): "
    L_SUCCESS_MODULE_ADDED="Module added successfully!"
    L_INFO_ADD_MODULE_HEADER="--- Add Custom Module ---"
    L_INFO_NO_FREE_SCRIPTS="No available scripts to add were found."
    L_INFO_ADD_MODULE_SELECT_SCRIPT="Select a script to add:"
    L_INFO_ADD_MODULE_CANCEL_OPTION="--[ Cancel ]--"
    L_INFO_ADD_MODULE_INVALID_CHOICE="Invalid choice. Please try again."
    L_INFO_ADD_MODULE_CANCELED="Addition canceled."
    L_INFO_ADD_MODULE_CHOOSE_POS="--- Choose a position for the new module ---"
    L_INFO_CONFIGURE_MODULES_HEADER="--- Configure Modules ---"
    L_PROMPT_CONFIGURE_MODULE="Select module to configure [1-3]: "
    L_INFO_CONFIGURE_GH_STARS="Configure ${BOLD}Github Stars${RESET} module"
    L_INFO_CONFIGURE_NEWS_SOURCE="Configure ${BOLD}News Source${RESET}"
    L_INFO_CONFIGURE_CURRENCY_RATE="Configure ${BOLD}Currency Rates${RESET}"
    L_INFO_FETCHING_REPOS="Fetching repository list..."
    L_INFO_GH_NO_REPOS="Could not find repositories for '$username'."
    L_INFO_GH_SELECT_REPOS="Select repositories (${BOLD}space${RESET} - select, ${BOLD}enter${RESET} - confirm)."
    L_INFO_DIALOG_NOT_FOUND="('dialog' utility not found, using simplified selection)"
    L_INFO_GH_NO_REPOS_SELECTED="No repositories selected. Aborting."
    L_INFO_GH_CLEAR_CACHE_HINT="To apply changes immediately, clear the cache: ${BOLD}rm ~/.cache/fastfetch/github_stars.cache${RESET}"
    L_PROMPT_GH_LOGIN_NOW="Login to GitHub now? (y/N): "
    L_ERROR_GH_LOGIN_FAILED="Failed to login to GitHub."
    L_PROMPT_GH_USERNAME="Enter GitHub username: "
    L_PROMPT_GH_TRACK_REPO="Track repository '$repo'? (y/N): "
    L_ERROR_SCRIPT_NOT_FOUND="Script not found."
    L_ERROR_GH_CLI_REQUIRED="GitHub CLI (gh) required. Install it to configure the module."
    L_SUCCESS_GH_STARS_CONFIGURED="GitHub Stars module configured!"
    L_INFO_CONFIGURE_NEWS_HEADER="--- Configure News Source ---"
    L_INFO_NEWS_SOURCE_1="OpenNet.ru (RU)"
    L_INFO_NEWS_SOURCE_2="Phoronix (EN)"
    L_INFO_NEWS_SOURCE_3="LWN.net (EN)"
    L_INFO_NEWS_SOURCE_4="Cancel"
    L_SUCCESS_NEWS_SOURCE_SAVED="News source saved!"
    L_INFO_NEWS_CHANGES_APPLIED="Changes will be applied on the next fastfetch run."
    L_PROMPT_NEWS_SOURCE="Select source [1-4]: "
    L_INFO_CONFIGURE_CURRENCY_HEADER="--- Configure Currency Rate Module ---"
    L_INFO_CURRENCY_SELECT_SOURCE="Select a currency rate source:"
    L_INFO_CURRENCY_SOURCE_1="Central Bank of Russia (CBR)"
    L_INFO_CURRENCY_SOURCE_2="European Central Bank (ECB)"
    L_INFO_CURRENCY_PROMPT_CBR="Enter currency code (e.g., USD, EUR, CNY): "
    L_INFO_CURRENCY_PROMPT_ECB_FROM="Enter source currency (e.g., USD): "
    L_INFO_CURRENCY_PROMPT_ECB_TO="Enter target currency (e.g., EUR): "
    L_SUCCESS_CURRENCY_CONFIGURED="Currency rate settings saved!"
    L_INFO_CONFIGURING_SUDOERS="\n${BOLD}Configuring passwordless sudo for smartctl...${RESET}"
    L_INFO_SMARTCTL_NOT_FOUND="Error: 'smartctl' utility not found. Please install 'smartmontools'."
    L_INFO_SUDOERS_DESC_1="A sudoers entry will be created to allow executing"
    L_INFO_SUDOERS_DESC_2="the '${BOLD}smartctl -i ...${RESET}' command without a password for user '${BOLD}$current_user${RESET}'."
    L_INFO_SUDOERS_DESC_3="This will be done by creating the file: ${BOLD}$SUDOERS_FILE${RESET}"
    L_INFO_SUDOERS_DESC_4="\nYour sudo password will be required once for this setup."
    L_INFO_SUDOERS_WORKS_NOW="The disk_info.sh script will now work without a password prompt."
    L_SUCCESS_SUDOERS_CREATED="Sudoers rule created successfully!"
    L_ERROR_SUDOERS_FAILED="Failed to create sudoers rule."
    L_ERROR_SUDO_FAILED="Failed to get sudo privileges."
    L_PROMPT_RESET_CONFIRM="Are you sure you want to reset the configuration to default? (y/N) "
    L_SUCCESS_CONFIG_RESET="Configuration reset to default!"
    L_ERROR_CONFIG_NOT_FOUND="Configuration file not found."
    L_ERROR_DEFAULT_CONFIG_NOT_FOUND="Default configuration file not found."
    L_SUCCESS_CONFIG_SAVED="Configuration saved!"
    L_ERROR_JQ_NOT_FOUND="'jq' utility not found."
    L_ERROR_JQ_INSTALL_HINT="Install 'jq' to work with JSON files."
    L_INFO_CREATING_ALIAS_HEADER="--- Create Alias '${alias_name}' ---"
    L_INFO_ALIAS_CONFIG_CREATED="Creating config file: $config_file"
    L_INFO_ALIAS_APPLY_HINT="\nTo apply the changes, run:"
    L_INFO_ALIAS_RESTART_HINT="Or simply restart your terminal."
    L_INFO_ALIAS_DISK_INFO_DETECTED="Module 'disk_info.sh' detected, which uses 'smartctl'."
    L_INFO_ALIAS_SUDO_REQUIRED="'smartctl' requires superuser (sudo) privileges to work."
    L_INFO_ALIAS_QUESTION="\n${BOLD}How do you want to handle this?${RESET}"
    L_INFO_ALIAS_OPTION_1_DESC="Configure sudoers for passwordless execution of ${BOLD}the specific smartctl command${RESET} (${BOLD}recommended, most secure${RESET})."
    L_INFO_ALIAS_OPTION_1_PRINCIPLE="- ${BOLD}How it works:${RESET} Grants the minimum necessary permissions for reading disk info only."
    L_INFO_ALIAS_OPTION_1_RISK="- ${BOLD}Risk:${RESET} Minimal. Fastfetch and all other scripts will still run as a normal user."
    L_INFO_ALIAS_OPTION_2_DESC="Create an alias that runs ${BOLD}the entire fastfetch via sudo${RESET} (${BOLD}not recommended${RESET})."
    L_INFO_ALIAS_OPTION_2_EXAMPLE="- The alias will be: 'sudo fastfetch --logo none'."
    L_INFO_ALIAS_OPTION_2_RISK="- ${BOLD}Risk:${RESET} ${FG_RED}High.${RESET} All scripts, including those that download data from the network, will run as root."
    L_INFO_ALIAS_OPTION_3_DESC="Create a regular alias (you will have to type 'sudo slowfetch' manually)."
    L_INFO_ALIAS_OPTION_3_HINT="- A simple option if you don't want to change system settings and are okay with typing your password."
    L_INFO_ALIAS_OPTION_4="Cancel."
    L_INFO_ALIAS_SUDOERS_FAILED="Sudoers configuration failed. Alias creation canceled."
    L_INFO_ALIAS_SUDO_REMOVED="'sudo' has been removed from the '${BOLD}disk_info.sh${RESET}' script for smartctl."
    L_SUCCESS_ALIAS_CREATED="Alias created successfully!"
    L_ERROR_SHELL_NOT_SUPPORTED="Your shell is not supported. Only bash and zsh are supported."
    L_ERROR_INVALID_INPUT="Invalid input!"
    L_ERROR_INVALID_MODULE_NUM="Invalid module number!"
    L_ERROR_INVALID_DIRECTION="Invalid direction!"

    L_MAIN_MENU_TITLE="${BOLD}--- Fastfetch Configurator ---${RESET}"
    L_MAIN_MENU_1="Show/refresh module list"
    L_MAIN_MENU_2="Move module"
    L_MAIN_MENU_3="Remove module"
    L_MAIN_MENU_4="Add module"
    L_MAIN_MENU_5="Configure module"
    L_MAIN_MENU_R="Reset configuration to default"
    L_MAIN_MENU_A="Re-configure 'slowfetch' alias"
    L_MAIN_MENU_U="${FG_RED}u. Uninstall slowfetch${RESET}"
    L_MAIN_MENU_S="${FG_GREEN}s. Save changes and exit${RESET}"
    L_MAIN_MENU_Q="${FG_RED}q. Quit WITHOUT saving${RESET}"
    L_PROMPT_CHOOSE_ACTION="Choose an action: "
fi

declare -A SCRIPT_DEPENDENCIES=(
    ["github_stars.sh"]="gh jq"
    ["vram_info.sh"]="nvidia-smi"
    ["ram_specs.sh"]="inxi"
    ["disk_info.sh"]="lsblk df smartctl findmnt"
    ["network_speed.sh"]="curl"
    ["browser_info.sh"]="ps pgrep"
    ["usd_rub_rate.sh"]="curl xmlstarlet"
    ["news.sh"]="curl iconv xmlstarlet"
    ["media_art.sh"]="playerctl chafa"
    ["media_info.sh"]="playerctl"
    ["media_underline.sh"]="playerctl"
    ["ori_info.sh"]="xrandr"
    ["last_update.sh"]="grep date"
)

SCHEMA_LINE=""
CONFIG_JSON=""

get_paths() {
    local base_path="$PROJECT_ROOT"
    if [ -f "$INSTALLED_FLAG" ]; then
        base_path="$CONFIG_DIR"
    fi
    echo "CONFIG_PATH=${base_path}/${CONFIG_FILE_NAME}"
    echo "SCRIPTS_PATH=${base_path}/${SCRIPTS_DIR_NAME}"
    echo "DEFAULT_CONFIG_PATH=${base_path}/${DEFAULT_CONFIG_FILE_NAME}"
    echo "CONFIG_BACKUP_PATH=${base_path}/${CONFIG_BACKUP_FILE_NAME}"
    echo "LAUNCHER_PATH=${base_path}/${LAUNCHER_NAME}"
}

ensure_jq() {
    if ! command -v jq &>/dev/null; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_JQ_NOT_FOUND}${RESET}"
        echo -e "${L_ERROR_JQ_INSTALL_HINT}"
        exit 1
    fi
}

load_config() {
    eval "$(get_paths)"

    if [ ! -f "$CONFIG_PATH" ]; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_CONFIG_NOT_FOUND}${RESET}"
        exit 1
    fi
    SCHEMA_LINE=$(grep '^\s*"$schema"' "$CONFIG_PATH" | sed 's/,$//' | sed 's/^[[:space:]]*//')
    CONFIG_JSON=$(grep -v -e '^\s*//' -e '^\s*"$schema"' "$CONFIG_PATH")
}

save_config() {
    eval "$(get_paths)"

    echo "${L_INFO_SAVING}"
    cp "$CONFIG_PATH" "$CONFIG_BACKUP_PATH"
    local schema_to_insert
    if [ -n "$SCHEMA_LINE" ]; then schema_to_insert="    ${SCHEMA_LINE},"; fi
    jq '.' <<<"$CONFIG_JSON" | sed "1a\\$schema_to_insert" >"$CONFIG_PATH"
    echo -e "${FG_GREEN}${BOLD}${L_SUCCESS_PREFIX}${RESET} ${L_SUCCESS_CONFIG_SAVED}"
}

reset_config() {
    eval "$(get_paths)"

    if [ ! -f "$DEFAULT_CONFIG_PATH" ]; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_DEFAULT_CONFIG_NOT_FOUND}${RESET}"
        return
    fi

    read -rp "$(echo -e "${L_PROMPT_RESET_CONFIRM}")" confirm
    if [[ "$confirm" != "y" ]]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    local user_backup_file="${CONFIG_DIR}/${CONFIG_FILE_NAME}.before_reset_$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_PATH" "$user_backup_file"

    cp "$DEFAULT_CONFIG_PATH" "$CONFIG_PATH"

    echo -e "${FG_GREEN}${L_SUCCESS_CONFIG_RESET}${RESET}"
    echo -e "${L_INFO_BACKUP_SAVED_TO}"

    load_config 
}

check_script_dependencies() {
    local required_tools=()
    local missing_tools=()
    local used_scripts_paths
    local current_config_path

    if [ -f "$INSTALLED_FLAG" ]; then
        current_config_path="${CONFIG_DIR}/${CONFIG_FILE_NAME}"
    else
        current_config_path="${PROJECT_ROOT}/${CONFIG_FILE_NAME}"
    fi

    local current_config_json_content=$(grep -v -e '^\s*//' -e '^\s*"$schema"' "$current_config_path")

    used_scripts_paths=$(jq -r '.modules[] | select(type=="object" and .type=="command") | .text' <<<"$current_config_json_content" | grep -v 'null')

    while IFS= read -r script_path_full; do
        script_name=$(echo $(basename "$script_path_full") | awk '{print $1}')

        if [ -n "${SCRIPT_DEPENDENCIES[$script_name]}" ]; then
            for tool in ${SCRIPT_DEPENDENCIES[$script_name]}; do
                if ! [[ " ${required_tools[@]} " =~ " ${tool} " ]]; then
                    required_tools+=("$tool")
                fi
            done
        fi
    done <<<"$used_scripts_paths"

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${L_INFO_DEPENDENCIES_WARNING_HEADER}"
        for tool in "${missing_tools[@]}"; do
            echo -e "  - ${FG_RED}$tool${RESET}"
        done
        echo -e "${L_INFO_DEPENDENCIES_WARNING_FOOTER}"
        return 1
    fi
    echo -e "${FG_GREEN}OK!${RESET}"
    return 0
}

list_modules() {
    eval "$(get_paths)"

    echo -e "${BOLD}${L_INFO_MODULES_HEADER}${RESET}"

    local temp_file
    temp_file=$(mktemp)

    jq -c '.modules[]' <<<"$CONFIG_JSON" | while IFS= read -r module_json; do
        if [[ "$module_json" == "null" ]]; then
            continue
        fi

        local output_line=""

        if [[ "$module_json" == \"*\" ]]; then
            local module_string
            module_string=$(jq -r . <<<"$module_json")
            [[ "$module_string" == "break" ]] && output_line="break" || output_line="--- $module_string ---"
        elif [[ "$module_json" == \{*\} ]]; then
            local module_type
            module_type=$(echo "$module_json" | jq -r '.type // "unknown"')

            if [[ "$module_type" == "custom" ]]; then
                local format
                format=$(echo "$module_json" | jq -r '.format // ""')
                [[ "$format" == *"──"* ]] && output_line="--- ${L_INFO_SEPARATOR} ---" || output_line="$format"
            elif [[ "$module_type" == "command" ]]; then
                local text
                text=$(echo "$module_json" | jq -r '.text // ""')
                local key
                key=$(echo "$module_json" | jq -r '.key // ""')

                local script_base_name
                script_base_name=$(echo $(basename "$text") | awk '{print $1}' | sed 's/\.sh$//')

                local icon=""
                if [[ -f "${SCRIPTS_PATH}/${script_base_name}.sh" ]]; then
                    icon=$(grep '^ICON=' "${SCRIPTS_PATH}/${script_base_name}.sh" | cut -d'"' -f2 2>/dev/null || echo "")
                fi

                local display_name=""
                if [[ "$key" == " " ]]; then
                    [[ -n "$icon" ]] && display_name="$icon $script_base_name" || display_name="└─ $script_base_name"
                else
                    display_name="$key"
                fi

                output_line="$display_name (command)"
            else
                local key
                key=$(echo "$module_json" | jq -r '.key // ""')
                output_line="$key ($module_type)"
            fi
        fi

        if [ -n "$output_line" ]; then
            echo "$output_line" | sed 's/^[[:space:]]*//' >>"$temp_file"
        fi

    done

    if [[ -f "$temp_file" ]]; then
        nl -w2 -s'. ' "$temp_file"
        rm "$temp_file"
    fi

    echo "---------------------------------------"
}

move_module() {
    list_modules
    local count
    count=$(jq '.modules | length' <<<"$CONFIG_JSON")
    read -rp "$(echo -e "${BOLD}${L_PROMPT_MOVE_MODULE_NUM}${RESET} ")" index
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo -e "${FG_RED}${L_ERROR_INVALID_INPUT}${RESET}"
        return
    fi
    local jq_index=$((index - 1))
    if ((jq_index < 0 || jq_index >= count)); then
        echo -e "${FG_RED}${L_ERROR_INVALID_MODULE_NUM}${RESET}"
        return
    fi

    local module_json=$(jq -r ".modules[$jq_index]" <<<"$CONFIG_JSON")
    local module_type=$(echo "$module_json" | jq -r '.type // "unknown"')
    local module_name
    if [[ "$module_type" == "string" ]]; then
        module_name=$(echo "$module_json" | sed 's/^[[:space:]]*//')
    elif [[ "$module_type" == "command" ]]; then
        local text=$(echo "$module_json" | jq -r '.text // ""')
        local key=$(echo "$module_json" | jq -r '.key // ""')
        if [[ "$key" == " " ]]; then
            module_name=$(echo $(basename "$text") | awk '{print $1}' | sed 's/\.sh$//')
        else
            module_name="$key"
        fi
    else
        module_name=$(echo "$module_json" | jq -r '.key // ""' | sed 's/^[[:space:]]*//')
    fi

    echo "${L_INFO_MOVING_MODULE}"
    read -rp "$(echo -e "${L_PROMPT_MOVE_MODULE_DIR}")" direction
    local new_index
    if [[ "$direction" == "u" ]]; then
        if ((jq_index == 0)); then
            echo "${L_INFO_MODULE_ALREADY_TOP}"
            return
        fi
        new_index=$((jq_index - 1))
    elif [[ "$direction" == "d" ]]; then
        if ((jq_index == count - 1)); then
            echo "${L_INFO_MODULE_ALREADY_BOTTOM}"
            return
        fi
        new_index=$((jq_index + 1))
    else
        echo -e "${FG_RED}${L_ERROR_INVALID_DIRECTION}${RESET}"
        return
    fi

    CONFIG_JSON=$(jq "(.modules[$jq_index]) as \$element | del(.modules[$jq_index]) | .modules = .modules[:$new_index] + [\$element] + .modules[$new_index:]" <<<"$CONFIG_JSON")
    echo -e "${FG_GREEN}${L_SUCCESS_MODULE_MOVED}${RESET}"
}

remove_module() {
    list_modules
    read -rp "$(echo -e "${BOLD}${L_PROMPT_REMOVE_MODULE_NUM}${RESET} ")" index
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo -e "${FG_RED}${L_ERROR_INVALID_INPUT}${RESET}"
        return
    fi
    local jq_index=$((index - 1))

    local module_json=$(jq -r ".modules[$jq_index]" <<<"$CONFIG_JSON")
    local module_type=$(echo "$module_json" | jq -r '.type // "unknown"')
    local module_info
    if [[ "$module_type" == "string" ]]; then
        module_info=$(echo "$module_json" | sed 's/^[[:space:]]*//')
    elif [[ "$module_type" == "command" ]]; then
        local key=$(echo "$module_json" | jq -r '.key // ""')
        if [[ "$key" == " " ]]; then
            module_info=$(echo $(basename "$(echo "$module_json" | jq -r '.text // ""')") | awk '{print $1}' | sed 's/\.sh$//')
        else
            module_info="$key"
        fi
    else
        module_info=$(echo "$module_json" | jq -r '.key // ""' | sed 's/^[[:space:]]*//')
    fi

    read -rp "$(echo -e "${L_PROMPT_REMOVE_MODULE_CONFIRM}")" confirm
    if [[ "$confirm" != "y" ]]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    CONFIG_JSON=$(jq "del(.modules[$jq_index])" <<<"$CONFIG_JSON")
    echo -e "${FG_GREEN}${L_SUCCESS_MODULE_REMOVED}${RESET}"
}

add_module() {
    eval "$(get_paths)"

    echo -e "${BOLD}${L_INFO_ADD_MODULE_HEADER}${RESET}"
    local all_scripts
    mapfile -t all_scripts < <(find "$SCRIPTS_PATH" -maxdepth 1 -type f -name "*.sh" -printf "%f\n")
    local used_scripts
    mapfile -t used_scripts < <(jq -r '.modules[] | select(type=="object" and .type=="command") | .text' <<<"$CONFIG_JSON" | grep -oP '[a-zA-Z0-9_-]+\.sh' | sort -u)
    local available_scripts=()
    for script in "${all_scripts[@]}"; do
        is_used=false
        for used in "${used_scripts[@]}"; do if [[ "$script" == "$used" ]]; then
            is_used=true
            break
        fi; done
        if ! $is_used; then available_scripts+=("$script"); fi
    done

    if [ ${#available_scripts[@]} -eq 0 ]; then
        echo "${L_INFO_NO_FREE_SCRIPTS}"
        return
    fi

    local cancel_option="${L_INFO_ADD_MODULE_CANCEL_OPTION}"
    available_scripts+=("$cancel_option")

    echo "${L_INFO_ADD_MODULE_SELECT_SCRIPT}"
    select script_to_add in "${available_scripts[@]}"; do
        if [ -n "$script_to_add" ]; then
            if [[ "$script_to_add" == "$cancel_option" ]]; then
                echo "${L_INFO_ADD_MODULE_CANCELED}"
                return
            fi
            break
        else echo -e "${FG_RED}${L_INFO_ADD_MODULE_INVALID_CHOICE}${RESET}"; fi
    done

    read -rp "$(echo -e "${BOLD}${L_PROMPT_ADD_MODULE_KEY}${RESET} ")" key
    local final_key="${key:- }"

    local new_module
    new_module=$(jq -n --arg key "$final_key" --arg text "\$HOME/.config/fastfetch/scripts/$script_to_add" '{type: "command", key: $key, text: $text}')

    clear
    echo -e "${BOLD}${L_INFO_ADD_MODULE_CHOOSE_POS}${RESET}"
    list_modules
    local count
    count=$(jq '.modules | length' <<<"$CONFIG_JSON")
    read -rp "$(echo -e "${BOLD}${L_PROMPT_ADD_MODULE_POS}${RESET} ")" index

    if ! [[ "$index" =~ ^[0-9]+$ ]] || ((index <= 0)) || ((index > count)); then
        CONFIG_JSON=$(jq --argjson newModule "$new_module" '.modules += [$newModule]' <<<"$CONFIG_JSON")
    else
        local jq_index=$((index - 1))
        CONFIG_JSON=$(jq --argjson newModule "$new_module" --argjson idx "$jq_index" '.modules = .modules[:$idx] + [$newModule] + .modules[$idx:]' <<<"$CONFIG_JSON")
    fi

    echo -e "${FG_GREEN}${L_SUCCESS_MODULE_ADDED}${RESET}"
}

configure_module() {
    echo -e "${BOLD}${L_INFO_CONFIGURE_MODULES_HEADER}${RESET}"
    echo -e "1. ${L_INFO_CONFIGURE_GH_STARS}"
    echo -e "2. ${L_INFO_CONFIGURE_NEWS_SOURCE}"
    echo -e "3. ${L_INFO_CONFIGURE_CURRENCY_RATE}"
    echo "--------------------------"
    read -rp "$(echo -e "${BOLD}${L_PROMPT_CONFIGURE_MODULE}${RESET} ")" choice
    case $choice in
    1) configure_github_stars ;;
    2) configure_news_module ;;
    3) configure_currency_module ;;
    *) echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}" ;;
    esac
}

configure_github_stars() {
    eval "$(get_paths)"
    local script_path="${SCRIPTS_PATH}/github_stars.sh"
    if [ ! -f "$script_path" ]; then
        echo -e "${FG_RED}${L_ERROR_SCRIPT_NOT_FOUND}${RESET}"
        return
    fi

    if ! command -v gh &>/dev/null; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_GH_CLI_REQUIRED}${RESET}"
        return
    fi

    if ! gh auth status &>/dev/null; then
        echo "You are not logged into GitHub via gh."
        read -rp "${L_PROMPT_GH_LOGIN_NOW}" login_choice
        if [[ "$login_choice" == "y" ]]; then
            gh auth login
            if ! gh auth status &>/dev/null; then
                echo -e "${FG_RED}${L_ERROR_GH_LOGIN_FAILED}${RESET}"
                return
            fi
        else return; fi
    fi

    read -rp "${L_PROMPT_GH_USERNAME}" username
    if [ -z "$username" ]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    echo "${L_INFO_FETCHING_REPOS}"
    local repos
    mapfile -t repos < <(gh repo list "$username" --limit 100 --json "nameWithOwner" -q '.[].nameWithOwner')
    if [ ${#repos[@]} -eq 0 ]; then
        echo -e "${FG_RED}${L_INFO_GH_NO_REPOS}${RESET}"
        return
    fi

    echo -e "${L_INFO_GH_SELECT_REPOS}"
    local selected_repos_str
    if command -v dialog &>/dev/null; then
        local dialog_opts=()
        for repo in "${repos[@]}"; do dialog_opts+=("$repo" "" off); done
        selected_repos_str=$(dialog --stdout --separate-output --checklist "Your repositories:" 20 70 15 "${dialog_opts[@]}")
    else
        echo "(${L_INFO_DIALOG_NOT_FOUND})"
        local selected_repos_arr=()
        for repo in "${repos[@]}"; do
            read -rp "${L_PROMPT_GH_TRACK_REPO}" track_choice
            if [[ "$track_choice" == "y" ]]; then selected_repos_arr+=("$repo"); fi
        done
        selected_repos_str=$(printf "%s\n" "${selected_repos_arr[@]}")
    fi
    if [ -z "$selected_repos_str" ]; then
        echo "${L_INFO_GH_NO_REPOS_SELECTED}"
        return
    fi

    local new_repos_block="    local REPOS=(\n"
    while read -r repo; do new_repos_block+="        \"$repo\"\n"; done <<<"$selected_repos_str"
    new_repos_block+="    )"

    sed -i.bak -e "/local REPOS=(/,/)/c\\$new_repos_block" "$script_path"
    echo -e "${FG_GREEN}${BOLD}${L_SUCCESS_PREFIX}${RESET} ${L_SUCCESS_GH_STARS_CONFIGURED}"
    echo "${L_INFO_GH_CLEAR_CACHE_HINT}"
}

configure_news_module() {
    echo -e "${BOLD}${L_INFO_CONFIGURE_NEWS_HEADER}${RESET}"

    local news_config_dir="$HOME/.config/fastfetch"
    local source_file="$news_config_dir/news.source"
    mkdir -p "$news_config_dir"

    echo "${L_INFO_NEWS_SELECT_SOURCE}"
    echo "  1. ${L_INFO_NEWS_SOURCE_1}"
    echo "  2. ${L_INFO_NEWS_SOURCE_2}"
    echo "  3. ${L_INFO_NEWS_SOURCE_3}"
    echo "  4. ${L_INFO_NEWS_SOURCE_4}"

    read -rp "$(echo -e "\n${BOLD}${L_PROMPT_NEWS_SOURCE}${RESET} ")" choice

    local new_source=""
    case $choice in
    1) new_source="opennet" ;;
    2) new_source="phoronix" ;;
    3) new_source="lwn" ;;
    4)
        echo "${L_INFO_CANCEL}"
        return
        ;;
    *)
        echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}"
        return
        ;;
    esac

    echo "$new_source" >"$source_file"

    echo -e "${FG_GREEN}${L_SUCCESS_NEWS_SOURCE_SAVED}${RESET}"
    echo "${L_INFO_NEWS_CHANGES_APPLIED}"
}

configure_currency_module() {
    echo -e "\n${BOLD}${L_INFO_CONFIGURE_CURRENCY_HEADER}${RESET}"
    local config_dir="$HOME/.config/fastfetch"
    local config_file="$config_dir/currency.conf"
    mkdir -p "$config_dir"

    echo "${L_INFO_CURRENCY_SELECT_SOURCE}"
    echo "  1. ${L_INFO_CURRENCY_SOURCE_1}"
    echo "  2. ${L_INFO_CURRENCY_SOURCE_2}"
    echo "  3. ${L_INFO_NEWS_SOURCE_4}"

    read -rp "$(echo -e "\n${BOLD}${L_PROMPT_NEWS_SOURCE}${RESET} ")" choice

    local new_source=""
    local new_pair=""

    case $choice in
    1)
        new_source="CBR"
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_CBR}")" currency_code
        if [ -z "$currency_code" ]; then
            echo "${L_INFO_CANCEL}"
            return
        fi
        new_pair="${currency_code^^}/RUB"
        ;;
    2)
        new_source="ECB"
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_ECB_FROM}")" currency_from
        if [ -z "$currency_from" ]; then
            echo "${L_INFO_CANCEL}"
            return
        fi
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_ECB_TO}")" currency_to
        if [ -z "$currency_to" ]; then
            echo "${L_INFO_CANCEL}"
            return
        fi
        new_pair="${currency_from^^}/${currency_to^^}"
        ;;
    3)
        echo "${L_INFO_CANCEL}"
        return
        ;;
    *)
        echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}"
        return
        ;;
    esac

    echo "SOURCE=\"$new_source\"" >"$config_file"
    echo "PAIR=\"$new_pair\"" >>"$config_file"

    echo -e "${FG_GREEN}${L_SUCCESS_CURRENCY_CONFIGURED}${RESET}"
}

configure_sudoers() {
    echo -e "${L_INFO_CONFIGURING_SUDOERS}"

    if ! command -v smartctl &>/dev/null; then
        echo -e "${FG_RED}${L_INFO_SMARTCTL_NOT_FOUND}${RESET}"
        return 1
    fi

    local smartctl_path
    smartctl_path=$(command -v smartctl)
    local current_user=${SUDO_USER:-$USER}
    local sudoers_rule="$current_user ALL=(ALL) NOPASSWD: $smartctl_path -i /dev/sd*, $smartctl_path -i /dev/nvme*"

    echo "${L_INFO_SUDOERS_DESC_1}"
    echo -e "${L_INFO_SUDOERS_DESC_2}"
    echo -e "${L_INFO_SUDOERS_DESC_3}"
    echo -e "${L_INFO_SUDOERS_DESC_4}"

    sudo -v
    if [ $? -ne 0 ]; then
        echo -e "${FG_RED}${L_ERROR_SUDO_FAILED}${RESET}"
        return 1
    fi

    echo "$sudoers_rule" | sudo tee "$SUDOERS_FILE" >/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${FG_GREEN}${L_SUCCESS_PREFIX} ${L_SUCCESS_SUDOERS_CREATED}${RESET}"
        echo "${L_INFO_SUDOERS_WORKS_NOW}"
        return 0
    else
        echo -e "${FG_RED}${L_ERROR_SUDOERS_FAILED}${RESET}"
        return 1
    fi
}

write_alias_to_config() {
    local alias_name=$1
    local alias_command_value=$2 
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *)
        echo -e "${FG_RED}${L_ERROR_PREFIX} ${L_ERROR_SHELL_NOT_SUPPORTED}${RESET}"
        return
        ;;
    esac

    local alias_line="alias ${alias_name}='${alias_command_value}'"
    local alias_comment="# Alias for fastfetch, added by configurator"

    if [ ! -f "$config_file" ]; then
        echo "${L_INFO_ALIAS_CONFIG_CREATED}"
        touch "$config_file"
    fi

    sed -i.bak "/^${alias_comment}/d" "$config_file"
    sed -i.bak "/^alias ${alias_name}=/d" "$config_file"

    echo -e "\n${alias_comment}\n${alias_line}" >>"$config_file"
    echo -e "${FG_GREEN}${L_SUCCESS_ALIAS_CREATED}${RESET}"
}

remove_alias_from_config() {
    local alias_name=$1
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *) return ;;
    esac

    if [ -f "$config_file" ]; then
        sed -i.bak -e "/# Alias for fastfetch, added by configurator/d" -e "/^alias ${alias_name}=/d" "$config_file"
    fi
}

prompt_to_reload_shell() {
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *)
        echo -e "${L_INFO_ALIAS_APPLY_HINT}"
        echo -e "${L_INFO_ALIAS_RESTART_HINT}"
        return
        ;;
    esac

    local source_command="source ${config_file}"
    if [[ "$shell_name" == "zsh" ]]; then
        source_command="source ${config_file} && compinit"
    fi

    echo -e "${L_INFO_ALIAS_APPLY_HINT}\n  ${BOLD}${source_command}${RESET}\n${L_INFO_ALIAS_RESTART_HINT}"

    read -rp "$(echo -e "${L_PROMPT_RELOAD_SHELL}")" choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "${L_INFO_RELOADING_SHELL}"
        exec "$SHELL"
    fi
}

create_alias() {
    local alias_name=$1
    local default_command=$2
    local config_base_path

    if [ -f "$INSTALLED_FLAG" ]; then
        config_base_path="$CONFIG_DIR"
    else
        config_base_path="$PROJECT_ROOT"
    fi

    local current_config_path="${config_base_path}/${CONFIG_FILE_NAME}"
    local alias_command_value="${default_command}"
    local sudo_needed=false

    echo -e "\n${BOLD}${L_INFO_CREATING_ALIAS_HEADER}${RESET}"

    if jq -e '.modules[] | select(.text? | strings | contains("disk_info.sh"))' "$current_config_path" >/dev/null; then
        sudo_needed=true
    fi

    if [[ "$sudo_needed" == true ]]; then
        echo "${L_INFO_ALIAS_DISK_INFO_DETECTED}"
        echo "${L_INFO_ALIAS_SUDO_REQUIRED}"
        echo -e "${L_INFO_ALIAS_QUESTION}"
        echo -e "  1. ${L_INFO_ALIAS_OPTION_1_DESC}"
        echo -e "     ${L_INFO_ALIAS_OPTION_1_PRINCIPLE}"
        echo -e "     ${L_INFO_ALIAS_OPTION_1_RISK}"
        echo ""
        echo -e "  2. ${L_INFO_ALIAS_OPTION_2_DESC}"
        echo -e "     - ${L_INFO_ALIAS_OPTION_2_EXAMPLE}"
        echo -e "     - ${L_INFO_ALIAS_OPTION_2_RISK}"
        echo ""
        echo -e "  3. ${L_INFO_ALIAS_OPTION_3_DESC}"
        echo -e "     ${L_INFO_ALIAS_OPTION_3_HINT}"
        echo ""
        echo "  4. ${L_INFO_ALIAS_OPTION_4}"

        read -rp "$(echo -e "\n${BOLD}${L_PROMPT_ALIAS_OPTION}${RESET} ")" choice

        case $choice in
        1)
            if configure_sudoers; then
                eval "$(get_paths)"
                if grep -q "sudo smartctl" "${SCRIPTS_PATH}/disk_info.sh"; then
                    sed -i.bak 's/sudo smartctl/smartctl/' "${SCRIPTS_PATH}/disk_info.sh"
                    echo "${L_INFO_ALIAS_SUDO_REMOVED}"
                fi
                alias_command_value="${default_command}"
            else
                echo -e "${FG_RED}${L_INFO_ALIAS_SUDOERS_FAILED}${RESET}"
                return
            fi
            ;;
        2)
            alias_command_value="sudo ${default_command}"
            ;;
        3)
            alias_command_value="${default_command}"
            ;;
        4)
            echo "${L_INFO_CANCEL}"
            return
            ;;
        *)
            echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE} ${L_INFO_CANCEL}${RESET}"
            return
            ;;
        esac
    fi

    write_alias_to_config "$alias_name" "$alias_command_value"
}

create_config_alias() {
    eval "$(get_paths)"
    write_alias_to_config "slowfetch-config" "bash ${LAUNCHER_PATH}"
}

first_run_setup() {
    clear
    echo -e "${L_INSTALL_WELCOME}"
    echo "${L_INSTALL_FIRST_RUN}"

    echo -e "\n${L_INSTALL_DEP_CHECK}"
    if ! check_script_dependencies; then
        read -rp "$(echo -e "${L_PROMPT_CONTINUE_OR_EXIT}")" user_choice
        if [[ "$user_choice" == "exit" ]]; then
            echo "${L_INFO_EXITING}"
            exit 0
        fi
    fi

    create_alias "slowfetch" "fastfetch --logo none"

    echo -e "\n${L_INSTALL_PERFORMING}"
    perform_installation

    echo -e "\n${L_INSTALL_CONFIG_ALIAS}"
    create_config_alias

    touch "$INSTALLED_FLAG"

    clear
    echo -e "${L_INSTALL_COMPLETE_HEADER}"
    echo "${L_INSTALL_COMPLETE_BODY}"
    echo -e "  - ${L_INSTALL_COMPLETE_ALIAS_SLOWFETCH}"
    echo -e "  - ${L_INSTALL_COMPLETE_ALIAS_CONFIG}"

    prompt_to_reload_shell
    exit 0
}

perform_installation() {
    mkdir -p "$CONFIG_DIR"

    if [ -n "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
        echo "   - ${L_INSTALL_BACKING_UP}"
        local backup_dir="${CONFIG_DIR}/.backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        mv "$CONFIG_DIR"/* "$CONFIG_DIR"/.[!.]* "$backup_dir/" 2>/dev/null
    fi

    cp -a "$PROJECT_ROOT"/* "$CONFIG_DIR/"

    chmod +x "${CONFIG_DIR}/${LAUNCHER_NAME}"
    chmod +x "${CONFIG_DIR}/${SCRIPTS_DIR_NAME}/"*.sh
    echo -e "${FG_GREEN}   OK!${RESET}"
}

uninstall_project() {
    clear
    echo -e "${FG_RED}${BOLD}${L_UNINSTALL_WARNING}${RESET}"
    read -rp "$(echo -e "${L_UNINSTALL_CONFIRM}")" confirm
    if [[ "$confirm" != "y" ]]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    echo -e "\n${L_UNINSTALL_STARTED}"

    echo -n "-> ${L_UNINSTALL_SUDOERS} "
    if [ -f "$SUDOERS_FILE" ]; then
        sudo rm -f "$SUDOERS_FILE"
        echo -e "${FG_GREEN}OK${RESET}"
    else
        echo "Not found."
    fi

    echo -n "-> ${L_UNINSTALL_ALIASES} "
    remove_alias_from_config "slowfetch"
    remove_alias_from_config "slowfetch-config"
    echo -e "${FG_GREEN}OK${RESET}"

    echo "-> ${L_UNINSTALL_FILES}"
    local latest_backup_dir=$(find "$CONFIG_DIR" -maxdepth 1 -type d -name ".backup_*" | sort -r | head -n 1)

    if [ -n "$latest_backup_dir" ]; then
        echo "   - ${L_UNINSTALL_RESTORE}"
        local temp_cleanup_dir="${CONFIG_DIR}/.temp_cleanup_$(date +%s)"
        mkdir -p "$temp_cleanup_dir"
        find "$CONFIG_DIR" -mindepth 1 ! -wholename "$latest_backup_dir*" -exec mv -t "$temp_cleanup_dir" {} + 2>/dev/null

        mv "$latest_backup_dir"/* "$latest_backup_dir"/.[!.]* "$CONFIG_DIR/" 2>/dev/null

        rm -rf "$temp_cleanup_dir" "$latest_backup_dir"
    else
        echo "   - ${L_UNINSTALL_NO_BACKUP}"
        rm -rf "$CONFIG_DIR"
    fi

    echo -e "\n${FG_GREEN}${L_UNINSTALL_COMPLETE}${RESET}"
    echo "${L_UNINSTALL_GOODBYE}"

    rm -- "$0"
    exit 0
}

main_menu() {
    clear
    echo -e "${L_MAIN_MENU_TITLE}"
    echo "1. ${L_MAIN_MENU_1}"
    echo "2. ${L_MAIN_MENU_2}"
    echo "3. ${L_MAIN_MENU_3}"
    echo "4. ${L_MAIN_MENU_4}"
    echo "5. ${L_MAIN_MENU_5}"
    echo "r. ${L_MAIN_MENU_R}"
    echo "a. ${L_MAIN_MENU_A}"
    echo "---------------------------------------"
    echo -e "${L_MAIN_MENU_U}"
    echo "---------------------------------------"
    echo -e "${L_MAIN_MENU_S}"
    echo -e "${L_MAIN_MENU_Q}"
    echo "---------------------------------------"

    read -rp "$(echo -e "${BOLD}${L_PROMPT_CHOOSE_ACTION}${RESET} ")" choice
    case $choice in
    1) list_modules ;;
    2) move_module ;;
    3) remove_module ;;
    4) add_module ;;
    5) configure_module ;;
    r) reset_config ;;
    a)
        create_alias "slowfetch" "fastfetch --logo none"
        prompt_to_reload_shell
        ;;
    u) uninstall_project ;;
    s)
        save_config
        exit 0
        ;;
    q)
        echo "${L_INFO_EXITING_NO_SAVE}"
        exit 0
        ;;
    *) echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}" ;;
    esac

    echo -e "\n${L_INFO_PRESS_ENTER}"
    read -r
}

if [ ! -f "$INSTALLED_FLAG" ]; then
    if [ "$PROJECT_ROOT" != "$CONFIG_DIR" ]; then
        first_run_setup
    fi
fi

ensure_jq
load_config

while true; do
    main_menu
done
