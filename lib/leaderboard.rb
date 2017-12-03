require 'score'
require 'leaderboard_markdown'

class Leaderboard
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
