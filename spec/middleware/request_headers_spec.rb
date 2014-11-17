RSpec.describe Faraday::Conductivity::RequestHeaders do

  it "includes the mimetype specified" do
    connection = create_connection do |faraday|
      faraday.request :request_headers, :accept => "application/json", :x_version_number => "123"
    end
    request_headers = connection.get("/test").env[:request_headers]

    expect(request_headers["Accept"]).to eq "application/json"
    expect(request_headers["X-Version-Number"]).to eq "123"
  end

  it "doesn't override locally specified headers" do
    connection = create_connection do |faraday|
      faraday.request :request_headers, :accept => "application/json"
    end
    response = connection.get("/test") do |request|
      request.headers[:accept] = "application/xml"
    end

    request_headers = response.env[:request_headers]

    expect(request_headers["Accept"]).to eq "application/xml"
  end

end
