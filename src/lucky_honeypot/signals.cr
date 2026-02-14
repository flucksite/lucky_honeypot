require "json"

struct LuckyHoneypot::Signals
  include JSON::Serializable

  @[JSON::Field(key: "m")]
  getter? mouse : Bool
  @[JSON::Field(key: "t")]
  getter? touch : Bool
  @[JSON::Field(key: "s")]
  getter? scroll : Bool
  @[JSON::Field(key: "k")]
  getter? keyboard : Bool
  @[JSON::Field(key: "f")]
  getter? focus : Bool

  # Calculates the likelyhood of a human (0 being a bot, 1 being a human). Any
  # value above 0 is already a good chance.
  def human_rating : Float64
    [mouse?, touch?, scroll?, keyboard?, focus?].count(&.itself) / 5
  end

  # Convenience method to caclulate the human rating form a class method.
  def self.human_rating(json : String) : Float
    from_json(json).human_rating
  end
end
