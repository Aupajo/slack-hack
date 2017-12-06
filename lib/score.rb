Score = Struct.new(:slack_user_id, :count) do
  def <=> (other)
    other.count <=> count
  end
end
