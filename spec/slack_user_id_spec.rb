require 'slack_user_id'

RSpec.describe SlackUserID do
  it 'can parse a Slack user ID' do
    {
      nil => nil,
      ''  => nil,
      ' ' => nil,
      'no username here' => nil,
      '<@plainuserid>' => 'plainuserid',
      'there is a <@userid|with_pipe> here' => 'userid',
      '<not_a_user_id>' => nil,
      '<@almost a user id>' => nil,
      '<@first> and <@second>' => 'first'
    }.each do |input, output|
      expect(SlackUserID.parse(input)).to eq output
    end
  end
end
