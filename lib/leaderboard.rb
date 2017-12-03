require 'leaderboard_markdown'

class Leaderboard
  Score = Struct.new(:id, :count) do
    def slack_user_id
      id ? "<@#{id}>" : "(Anonymous)"
    end

    def <=> (other)
      other.count <=> count
    end
  end

  attr_reader :database

  def initialize(database)
    @database = database
  end

  def to_markdown
    LeaderboardMarkdown.new(self).to_s
  end

  def attackers
    scores_for(:attacker_id)
  end

  def victims
    scores_for(:victim_id)
  end

  private

  def scores_for(column)
    dataset.group_and_count(column).map { |data| Score.new(*data.values) }.sort
  end

  def dataset
    database[:hacks]
  end
end
