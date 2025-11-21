require "lucky"
require "../../lib/lucky/spec/support/context_helper"
require "../spec_helper"

include ContextHelper

describe LuckyHoneypot::Pipe do
  it "halts with a filled honeypot" do
    body = URI::Params.encode({"user:website" => "https://spam.bot"})
    request = HTTP::Request.new("POST", "/honeypot", headers: headers, body: body)
    context = build_context(request)
    context.session.set(:honeypot_timestamp_user_website, Time.utc.to_unix_ms.to_s)

    sleep 101.milliseconds

    route = HoneypotWithDefaults::Create.new(context, params).call

    route.context.response.status.should eq(HTTP::Status::NO_CONTENT)
    context.session.get?(:honeypot_timestamp_user_website).should be_nil
  end

  it "halts with a fast submission" do
    request = HTTP::Request.new("POST", "/honeypot", headers: headers)
    context = build_context(request)
    context.session.set(:honeypot_timestamp_user_website, Time.utc.to_unix_ms.to_s)

    sleep 50.milliseconds

    route = HoneypotWithDefaults::Create.new(context, params).call

    route.context.response.status.should eq(HTTP::Status::NO_CONTENT)
    context.session.get?(:honeypot_timestamp_user_website).should be_nil
  end

  it "accepts a submission with an empty honeypot and a proper delay" do
    body = URI::Params.encode({"user:website" => ""})
    request = HTTP::Request.new("POST", "/honeypot", headers: headers, body: body)
    context = build_context(request)
    context.session.set(:honeypot_timestamp_user_website, Time.utc.to_unix_ms.to_s)

    sleep 101.milliseconds

    route = HoneypotWithDefaults::Create.new(context, params).call

    route.context.response.status.should eq(HTTP::Status::OK)
    context.session.get?(:honeypot_timestamp_user_website).should be_nil
  end

  it "allows custom http handling" do
    request = HTTP::Request.new("POST", "/honeypot_with_block", headers: headers)
    context = build_context(request)
    context.session.set(:honeypot_timestamp_user_website, Time.utc.to_unix_ms.to_s)

    route = HoneypotWithCustomBlock::Create.new(context, params).call
    route.context.response.status.should eq(HTTP::Status::SEE_OTHER)
  end
end

abstract class TestAction < Lucky::Action
  include Lucky::EnforceUnderscoredRoute
  accepted_formats [:html], default: :html
end

class HoneypotWithDefaults::Create < TestAction
  include LuckyHoneypot::Pipe

  honeypot "user:website", wait: 100.milliseconds

  post "/honeypot" do
    plain_text "hello"
  end
end

class HoneypotWithCustomBlock::Create < TestAction
  include LuckyHoneypot::Pipe

  honeypot "user:website", wait: 100.milliseconds do
    redirect to: HoneypotWithCustomBlock::Create.path, status: HTTP::Status::SEE_OTHER
  end

  post "/honeypot_with_block" do
    plain_text "hello"
  end
end

private def headers
  headers = HTTP::Headers.new
  headers["X_FORWARDED_FOR"] = "127.0.0.1"
  headers["Content-Type"] = "application/x-www-form-urlencoded"
  headers
end
