require 'rack'
require 'json'
require 'slack_user_id'

class Server
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.params.fetch('token') != config.verification_token
      [401, {}, ['Not authorized']]
    else
      message = request.params.fetch('text')

      if message.strip.split(/\s/).first == 'leaderboard'
        lines = []

        lines << "*Most hacks*"

        config.database[:hacks].group_and_count(:attacker_id).sort { |a, b| b[:count] <=> a[:count] }.each do |data|
          name = data[:attacker_id] ? "<@#{data[:attacker_id]}>" : "(Anonymous)"
          count = data[:count]
          lines << "#{name}: #{count}"
        end

        lines << "\n*Most hacked*"

        config.database[:hacks].group_and_count(:victim_id).sort { |a, b| b[:count] <=> a[:count] }.each do |data|
          name = "<@#{data[:victim_id]}>"
          count = data[:count]
          lines << "#{name}: #{count}"
        end

        data = {
          response_type: "ephemeral",
          text: lines.join("\n")
        }
      else
        victim_id = request.params.fetch('user_id')
        victim = "<@#{victim_id}>"

        attacker_id = SlackUserID.parse(message)

        config.database[:hacks].insert(victim_id: victim_id, attacker_id: attacker_id)

        attacker = attacker_id ? "<@#{attacker_id}>" : "someone"

        acknowledgement = config.acknowledgement % { victim: victim, attacker: attacker }

        data = {
          response_type: "in_channel",
          text: acknowledgement
        }
      end

      [200, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
    end
  end
end
