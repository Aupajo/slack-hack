require 'rack'
require 'json'
require 'slack_user_id'
require 'leaderboard'
require 'hack'

class Server
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.params.fetch('token') != config.verification_token
      [401, {}, ['Not authorized, invalid verification token']]
    else
      message = request.params.fetch('text')

      if message.strip.split(/\s/).first == 'leaderboard'
        body = Leaderboard.new(config.database).to_markdown
      else
        victim_id = request.params.fetch('user_id')
        attacker_id = SlackUserID.parse(message)

        hack = Hack.new(attacker_id: attacker_id, victim_id: victim_id)
        hack.persist!(config.database)

        body = hack.acknowledgement_message(config.acknowledgement)
      end

      json = JSON.generate(
        response_type: "in_channel",
        text: body
      )

      [200, { 'Content-Type' => 'application/json' }, [json]]
    end
  end
end
