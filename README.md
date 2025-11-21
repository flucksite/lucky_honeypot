# lucky_honeypot

🍯 Simple invisible captcha spam protection for Lucky Framework apps.

> [!Note]
> The original repository is hosted at
> [https://codeberg.org/fluck/lucky_honeypot](https://codeberg.org/fluck/lucky_honeypot).

## How it works

This shard uses two techniques to catch spambots:

1. Invisible fields. Bots fill out every field, including ones hidden with CSS.
2. Timing checks. Bots submit forms instantly, humans need time to fill them out.

When either check fails, the submission is quietly rejected. The bot thinks it
succeeded and moves on.

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
    form_for SignUps::Create, class: "flow" do
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

- [Wout](https://github.com/your-github-user) - creator and maintainer
