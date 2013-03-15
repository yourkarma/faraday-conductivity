require 'faraday/conductivity'

module SpecHelper

  def response
    connection.get("/test")
  end

  def create_connection
    Faraday.new(url: "http://widgets.example.org") do |faraday|
      yield faraday
      faraday.adapter :test, stubs
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
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include SpecHelper
end

require 'service_double'

$service_double_url = "http://localhost:3434"

$service_double = ServiceDouble.hook_into(:rspec) do |config|
  config.server = File.expand_path('../fake_server.rb', __FILE__)
  config.url = $service_double_url
end
