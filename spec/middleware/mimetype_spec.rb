RSpec.describe Faraday::Conductivity::Mimetype do

  subject(:request_headers) { response.env[:request_headers] }

  it "includes the mimetype specified" do
    expect(request_headers["Accept"]).to eq mimetype
  end

  let(:mimetype) { "application/vnd.users-v2+json" }

  def connection
    create_connection do |faraday|
      faraday.request :mimetype, :accept => mimetype
    end
  end

end
