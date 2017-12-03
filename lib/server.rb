require 'rack'
require 'json'
require 'slack_user_id'
require 'leaderboard'

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
        body = Leaderboard.new(config.database).to_markdown
      else
        victim_id = request.params.fetch('user_id')
        victim = "<@#{victim_id}>"

        attacker_id = SlackUserID.parse(message)

        config.database[:hacks].insert(victim_id: victim_id, attacker_id: attacker_id)

        attacker = attacker_id ? "<@#{attacker_id}>" : "someone"

        body = config.acknowledgement % { victim: victim, attacker: attacker }
      end

      json = JSON.generate(
        response_type: "in_channel",
        text: body
      )

      [200, { 'Content-Type' => 'application/json' }, [json]]
    end
  end
end
