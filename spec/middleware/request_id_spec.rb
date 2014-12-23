RSpec.describe Faraday::Conductivity::RequestId do

  subject(:request_headers) { response.env[:request_headers] }

  context "when request_id is set via thread variable" do
    after { Thread.current[:request_id] = nil }

    it "includes the thread local variable" do
      Thread.current[:request_id] = "my-request-id"
      expect(request_headers["X-Request-Id"]).to eq "my-request-id"
    end

    def connection
      create_connection do |faraday|
        faraday.request :request_id
      end
    end
  end

  context "when request id is set via second argument" do
    it "includes the second argument" do
      expect(request_headers["X-Request-Id"]).to eq "my-request-id"
    end

    def connection
      create_connection do |faraday|
        faraday.request :request_id, "my-request-id"
      end
    end
  end

  context "when request id is not set" do
    it "doesn't add the header if there is no request id" do
      expect(request_headers).not_to have_key "X-Request-Id"
    end

    def connection
      create_connection do |faraday|
        faraday.request :request_id
      end
    end
  end
end
