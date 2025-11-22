module LuckyHoneypot::Pipe
  macro honeypot(name, wait = 2.seconds, &block)
    {%
      safe_name = name.gsub(/\:/, "_")
      session_key = "#{LuckyHoneypot::SESSION_KEY_PREFIX.id}_#{safe_name.id}"
      method_name = %(reject_#{safe_name.id}_honeypot).id
    %}

    before {{method_name}}

    private def {{method_name}}
      if honeypot_not_filled?({{name}}) &&
         honeypot_timespan_elapsed?({{session_key}}, {{wait}})
        session.delete({{session_key}})
        continue
      else
        context.session.set({{session_key}}, Time.utc.to_unix_ms.to_s)
        {% if block.nil? %}
          response.status = HTTP::Status::NO_CONTENT
          plain_text ""
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

    wait < (Time.utc.to_unix_ms - timestamp).milliseconds
  end
end
