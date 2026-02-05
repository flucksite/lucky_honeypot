require "lucky"
require "../spec_helper"

describe LuckyHoneypot::Tag do
  describe "#honeypot_input" do
    it "renders a honeypot with a default style attibute" do
      html = LuckyHoneypotTagWithStyleTestPage.new(test_context).render.to_s

      html.should contain(%(name="user:name" type="text"))
      html.should contain(%(aria-hidden="true" tabindex="-1" autocomplete="off"))
      html.should contain(
        %(style="position:absolute;left:-9999px;width:1px;height:1px;pointer-events:none;")
      )
    end

    it "sets a timestamp in the session" do
      page = LuckyHoneypotTagWithStyleTestPage.new(test_context)
      page.render.to_s

      timestamp = page.context.session.get(:honeypot_timestamp_user_name)
      timestamp.size.should eq(13)
      timestamp.to_i64.should be <= Time.utc.to_unix_ms
    end

    it "renders a honeypot with a class and no style attibute" do
      html = LuckyHoneypotTagWithClassTestPage.new(test_context).render.to_s

      html.should contain(%(class="visually-hidden"))
      html.should_not contain(%(style="))
    end

    it "renders a honeypot with a custom style attibute" do
      html = LuckyHoneypotTagWithCustomStyleTestPage.new(test_context).render.to_s

      html.should contain(%(style="display:none"))
      html.should_not contain(%(style="position:absolute;left:-9999px))
    end

    it "renders a honeypot with a additional attributes" do
      html = LuckyHoneypotTagWithAdditionalAttributesTestPage.new(test_context).render.to_s

      html.should contain(%(data-very="lukcy"))
    end
  end

  describe "#honeypot_signals" do
    it "renders a honeypot signals tag" do
      html = LuckyHoneypotSignalsTestPage.new(test_context).render.to_s

      html.should contain(%(name="honeypot_signals"))
      html.should contain(%(id="honeypot_signals"))
      html.should contain(%(document.querySelector('#honeypot_signals')))
    end
  end
end

abstract class LuckyHoneypotBaseTestPage
  include Lucky::HTMLPage
  include LuckyHoneypot::Tag

  abstract def render
end

class LuckyHoneypotTagWithStyleTestPage < LuckyHoneypotBaseTestPage
  def render
    honeypot_input("user:name")
    view
  end
end

class LuckyHoneypotTagWithClassTestPage < LuckyHoneypotBaseTestPage
  def render
    honeypot_input("user:name", class: "visually-hidden")
    view
  end
end

class LuckyHoneypotTagWithCustomStyleTestPage < LuckyHoneypotBaseTestPage
  def render
    honeypot_input("user:name", style: "display:none")
    view
  end
end

class LuckyHoneypotTagWithAdditionalAttributesTestPage < LuckyHoneypotBaseTestPage
  def render
    honeypot_input("user:name", data_very: "lukcy")
    view
  end
end

class LuckyHoneypotSignalsTestPage < LuckyHoneypotBaseTestPage
  def render
    honeypot_signals
    view
  end
end

private def test_context : HTTP::Server::Context
  io = IO::Memory.new
  request = HTTP::Request.new("GET", "/")
  response = HTTP::Server::Response.new(io)
  HTTP::Server::Context.new request, response
end
