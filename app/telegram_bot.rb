require 'telegram/bot'

token = '6530899159:AAGjsSEAEjwLfOLeR0JChLe2GJ9VQCph7Pk'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you.")
    end
  end
end

