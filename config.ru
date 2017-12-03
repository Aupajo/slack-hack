require_relative 'config/environment'

config = Config.new

run Server.new(config)
