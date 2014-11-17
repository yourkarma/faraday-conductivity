RSpec.describe Faraday::Conductivity::UserAgent do

  subject(:user_agent) { response.env[:request_headers]["User-Agent"] }

  it "includes the name and version of the app" do
    expect(user_agent).to start_with "MarketingSite/1.1"
  end

  it "includes the current ruby version" do
    expect(user_agent).to include RUBY_VERSION
  end

  it "includes the current ruby engine" do
    expect(user_agent).to include RUBY_ENGINE
  end

  it "includes the current ruby patch level" do
    expect(user_agent).to include RUBY_PATCHLEVEL.to_s
  end

  it "includes the platform" do
    expect(user_agent).to include RUBY_PLATFORM
  end

  it "includes the pid" do
    expect(user_agent).to include "1337"
  end

  it "includes the current host" do
    expect(user_agent).to include "my.hostname"
  end

  it "includes the current user name" do
    expect(user_agent).to include "linus"
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
