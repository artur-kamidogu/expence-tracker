namespace :telegram do
    desc "Start Telegram bot"
    task :start => :environment do
      TelegramBot.run
    end
  end