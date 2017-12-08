require 'sequel'

class Config
  attr_accessor *%i(
    verification_token
    slash_command
    acknowledgement
    database_url
  )

  def database
    @database ||= Sequel.connect(database_url)
  end

  def verification_token
    @verification_token ||= ENV.fetch('SLACK_VERIFICATION_TOKEN')
  end

  def webhook_url
    @webhook_url ||= ENV.fetch('SLACK_WEBHOOK_URL')
  end

  def slash_command
    @slash_command ||= ENV.fetch('SLACK_SLASH_COMMAND', 'hack')
  end

  def database_url
    @database_url ||= ENV.fetch('DATABASE_URL', "postgres://localhost/slack_hack_#{env}")
  end

  def env
    ENV.fetch('RACK_ENV', :development).to_sym
  end
end
