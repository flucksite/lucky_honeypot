require "../spec_helper"

describe LuckyHoneypot::Signals do
  describe ".from_json" do
    it "is initialized from a JSON object" do
      signals = LuckyHoneypot::Signals.from_json(test_signals_json(m: true))

      signals.mouse?.should be_true
      signals.touch?.should be_false
      signals.scroll?.should be_false
      signals.keyboard?.should be_false
      signals.focus?.should be_false
    end
  end

  describe "#human_rating" do
    it "calculates a human rating based on the given signals" do
      LuckyHoneypot::Signals.from_json(test_signals_json).human_rating
        .should eq(0)
      LuckyHoneypot::Signals.from_json(test_signals_json(m: true)).human_rating
        .should eq(0.2)
      LuckyHoneypot::Signals.from_json(test_signals_json(m: true, t: true)).human_rating
        .should eq(0.4)
    end

    it "returns 1.0 when all signals are true" do
      LuckyHoneypot::Signals.from_json(test_signals_json(m: true, t: true, s: true, k: true, f: true)).human_rating
        .should eq(1.0)
    end
  end

  describe "invalid JSON" do
    it "raises on invalid JSON" do
      expect_raises(JSON::ParseException) do
        LuckyHoneypot::Signals.from_json("not json")
      end
    end

    it "raises on missing keys" do
      expect_raises(JSON::ParseException) do
        LuckyHoneypot::Signals.from_json(%({"m": true}))
      end
    end
  end

  describe ".human_rating" do
    it "calculates a human rating based on the given signals" do
      LuckyHoneypot::Signals.human_rating(test_signals_json(k: true))
        .should eq(0.2)
    end
  end
end

private def test_signals_json(
  m = false,
  t = false,
  s = false,
  k = false,
  f = false,
)
  {m: m, t: t, s: s, k: k, f: f}.to_json
end
