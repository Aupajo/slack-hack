class LeaderboardMarkdown
  attr_reader :leaderboard

  def initialize(leaderboard)
    @leaderboard = leaderboard
  end

  def to_s
    <<~MARKDOWN
      *Most hacks*
      #{formatted_scores_for :attackers}

      *Most hacked*
      #{formatted_scores_for :victims}
    MARKDOWN
  end

  private

  def formatted_scores_for(resource)
    leaderboard.send(resource).map(&method(:formatted_score)).join("\n")
  end

  def formatted_score(score)
    "#{score.slack_user_id}: #{score.count}"
  end
end
