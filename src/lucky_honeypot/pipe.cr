module LuckyHoneypot::Pipe
  macro included
    before honeypot_signals_evaluation
  end

  # Declares a before pipe to watch for the submission of a honeypot field, and
  # render No Content if the value is not blank.
  macro honeypot(name, wait = LuckyHoneypot.settings.default_delay, &block)
    {%
      safe_name = name.gsub(/\:/, "_")
      session_key = "#{LuckyHoneypot::SESSION_KEY_PREFIX.id}_#{safe_name.id}"
      method_name = %(reject_#{safe_name.id}_honeypot).id
    %}

    before {{ method_name }}

    private def {{ method_name }}
      if honeypot_not_filled?({{ name }}) &&
         honeypot_timespan_elapsed?({{ session_key }}, {{ wait }})
        session.delete({{ session_key }})
        continue
      else
        context.session.set({{ session_key }}, Time.utc.to_unix_ms.to_s)
        {% if block.nil? %}
          response.status = HTTP::Status::NO_CONTENT
          plain_text ""
        {% else %}
          {{ block.body }}
        {% end %}
      end
    end
  end

  # Tests if a honeypot field is not filled.
  private def honeypot_not_filled?(name : String) : Bool
    params.get?(name).nil? || params.get(name).blank?
  end

  # Tests if the form submission was faster than the configured time span.
  private def honeypot_timespan_elapsed?(
    key_name : String,
    wait : Time::Span,
  ) : Bool
    return true if LuckyHoneypot.settings.disable_delay?
    return false unless timestamp = session.get?(key_name).try(&.to_i64)

    wait < (Time.utc.to_unix_ms - timestamp).milliseconds
  end

  # Calculates the results of the user interaction signals.
  private def honeypot_signals_evaluation
    json = params.get(LuckyHoneypot.settings.signals_input_name)
    honeypot_signals LuckyHoneypot::Signals.from_json(json).human_rating
    continue
  rescue JSON::ParseException | Lucky::MissingParamError
    honeypot_signals 0
    continue
  end

  # Placeholder callback to handle calculated human rating based on signals.
  private def honeypot_signals(rating : Float64) : Void
  end
end
