$LOAD_PATH << "lib"
require 'server'
require 'config'

config = Config.new
config.verification_token = ENV.fetch('SLACK_VERIFICATION_TOKEN')
config.slash_command = ENV.fetch('SLACK_SLASH_COMMAND')
config.acknowledgement = ENV.fetch('HACK_ACKNOWLEDGEMENT')

run Server.new(config)
