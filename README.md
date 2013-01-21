# Faraday::Conductivity

Extra Faraday Middleware! Geared towards a service oriented architecture.

Here is an overview of my favorite stack. More information about each
middleware is below.

``` ruby
APP_VERSION = IO.popen(["git", "rev-parse", "HEAD", :chdir => Rails.root]).read.chomp

connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|

  # provided by Faraday itself
  faraday.token_auth   "secret"

  # provided by this gem
  faraday.use :extended_logging, logger: Rails.logger

  # provided by Faraday
  faraday.request :multipart
  faraday.request :url_encoded

  # provided by this gem
  faraday.request :user_agent, app: "MarketingSite", version: APP_VERSION
  faraday.request :request_id

  # provided by faraday_middleware
  faraday.response :json, content_type: /\bjson$/

  faraday.adapter Faraday.default_adapter

end
```

You should also take a look at
[faraday_middleware](https://github.com/lostisland/faraday_middleware).

More middleware to come!

## Installation

Add this line to your application's Gemfile:

    gem 'faraday-conductivity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday-conductivity

## Usage

Here is an overview of the middleware included in this gem.

### Extended Logging

Provides pretty logging, allowing you to inspect every detail of the request
and response.

``` ruby
connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
  faraday.use :extended_logging, logger: Rails.logger
end
```

### RequestID

Pass on a request ID from your frontend applications to your backend services.
This allows for tracking requests over multiple services. Use this in
combination with something like the Rails tagged logger and you'll always know
what triggered something to happen in your application.

It works by trying to find the request id in `Thread.current[:request_id]` and
setting the `X-Request-Id` header.

``` ruby
connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
  faraday.request :request_id
end
```

In order for this to work, you need to make the Request ID globally available.
To do this in Rails:

``` ruby
class Application < ActionController::Base
  before_filter Faraday::Conductivity::RequestIdFilter
end
```

It's a hack, but it works really well.

### User Agent

Which application, on which server, made this request? With this middleware you
know! It sets the User-Agent string based on the user, pid and hostname.

``` ruby
connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
  faraday.request :user_agent, app: "MarketingSite", version: "1.1"
end
```

The User-Agent will looks like this on my machine:

```
MarketingSite/1.1 (iain.local; iain; 30360) ruby/1.9.3 (327; x86_64-darwin12.2.0)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
