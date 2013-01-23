require "logger"
require "faraday/conductivity"
require "faraday_middleware"
require "json"

# I'm sorry about the state of this test file.
# This will be cleaned up, I promise.

describe Faraday::Conductivity do

  it 'should have a version number' do
    Faraday::Conductivity::VERSION.should_not be_nil
  end

  example "user_agent" do
    connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
      faraday.request :user_agent, app: "MarketingSite", version: "1.1"
    end
    request = connection.get("/foobar")
    request.env[:request_headers]["User-Agent"].should match %r(^MarketingSite/1.1 \([^\s]+; [^\s]+; \d+\) ruby/1.9.3)
  end

  example "extended_logging" do
    io = StringIO.new
    dummy_logger = Logger.new(io)
    request_with do |faraday|
      faraday.use :extended_logging, logger: dummy_logger
    end
    io.rewind
    logged = io.read
    logged.should include "Started GET request"
    logged.should include "http://example.org/test"
    logged.should include "the dummy response"
    logged.should include "the request body"
    logged.should include "X-Response-Header"
    logged.should include "header-value"
    # puts logged
  end

  example "request id" do
    Thread.current[:request_id] = "my-request-id"
    response = request_with do |faraday|
      faraday.request :request_id
    end
    response.env[:request_headers]["X-Request-Id"].should eq "my-request-id"
  end

  example "mimetype" do
    mimetype = "application/vnd.users-v2+json"
    response = request_with do |faraday|
      faraday.request :mimetype, accept: mimetype
    end
    response.env[:request_headers]["Accept"].should eq mimetype
  end

  def request_with
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') { |env| [200, {"X-Response-Header" => "header-value"}, {foo:"the dummy response"}.to_json] }
    end
    connection = Faraday.new(url: "http://example.org/") do |faraday|
      yield faraday
      faraday.adapter :test, stubs
    end
    connection.get("/test") do |req|
      req.body = "the request body"
    end
  end

end
