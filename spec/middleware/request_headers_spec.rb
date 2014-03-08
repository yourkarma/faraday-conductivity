require "spec_helper"

describe Faraday::Conductivity::RequestHeaders do

  it "includes the mimetype specified" do
    connection = create_connection do |faraday|
      faraday.request :request_headers, :accept => "application/json", :x_version_number => "123"
    end
    request_headers = connection.get("/test").env[:request_headers]

    request_headers["Accept"].should eq "application/json"
    request_headers["X-Version-Number"].should eq "123"
  end

  it "doesn't override locally specified headers" do
    connection = create_connection do |faraday|
      faraday.request :request_headers, :accept => "application/json"
    end
    response = connection.get("/test") do |request|
      request.headers[:accept] = "application/xml"
    end

    request_headers = response.env[:request_headers]

    request_headers["Accept"].should eq "application/xml"
  end

end
