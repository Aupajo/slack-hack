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

    return NOT_AUTHORIZED_RESPONSE if token_invalid?

    if leaderboard_requested?
      leaderboard_message
    else
      record_and_acknowledge_hack!
    end
  end

  private

  def leaderboard_message
    message = Leaderboard.new(config.database).to_markdown
    slack_response(message, response_type: "ephemeral")
  end

  def record_and_acknowledge_hack!
    victim_id = request.params.fetch('user_id')
    attacker_id = SlackUserID.parse(slash_message_content)

    begin
      hack = Hack.new(attacker_id: attacker_id, victim_id: victim_id)
      hack.persist!(config.database)
      slack_response(hack.acknowledgement_message)
    rescue Hack::SelfHackError
      slack_response("You can't hack yourself!", response_type: "ephemeral")
    end
  end

  def slack_response(body, response_type: "in_channel")
    json_response(response_type: response_type, text: body)
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
