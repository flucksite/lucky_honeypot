require "json"

struct LuckyHoneypot::Signals
  include JSON::Serializable

  # Mouse movement
  getter m : Bool
  # touch gesture
  getter t : Bool
  # Scroll trigger
  getter s : Bool
  # Keyboard input
  getter k : Bool

  # Calculates the likelyhood of a human (0 being a bot, 1 being a human). Any
  # value above 0 is already a good chance.
  def human_rating : Float64
    [m, t, s, k].count { |f| f } / 4
  end

  # Convenience method to caclulate the human rating form a class method.
  def self.human_rating(json : String) : Float
    from_json(json).human_rating
  end
end
