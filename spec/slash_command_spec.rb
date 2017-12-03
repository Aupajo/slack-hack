require 'rack/test'
require 'server'
require 'config'

RSpec.describe 'Slash command' do
  let(:config) { Config.new }
  let(:app) { Server.new(config) }
  include Rack::Test::Methods

  before do
    tables = config.database.tables - [:schema_info]
    tables.each { |table| config.database[table].truncate }
  end

  it 'returns a 401 if the Slack verification token is incorrect' do
    config.verification_token = 'apples'
    expect(post('/hack', token: 'oranges').status).to eq 401
  end

  it 'returns an acknowledgement' do
    config.verification_token = 'apples'
    config.acknowledgement = '%{victim} was pwned by %{attacker}'

    payload = slack_payload(
      token: "apples",
      user_id: "U2147483697",
      text: "<@U012ABCDEF|ernie>"
    )

    post('/hack', payload)

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq 'application/json'
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      {
        response_type: "in_channel",
        text: "<@U2147483697> was pwned by <@U012ABCDEF>"
      }
    )
  end

  it 'returns an anonymous acknowledgement' do
    config.verification_token = 'secret'
    config.acknowledgement = '%{victim} was pwned by %{attacker}'

    payload = slack_payload(token: "secret", user_id: "U2147483697", text: "")
    post('/hack', payload)

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq 'application/json'
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      {
        response_type: "in_channel",
        text: "<@U2147483697> was pwned by someone"
      }
    )
  end

  it 'returns an anonymous acknowledgement' do
    config.verification_token = 'secret'

    post('/hack', slack_payload(token: "secret", user_id: "A", text: "<@B>"))
    post('/hack', slack_payload(token: "secret", user_id: "B", text: "<@C>"))
    post('/hack', slack_payload(token: "secret", user_id: "A", text: "<@C>"))
    post('/hack', slack_payload(token: "secret", user_id: "A", text: ""))

    post('/hack', slack_payload(token: "secret", user_id: "A", text: "leaderboard"))

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq 'application/json'

    expected_body = <<~LEADERBOARD.strip
      *Most hacks*
      <@C>: 2
      (Anonymous): 1
      <@B>: 1

      *Most hacked*
      <@A>: 3
      <@B>: 1
    LEADERBOARD

    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      {
        response_type: "ephemeral",
        text: expected_body
      }
    )
  end

  def slack_payload(**params)
    {
      token: "secret",
      team_id: "T0001",
      team_domain: "example",
      enterprise_id: "E0001",
      enterprise_name: "Globular%20Construct%20Inc",
      channel_id: "C2147483705",
      channel_name: "test",
      user_id: "U2147483697",
      user_name: "Steve",
      command: "/hack",
      text: "",
      response_url: "https://hooks.slack.com/commands/1234/5678",
      trigger_id: "13345224609.738474920.8088930838d88f008e0",
    }.merge(params)
  end
end
