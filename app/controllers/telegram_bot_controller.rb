class TelegramBotController < ApplicationController
    skip_before_action :verify_authenticity_token

    def webhook
      token = '6530899159:AAGjsSEAEjwLfOLeR0JChLe2GJ9VQCph7Pk'
      client = Telegram::Bot::Client.new(token)

      update = params[:update]

      if update && update['message']
        message = update['message']
        chat_id = message['chat']['id']
        text = message['text']

        case text
        when '/start'
          client.api.send_message(chat_id: chat_id, text: "Hello, #{message['from']['first_name']}")
        else
          client.api.send_message(chat_id: chat_id, text: "I don't understand you.")
        end
      end

      head :ok
    end
  end