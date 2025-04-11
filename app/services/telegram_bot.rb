# app/bots/telegram_bot.rb
require 'telegram/bot'

class TelegramBot
  def self.run
    token = '6530899159:AAGjsSEAEjwLfOLeR0JChLe2GJ9VQCph7Pk' # Замените на реальный токен
    logger = Logger.new($stdout)

    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        begin
          user = User.find_by(telegram_id: message.chat.id)
          chat_id = message.chat.id
          text = message.text.to_s.downcase

          case text
          when '/start'
            bot.api.send_message(
              chat_id: chat_id,
              text: "👋 Привет! Я бот для учета расходов.\n" \
                    "Доступные команды:\n" \
                    "/login [email] [password] - вход\n" \
                    "/add [сумма] [категория] [описание] - добавить расход\n" \
                    "/stats - статистика за сегодня"
            )
          when /^\/login (.+) (.+)$/
            email, password = text.split[1..2]
            handle_login(bot, chat_id, email, password)
          when /^\/add (\d+) (.+) (.+)$/
            unless user
              bot.api.send_message(chat_id: chat_id, text: "❌ Сначала войдите: /login email password")
              next
            end
            amount, category_name, description = text.split[1..3]
            handle_add_transaction(bot, user, amount, category_name, description)
          when '/stats'
            unless user
              bot.api.send_message(chat_id: chat_id, text: "❌ Сначала войдите: /login email password")
              next
            end
            handle_today_stats(bot, user)
          else
            bot.api.send_message(chat_id: chat_id, text: "❌ Неизвестная команда. Введите /start")
          end
        rescue => e
          logger.error("Ошибка: #{e.message}")
          bot.api.send_message(chat_id: chat_id, text: "⚠️ Ошибка: #{e.message}") if chat_id
        end
      end
    end
  end

  private

  def self.handle_login(bot, chat_id, email, password)
    user = User.find_by(email: email)
    if user&.valid_password?(password)
      user.update!(telegram_id: chat_id)
      bot.api.send_message(chat_id: chat_id, text: "✅ Вы успешно авторизованы!")
    else
      bot.api.send_message(chat_id: chat_id, text: "❌ Неверный email или пароль.")
    end
  end

  def self.handle_add_transaction(bot, user, amount, category_name, description)
    category = Category.find_or_create_by!(name: category_name, user: user)
    transaction = user.transactions.create!(
      amount: amount,
      description: description,
      date: Date.today,
      category: category
    )
    bot.api.send_message(
      chat_id: user.telegram_id,
      text: "💸 Транзакция добавлена:\n" \
            "💰 #{amount} руб.\n" \
            "🏷️ #{category_name}\n" \
            "📝 #{description}"
    )
  rescue => e
    bot.api.send_message(chat_id: user.telegram_id, text: "❌ Ошибка: #{e.message}")
  end

  def self.handle_today_stats(bot, user)
    transactions = user.transactions.where(date: Date.today).group(:category).sum(:amount)
    if transactions.empty?
      bot.api.send_message(chat_id: user.telegram_id, text: "📊 Сегодня расходов нет.")
    else
      message = "📊 Статистика за сегодня:\n"
      transactions.each do |category, amount|
        message += "▫️ #{category.name}: #{amount} руб.\n"
      end
      total = transactions.values.sum
      message += "\n💵 Итого: #{total} руб."
      bot.api.send_message(chat_id: user.telegram_id, text: message)
    end
  end
end