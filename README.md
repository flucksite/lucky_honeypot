# lucky_honeypot

🍯 Simple invisible captcha spam protection for Lucky Framework apps.

> [!Note]
> The original repository is hosted at
> [https://codeberg.org/fluck/lucky_honeypot](https://codeberg.org/fluck/lucky_honeypot).

## How it works

This shard uses three techniques to catch spambots:

1. **Invisible fields**. Bots fill out every field, including ones hidden with CSS.
2. **Timing checks**. Bots submit forms instantly, humans need more time.
3. **Input signals**. Bots don't tend to trigger mouse/touch/scroll/keyboard events.

When either of the two first checks fail, the submission is quietly rejected.
The bot thinks it succeeded and moves on. The third one can be used to reject
submissions at a certain _human rating_ threshold, or to flag entries that may
be suspicious.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     lucky_honeypot:
       codeberg: fluck/lucky_honeypot
   ```

2. Run `shards install`

## Usage

Require the shard in your `src/shards.cr`:

```crystal
require "lucky_honeypot"
```

Add the honeypot to the form you would like to protect:

```crystal
class SignUps::NewPage < AuthLayout
  include LuckyHoneypot::Tag

  def content
    form_for SignUps::Create do
      # ...
      honeypot_input "user:website"
      # ...
    end
  end
end
```

> [!TIP]
> The name of the honeypot input can be anything, but it's best to keep it in
> line with the rest of the fields in your form, so it looks believable.

Finally, configure the honeypot in the receiving action:

```crystal
class SignUps::Create < BrowserAction
  include LuckyHoneypot::Pipe

  honeypot "user:website"

  post "/sign_up" do
    # ...
  end
end
```

That's it! Your form is now protected.

### Configuring the input

The `honeypot_input` is good to go out of the box, but there are some things to
consider. By default, it is rendered with a `style` attribute to make it
inaccessible for humans, so they don't accidentally fill it out. By passing a
class attribute, it is assumed that you're using your own CSS class to hide the
input:

```crystal
honeypot_input "user:website", class: "visually-hidden"
```

> [!IMPORTANT]
> When a `class` attribute is passed, the default `style` attribute won't be
> rendered. However, you can pass your own `style` attribute as well.

Aside from the special `class` attribute, you can pass any other attribute as
well:

```crystal
honeypot_input "user:website", data_purpose: "not for humans"
```

> [!NOTE]
> The `honeypot_input` macro method will also set a timestamp in the session to
> verify submission timing. Consider this when you add your own field instead
> of using this macro.

### Configuring the submission delay

```crystal
Habitat.configure do |settings|
  # Default required delay between page load and form submission.
  setting.default_delay = 2.seconds

  # Disables the submission delay entirely; useful in test environments.
  setting.disable_delay = false
end
```

### Configuring the pipe

The `honeypot` macro does two things:

1. Ensure the declared honeypot field is not filled
2. Ensure the form was not submitted too quickly

The default timing for the form submission is 2 seconds, but that can be
configured:

```crystal
honeypot "user:website", wait: 5.seconds
# or
honeypot "user:website", wait: 1_500.milliseconds
```

> [!TIP]
> The ideal timing will depend on the length of your form. Do some testing to
> see how fast you can fill out the form, and use that as the baseline.

If a honeypot is filled or submitted too quickly, a `head 204 (No Content)` will
be returned. This is common behaviour for honeypots. The bot will assume the
submission was successful and move on to its next target. If you want to
handle it differently, can can pass a block with the desired response:

```crystal
honeypot "user:website" do
  flash.info = "Moving on..."
  redirect to: Home::Index, status: HTTP::Status::SEE_OTHER
end
```

Finally, you can also add multiple honeypots, each with their own timing and
HTTP handling:

```crystal
honeypot "user:website", wait: 5.seconds
honeypot "note" do
  html Bot::IndexPage
end
```

## Detecting input signals

This shard comes with simple input signals detection built-in. It monitors
mouse movements, touch gestures, scroll triggers, and keyboard input. If any of
those are detected, it adds to the likeliness of human interaction.

To track the input signals, add the `honeypot_signals` tag to your form:

```crystal
honeypot_signals
```

Similar to the `honeypot_input` tag, it accepts a custom name and additional
attributes:

```crystal
honeypot_signals "user:signals", data_some: "value"
```

The signals tag only tracks input signals and stores the result in a hidden
field that is submitted with the form. It is up to you what to do with the
information. For example, you could render a `head 204` if the human rating is
below a certain threshold:

```crystal
class SignUps::Create < BrowserAction
  include LuckyHoneypot::Pipe

  post "/sign_up" do
    # ...
  end

  private def honeypot_signals(rating : Float64)
    if rating < 0.25
      head 204
    else
      continue
    end
  end
end
```

Or you could use it to flag a record in case of a suspicious submission:

```crystal
if LuckyHoneypot::Signals.human_rating(params.get(:honeypot_signals)) < 0.25
  # Do your thing
end
```

And if you want more information about which inputs where triggered:

```crystal
signals = LuckyHoneypot::Signals.from_json(params.get(:honeypot_signals))
signals.human_rating  # a value between 0 (bot) and 1 (human)
signals.m?            # if true, the mouse was moved
signals.t?            # if true, a touch gesture was detected
signals.s?            # if true, a scroll was triggered
signals.k?            # if true, keyboard input was detected
```

> [!NOTE]
> The human rating is calculated by averaging the `true` values. So `0` is most
> certainly a bot, `0.25` might as well be a human if they only used the
> keyboard and didn't scroll. In practice, this is unlikely unless a from is at
> the top of the page. Realistically, 0.5 is a good threshold because mouse,
> scroll and keyboard are triggered in most cases on desktop, and on mobile all
> four.

## Security considerations

This shard provides basic bot protection, but it should not be your only line of
defense. Here are few important points to consider:

- It's not foolproof and sophisticated bots can bypass honeypots
- Combine this with Lucky's built-in rate limiting feature
- For high-value forms, consider adding CAPTCHA or email verification

For most use cases (contact forms, newsletter signups, etc.), this shard
provides excellent protection with zero user friction. By adding a honeypot,
you'll catch between 60% and 90% of all automated form submissions.

If you want protection from more sophisticated bots, have a look at the
[Prosopo shard](https://codeberg.org/fluck/prosopo) or the [hCaptcha
shard](https://codeberg.org/fluck/hcaptcha).

## Contributing

We use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
for our commit messages, so please adhere to that pattern.

1. Fork it (<https://codeberg.org/fluck/lucky_honeypot/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'feat: add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Wout](https://codeberg.org/w0u7) - creator and maintainer
