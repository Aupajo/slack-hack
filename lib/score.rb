Score = Struct.new(:id, :count) do
  def slack_user_id
    id ? "<@#{id}>" : "(Anonymous)"
  end

  def <=> (other)
    other.count <=> count
  end
end
