require 'rack'
require 'json'

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
      victim = "<@#{request.params.fetch('user_id')}>"
      attacker = request.params.fetch('text')

      acknowledgement = config.acknowledgement % { victim: victim, attacker: attacker }

      body = JSON.generate(
        response_type: "in_channel",
        text: acknowledgement
      )

      [200, { 'Content-Type' => 'application/json' }, [body]]
    end
  end
end
