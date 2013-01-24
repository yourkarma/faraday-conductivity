require 'spec_helper'

describe Faraday::Conductivity::RequestId do

  subject(:request_headers) { response.env[:request_headers] }

  it "includes the thread local variable" do
    Thread.current[:request_id] = "my-request-id"
    request_headers["X-Request-Id"].should eq "my-request-id"
  end

  it "doesn't add the header if there is no request id" do
    Thread.current[:request_id] = nil
    request_headers.should_not have_key "X-Request-Id"
  end

  def connection
    create_connection do |faraday|
      faraday.request :request_id
    end
  end

end
