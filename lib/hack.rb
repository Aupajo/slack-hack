class Hack
  attr_reader :attacker_id, :victim_id

  def initialize(attacker_id:, victim_id:)
    @attacker_id, @victim_id = attacker_id, victim_id
  end

  def persist!(database)
    database[:hacks].insert(victim_id: victim_id, attacker_id: attacker_id)
  end

  def acknowledgement_message
    message = "<@#{victim_id}> left their computer unattended!"

    if attacker_id
      message << " <@#{attacker_id}> scored a point."
    end

    message
  end
end
