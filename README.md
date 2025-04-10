# Finances App

![finances-thumb](https://user-images.githubusercontent.com/63426656/226148785-0c108670-5fe3-4ce6-9a14-2012d9868de9.png)


```markdown
# 💸 Expense Tracker — Установка и запуск проекта

## 🚀 Быстрый старт в WSL (Ubuntu) (не повторяйте моих ошибой делайте git clone сразу из под wsl )

Инструкция по установке и запуску проекта в среде WSL (например, Ubuntu в Windows 10/11).

---

## 🧱 Требования

- Ruby 3.2.1
- Node.js и npm
- Yarn
- PostgreSQL
- RVM (Ruby Version Manager)
- Bundler

---

## 🛠️ Установка и настройка

### 1. Установи системные зависимости

```bash
sudo apt update
sudo apt install curl gnupg build-essential libpq-dev nodejs npm -y
```

### 2. Установи Ruby через RVM

```bash
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 3.2.1
rvm use 3.2.1 --default
```

### 3. Установи Yarn и обнови npm

```bash
sudo npm install -g yarn
sudo npm install -g npm@latest
```

Проверь версии:

```bash
ruby -v
node -v
npm -v
yarn -v
```

---

### 4. Установи и настрой PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib -y
```

Создай пользователя `root` с паролем:

```bash
sudo -i -u postgres
psql
CREATE USER root WITH PASSWORD 'your_password';
ALTER USER root WITH SUPERUSER;
\q
exit
```

---

### 5. Подготовь проект

Перейди в директорию проекта:

```bash
cd ~/путь/к/проекту/expense-tracker
```

Если проект был скачан в Windows — переконвертируй окончания строк:

```bash
sudo apt install dos2unix
find . -type f -exec dos2unix {} \;
```

---

### 6. Установи зависимости

Ruby-гемы:

```bash
bundle install
```

Node-модули:

```bash
yarn install
```

---

### 7. Настрой базу данных

Открой `config/database.yml` и укажи:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  username: root
  password: your_password
  host: localhost
```

---

### 8. Создай базу данных и применяй миграции

```bash
rails db:create && rails db:migrate
```

---

### 9. Запусти сервер

```bash
bin/dev
```
---

Теперь проект доступен на `http://localhost:3000` 🎉  
```

