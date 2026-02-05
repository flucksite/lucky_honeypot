require "habitat"

module LuckyHoneypot
  SESSION_KEY_PREFIX = "honeypot_timestamp"

  Habitat.create do
    # Default required delay between page load and form submission.
    setting default_delay : Time::Span = 2.seconds

    # Disables the submission delay entirely; useful in test environments.
    setting disable_delay : Bool = false

    # Name of the signals input field
    setting signals_input_name : String = "honeypot_signals"
  end
end
