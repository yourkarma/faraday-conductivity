require 'spec_helper'

describe Faraday::Conductivity::UserAgent do

  subject(:user_agent) { response.env[:request_headers]["User-Agent"] }

  it "includes the name and version of the app" do
    user_agent.should start_with "MarketingSite/1.1"
  end

  it "includes the current ruby version" do
    user_agent.should include RUBY_VERSION
  end

  it "includes the current ruby engine" do
    user_agent.should include RUBY_ENGINE
  end

  it "includes the current ruby patch level" do
    user_agent.should include RUBY_PATCHLEVEL.to_s
  end

  it "includes the platform" do
    user_agent.should include RUBY_PLATFORM
  end

  it "includes the pid" do
    user_agent.should include "1337"
  end

  it "includes the current host" do
    user_agent.should include "my.hostname"
  end

  it "includes the current user name" do
    user_agent.should include "linus"
  end

  let(:environment) {
    double :environment, :login => "linus", :hostname => "my.hostname", :pid => 1337
  }

  def connection
    create_connection do |faraday|
      faraday.request :user_agent, :app => "MarketingSite", :version => "1.1", :environment => environment
    end
  end

end
