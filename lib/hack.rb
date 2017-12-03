class Hack
  attr_reader :attacker_id, :victim_id

  def initialize(attacker_id:, victim_id:)
    @attacker_id, @victim_id = attacker_id, victim_id
  end

  def persist!(database)
    database[:hacks].insert(victim_id: victim_id, attacker_id: attacker_id)
  end

  def acknowledgement_message(template)
    victim = "<@#{victim_id}>"
    attacker = attacker_id ? "<@#{attacker_id}>" : "someone"
    template % { victim: victim, attacker: attacker }
  end
end
