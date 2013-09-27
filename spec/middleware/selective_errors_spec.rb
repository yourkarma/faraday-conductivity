require 'spec_helper'

describe Faraday::Conductivity::SelectiveErrors do

  subject(:request_headers) { response.env[:request_headers] }

  it "raises an exception if the error is inside the :on argument" do
    apply_selective_errors on: 407..409
    expect { response_with_status(408) }.to raise_error Faraday::Error::ClientError
  end

  it "won't raise an exception when outside the range" do
    apply_selective_errors on: 407..409
    expect { response_with_status(410) }.not_to raise_error
  end

  it "won't raise if included in range, but excluded with :except argument" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(408) }.not_to raise_error
  end

  it "raises an exception if included in :on and not included in :except" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(409) }.to raise_error Faraday::Error::ClientError
  end

  it "raises a resource not found error when the actual status is 404" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(404) }.to raise_error Faraday::Error::ResourceNotFound
  end

  it "raises a connection failed on 407" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(407) }.to raise_error Faraday::Error::ConnectionFailed
  end

  def apply_selective_errors(options)
    @options = options
  end

  def response_with_status(status)
    stubs = create_stubs do |stub|
      stub.get("/test") { |e| [status, {}, "response"] }
    end
    connection = create_connection(stubs) do |faraday|
      faraday.response :selective_errors, @options
    end
    connection.get("/test")
  end

end
