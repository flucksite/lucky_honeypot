module LuckyHoneypot::Tag
  # Renders a visually hidden honeypot input tag with the given name. Any
  # additional named arguments will be rendered as attributes.
  macro honeypot_input(name, **named_args)
    context.session.set(
      "{{ LuckyHoneypot::SESSION_KEY_PREFIX.id }}_{{ name.gsub(/\:/, "_").id }}",
      Time.utc.to_unix_ms.to_s
    )
    input(
      name: {{ name }},
      type: "text",
      aria_hidden: true,
      tabindex: -1,
      autocomplete: "off",
      {% unless named_args.has_key?(:class) || named_args.has_key?(:style) %}
        style: "position:absolute;left:-9999px;width:1px;height:1px;pointer-events:none;",
      {% end %}
      {{ named_args.double_splat }}
    )
  end

  # Renders and input and an input tracking script detecting mouse movements,
  # touch gestures, keyboard input, and scroll triggers.
  macro honeypot_signals(
    name = LuckyHoneypot.settings.signals_input_name,
    **named_args,
  )
  input(name: {{name}}, type: "hidden", {{ named_args.double_splat }})
    script do
      raw <<-JS
        (() => {
          const s = { m: false, t: false, s: false, k: false }
          const input = document.currentScript.previousElementSibling
          const form = input.form
          form.addEventListener('mousemove', () => s.m = true, { once: true })
          form.addEventListener('touchstart', () => s.t = true, { once: true })
          form.addEventListener('keydown', () => s.k = true, { once: true })
          window.addEventListener('scroll', () => s.s = true, { once: true })
          form.addEventListener('submit', () => input.value = JSON.stringify(s))
        })();
      JS
    end
  end
end
