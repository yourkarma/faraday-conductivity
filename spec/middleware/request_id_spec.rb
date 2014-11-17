RSpec.describe Faraday::Conductivity::RequestId do

  subject(:request_headers) { response.env[:request_headers] }

  it "includes the thread local variable" do
    Thread.current[:request_id] = "my-request-id"
    expect(request_headers["X-Request-Id"]).to eq "my-request-id"
  end

  it "doesn't add the header if there is no request id" do
    Thread.current[:request_id] = nil
    expect(request_headers).not_to have_key "X-Request-Id"
  end

  def connection
    create_connection do |faraday|
      faraday.request :request_id
    end
  end

end
