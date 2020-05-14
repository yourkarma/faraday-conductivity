RSpec.describe Faraday::Conductivity::SelectiveErrors do

  subject(:request_headers) { response.env[:request_headers] }

  it "raises an exception if the error is inside the :on argument" do
    apply_selective_errors on: 407..409
    expect { response_with_status(408) }.to raise_error Faraday::ClientError
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
    expect { response_with_status(409) }.to raise_error Faraday::ClientError
  end

  it "raises a resource not found error when the actual status is 404" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(404) }.to raise_error Faraday::ResourceNotFound
  end

  it "raises proxy auth required on 407" do
    apply_selective_errors on: 403..422, except: [408]
    expect { response_with_status(407) }.to raise_error Faraday::ProxyAuthError
  end

  it "stores more information about the request and response" do
    apply_selective_errors on: 403..422, except: [408]
    error = response_with_status(422) rescue $!
    expect(error.message).to eq "GET http://widgets.example.org/test responded with status 422"

    expect(error.request[:url].to_s).to eq "http://widgets.example.org/test"
    expect(error.request[:method]).to eq :get

    expect(error.response[:status]).to eq 422

    expect(error.request[:body]).to eq "the request body"
    expect(error.response[:body]).to eq "the response body"

    expect(error.request[:headers]).to eq "Accept" => "application/json"
    expect(error.response[:headers]).to eq "X-Foo-Bar" => "y"
    expect(error.response_time).to be_a Float
  end

  def apply_selective_errors(options)
    @options = options
  end

  def response_with_status(status)
    stubs = create_stubs do |stub|
      stub.get("/test") { |e| [status, { :x_foo_bar => "y" }, "the response body"] }
    end
    connection = create_connection(stubs) do |faraday|
      faraday.response :selective_errors, @options
    end
    connection.get("/test") do |f|
      f.body = "the request body"
      f.headers = { "Accept" => "application/json" }
    end
  end

end
