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

  # Calculates the likelihood of a human (0 being a bot, 1 being a human).
  def human_rating : Float64
    [mouse?, touch?, scroll?, keyboard?, focus?].count(&.itself) / 5.0
  end

  # Convenience method to calculate the human rating for a class method.
  def self.human_rating(json : String) : Float64
    from_json(json).human_rating
  end
end
