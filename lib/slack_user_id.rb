module SlackUserID
  def self.parse(string)
    return if string.nil?
    detected = string.scan(/\<@(.*?)\>/).flatten.first
    return unless detected
    first_part = detected.split('|', 2).first
    first_part if first_part.match?(/\A[A-z0-9]+\z/)
  end
end
