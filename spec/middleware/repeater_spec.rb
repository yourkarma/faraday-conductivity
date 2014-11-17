RSpec.describe Faraday::Conductivity::Repeater do

  let(:connection) {
    Faraday.new(url: $service_double_url) { |faraday|
      faraday.use :repeater, mode: :rapid, retries: 6
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    }
  }

  it "retries after timeouts" do
    expect(get_with_max(4).body).to eq "fast"
  end

  it "gives up after a number of retries" do
    expect { get_with_max(20) }.to raise_error(Faraday::Error::TimeoutError)
  end

  class MyPattern

    def initialize
      @waited = []
    end

    attr_reader :waited

    def wait(x)
      waited << x
    end

  end

  it "waits according to a pattern" do
    pattern = MyPattern.new
    expect(Faraday::Conductivity::Repeater::Pattern).to receive(:new).and_return(pattern)
    get_with_max(6)
    expect(pattern.waited).to eq pattern.waited.sort
  end

  it "handles other errors too" do
    connection = Faraday.new(url: "http://blabla.bla") { |faraday|
      faraday.use :repeater, mode: :rapid, retries: 2
      faraday.adapter Faraday.default_adapter
    }

    pattern = double :pattern
    expect(Faraday::Conductivity::Repeater::Pattern).to receive(:new).and_return(pattern)
    expect(pattern).to receive(:wait).with(1).ordered
    expect(pattern).to receive(:wait).with(2).ordered

    expect { connection.get("/") }.to raise_error(Faraday::Error::ConnectionFailed)
  end

  def get_with_max(num)
    connection.get("/unreliable/#{num}") { |req|
      req.options[:timeout] = 1
      req.options[:open_timeout] = 1
    }
  end

end
