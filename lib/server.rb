require 'rack'
require 'json'
require 'slack_user_id'
require 'leaderboard'
require 'hack'

class Server
  NOT_AUTHORIZED_RESPONSE = [401, {}, ['Not authorized']]

  attr_reader :config, :request, :hack

  def initialize(config)
    @config = config
  end

  def call(env)
    @request = Rack::Request.new(env)

    if token_invalid?
      NOT_AUTHORIZED_RESPONSE
    else
      if leaderboard_requested?
        body = Leaderboard.new(config.database).to_markdown
      else
        record_hack!
        body = hack.acknowledgement_message(config.acknowledgement)
      end

      json_response(response_type: "in_channel", text: body)
    end
  end

  private

  def record_hack!
    victim_id = request.params.fetch('user_id')
    attacker_id = SlackUserID.parse(slash_message_content)

    @hack = Hack.new(attacker_id: attacker_id, victim_id: victim_id)
    hack.persist!(config.database)
  end

  def json_response(status: 200, **payload)
    body = JSON.generate(payload)
    [status, { 'Content-Type' => 'application/json' }, [body]]
  end

  def token_invalid?
    request.params.fetch('token') != config.verification_token
  end

  def slash_message_content
    request.params.fetch('text').strip
  end

  def leaderboard_requested?
    slash_message_content.split(/\s/).first == 'leaderboard'
  end
end
