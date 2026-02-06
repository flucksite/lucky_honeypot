require "../spec_helper"

describe LuckyHoneypot::Signals do
  describe ".from_json" do
    it "is initialized from a JSON object" do
      signals = LuckyHoneypot::Signals.from_json(test_signals_json(m: true))

      signals.m?.should be_true
      signals.t?.should be_false
      signals.s?.should be_false
      signals.k?.should be_false
    end
  end

  describe "#human_rating" do
    it "calculates a human rating based on the given signals" do
      LuckyHoneypot::Signals.from_json(test_signals_json).human_rating
        .should eq(0)
      LuckyHoneypot::Signals.from_json(test_signals_json(m: true)).human_rating
        .should eq(0.25)
      LuckyHoneypot::Signals.from_json(test_signals_json(m: true, t: true)).human_rating
        .should eq(0.5)
    end
  end

  describe ".human_rating" do
    it "calculates a human rating based on the given signals" do
      LuckyHoneypot::Signals.human_rating(test_signals_json(k: true))
        .should eq(0.25)
    end
  end
end

private def test_signals_json(m = false, t = false, s = false, k = false)
  {m: m, t: t, s: s, k: k}.to_json
end
