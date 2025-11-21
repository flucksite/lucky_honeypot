module LuckyHoneypot::Pipe
  macro honeypot(name, wait = 1.second, &block)
    {%
      session_key = "#{LuckyHoneypot::SESSION_KEY_PREFIX.id}_#{name.id}"
      method_name = %(reject_#{name.gsub(/\:/, "_").id}_honeypot).id
    %}

    before {{method_name}}

    private def {{method_name}}
      if honeypot_not_filled?({{name}}) &&
         honeypot_timespan_elapsed?({{session_key}}, {{wait}})
        session.delete({{session_key}})
        continue
      else
        {% if block.nil? %}
          head HTTP::Status::NO_CONTENT
        {% else %}
          {{block.body}}
        {% end %}
      end
    end
  end

  private def honeypot_not_filled?(name : String) : Bool
    params.get?(name).nil? || params.get(name).blank?
  end

  private def honeypot_timespan_elapsed?(
    key_name : String,
    wait : Time::Span,
  ) : Bool
    return false unless timestamp = session.get?(key_name).try(&.to_i64)

    wait < (Time.utc.to_unix_ms - timestamp).seconds
  end
end
