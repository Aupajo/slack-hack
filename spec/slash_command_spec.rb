require 'rack/test'
require 'server'
require 'config'

RSpec.describe 'Slash command' do
  let(:config) { Config.new }
  let(:app) { Server.new(config) }
  include Rack::Test::Methods

  it 'returns a 401 if the Slack verification token is incorrect' do
    config.verification_token = 'apples'
    config.slash_command = 'hack'
    expect(get('/hack', token: 'oranges').status).to eq 401
  end

  it 'returns an acknowledgement' do
    config.verification_token = 'apples'
    config.slash_command = 'hack'
    config.acknowledgement = '%{victim} was pwned by %{attacker}'

    payload = {
      token: "apples",
      team_id: "T0001",
      team_domain: "example",
      enterprise_id: "E0001",
      enterprise_name: "Globular%20Construct%20Inc",
      channel_id: "C2147483705",
      channel_name: "test",
      user_id: "U2147483697",
      user_name: "Steve",
      command: "/weather",
      text: "<@U012ABCDEF|ernie>",
      response_url: "https://hooks.slack.com/commands/1234/5678",
      trigger_id: "13345224609.738474920.8088930838d88f008e0",
    }

    get('/hack', payload)

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq 'application/json'
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      {
        response_type: "in_channel",
        text: "<@U2147483697> was pwned by <@U012ABCDEF|ernie>"
      }
    )
  end

  it 'returns an anonymous acknowledgement' do
    config.verification_token = 'apples'
    config.slash_command = 'hack'
    config.acknowledgement = '%{victim} was pwned by %{attacker}'

    payload = {
      token: "apples",
      team_id: "T0001",
      team_domain: "example",
      enterprise_id: "E0001",
      enterprise_name: "Globular%20Construct%20Inc",
      channel_id: "C2147483705",
      channel_name: "test",
      user_id: "U2147483697",
      user_name: "Steve",
      command: "/weather",
      text: "",
      response_url: "https://hooks.slack.com/commands/1234/5678",
      trigger_id: "13345224609.738474920.8088930838d88f008e0",
    }

    get('/hack', payload)

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq 'application/json'
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      {
        response_type: "in_channel",
        text: "<@U2147483697> was pwned by someone"
      }
    )
  end
end
