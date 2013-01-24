require 'spec_helper'

describe Faraday::Conductivity::Mimetype do

  subject(:request_headers) { response.env[:request_headers] }

  it "includes the mimetype specified" do
    request_headers["Accept"].should eq mimetype
  end

  let(:mimetype) { "application/vnd.users-v2+json" }

  def connection
    create_connection do |faraday|
      faraday.request :mimetype, :accept => mimetype
    end
  end

end
