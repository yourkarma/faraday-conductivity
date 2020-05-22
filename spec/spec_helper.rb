require 'faraday/conductivity'

module SpecHelper

  def response
    connection.get("/test")
  end

  def create_connection(the_stubs = stubs)
    Faraday.new(url: "http://widgets.example.org") do |faraday|
      yield faraday
      faraday.adapter :test, the_stubs
    end
  end

  def stubs
    @stubs ||= create_stubs do |stub|
      stub.get('/test') { |env| [200, {"X-Bar" => "foo"} , "the response body"] }
    end
  end

  def create_stubs
    Faraday::Adapter::Test::Stubs.new do |stub|
      yield stub
    end
  end

end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include SpecHelper
end
