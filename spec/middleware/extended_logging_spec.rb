require 'spec_helper'
require 'logger'

describe Faraday::Conductivity::ExtendedLogging do

  subject(:log) { io.read }

  it "includes the HTTP verb" do
    log.should include "GET"
  end

  it "includes the request body" do
    log.should include "the request body"
  end

  it "includes the request headers" do
    log.should match %r"X-Foo\s+: bar"
  end

  it "includes the complete URL" do
    log.should include "http://widgets.example.org/test"
  end

  it "includes the response status" do
    log.should include "200"
  end

  it "includes the response time" do
    log.should match(/\d+\.\d+ms/)
  end

  it "includes the response headers" do
    log.should include "X-Bar : foo"
  end

  it "includes the response body" do
    log.should include "the response body"
  end

  before do
    perform_request
    io.rewind
  end

  let(:io) { StringIO.new }
  let(:logger) { Logger.new(io) }

  def perform_request
    connection.get("/test") do |request|
      request.headers["X-Foo"] = "bar"
      request.body = "the request body"
    end
  end

  def connection
    create_connection do |faraday|
      faraday.use :extended_logging, :logger => logger
    end
  end

end
