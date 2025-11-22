module LuckyHoneypot::Tag
  macro honeypot_input(name, **named_args)
    context.session.set(
      "{{ LuckyHoneypot::SESSION_KEY_PREFIX.id }}_{{ name.gsub(/\:/, "_").id }}",
      Time.utc.to_unix_ms.to_s
    )
    input(
      name: {{ name }},
      type: "text",
      aria_hidden:  true,
      tabindex:     -1,
      autocomplete: "off",
      {% unless named_args.has_key?(:class) || named_args.has_key?(:style) %}
        style: "position:absolute;left:-9999px;width:1px;height:1px;pointer-events:none;",
      {% end %}
      {{ named_args.double_splat }}
    )
  end
end
