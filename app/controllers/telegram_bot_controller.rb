class TelegramBotController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    token = '6530899159:AAGjsSEAEjwLfOLeR0JChLe2GJ9VQCph7Pk'
    bot = TelegramBotService.new(token, params[:update])

    if bot.valid_update?
      user = User.find_by(telegram_id: bot.chat_id)
      
      case bot.command
      when '/start'
        bot.send_message("Добро пожаловать в Expense Tracker! Доступные команды:\n/login [email] [password] - вход\n/add_transaction [amount] [description] [category_name] - добавить транзакцию\n/today_stats - статистика за сегодня")
      when '/login'
        handle_login(bot)
      when '/add_transaction'
        handle_add_transaction(bot, user)
      when '/today_stats'
        handle_today_stats(bot, user)
      else
        bot.send_message("Неизвестная команда. Введите /start для списка команд.")
      end
    end

    head :ok
  end

  private

  def handle_login(bot)
    email, password = bot.text.split[1..2]
    user = User.find_by(email: email)

    if user&.valid_password?(password)
      user.update(telegram_id: bot.chat_id)
      bot.send_message("Вы успешно авторизованы!")
    else
      bot.send_message("Неверный email или пароль.")
    end
  end

  def handle_add_transaction(bot, user)
    unless user
      bot.send_message("Сначала выполните вход с помощью /login [email] [password]")
      return
    end

    args = bot.text.split
    if args.size < 4
      bot.send_message("Использование: /add_transaction [amount] [description] [category_name]")
      return
    end

    amount = args[1].to_f
    description = args[2..-2].join(' ')
    category_name = args.last

    category = Category.find_or_create_by(name: category_name, user: user)
    transaction = user.transactions.new(
      amount: amount,
      description: description,
      date: Date.today,
      category: category
    )

    if transaction.save
      bot.send_message("Транзакция добавлена: #{amount} руб. - #{description} (#{category_name})")
    else
      bot.send_message("Ошибка: #{transaction.errors.full_messages.join(', ')}")
    end
  end

  def handle_today_stats(bot, user)
    unless user
      bot.send_message("Сначала выполните вход с помощью /login [email] [password]")
      return
    end

    transactions = user.transactions.where(date: Date.today).group(:category).sum(:amount)
    
    if transactions.any?
      message = "Статистика за сегодня:\n"
      transactions.each do |category, amount|
        message += "#{category.name}: #{amount} руб.\n"
      end
      total = transactions.values.sum
      message += "\nИтого: #{total} руб."
    else
      message = "Сегодня еще нет транзакций."
    end

    bot.send_message(message)
  end
end