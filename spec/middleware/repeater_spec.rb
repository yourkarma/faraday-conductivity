require 'spec_helper'

describe Faraday::Conductivity::Repeater do

  let(:connection) {
    Faraday.new(url: $service_double_url) { |faraday|
      faraday.use :repeater, mode: :rapid, retries: 6
      faraday.adapter Faraday.default_adapter
    }
  }

  it "retries after timeouts" do
    get_with_max(4).body.should eq "fast"
  end

  it "gives up after a number of retries" do
    expect { get_with_max(9) }.to raise_error(Faraday::Error::TimeoutError)
  end

  it "waits according to a pattern" do
    pattern = double :pattern
    Faraday::Conductivity::Repeater::Pattern.should_receive(:new).and_return(pattern)
    pattern.should_receive(:wait).with(1).ordered
    pattern.should_receive(:wait).with(2).ordered
    pattern.should_receive(:wait).with(3).ordered
    get_with_max(3)
  end

  it "handles other errors too" do
    connection = Faraday.new(url: "http://blabla.bla") { |faraday|
      faraday.use :repeater, mode: :rapid, retries: 2
      faraday.adapter Faraday.default_adapter
    }

    pattern = double :pattern
    Faraday::Conductivity::Repeater::Pattern.should_receive(:new).and_return(pattern)
    pattern.should_receive(:wait).with(1).ordered
    pattern.should_receive(:wait).with(2).ordered

    expect { connection.get("/") }.to raise_error(Faraday::Error::ConnectionFailed)
  end

  def get_with_max(num)
    connection.get("/unreliable/#{num}") { |req|
      req.options[:timeout] = 1
      req.options[:open_timeout] = 1
    }
  end

end
