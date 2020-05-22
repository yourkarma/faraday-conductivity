# Faraday::Conductivity [![Build Status](https://travis-ci.org/enova/faraday-conductivity.svg?branch=master)](https://travis-ci.org/enova/faraday-conductivity)

Originally implemented by [yourkarma/faraday-conductivity](https://github.com/yourkarma/faraday-conductivity).

---

Extra Faraday Middleware! Geared towards a service oriented architecture.

These middlewares are currently included:

* **user_agent**, adds a dynamic `User-Agent` header to the request, so you
  know which server and process the request is coming from.
* **extended_logging**, logs *all* the information of the request.
* **request_id**, passes along the `X-Request-Id` header to track API request
  back to the source.
* **request_headers**, allows you to specify default request headers used in each request.
* **selective_errors**, raise errors only on the statuses that you specify.

Further information:

* [faraday](https://github.com/lostisland/faraday)
* [faraday_middleware](https://github.com/lostisland/faraday_middleware)

## Example

Here is an overview of my favorite stack. More information about each
middleware is below.

``` ruby
APP_VERSION = IO.popen(["git", "rev-parse", "HEAD", :chdir => Rails.root]).read.chomp

require "faraday_middleware"
require "faraday/conductivity"

connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|

  # provided by Faraday itself
  faraday.token_auth "secret"
  faraday.request :multipart
  faraday.request :url_encoded

  # provided by this gem
  faraday.request :user_agent, app: "MarketingSite", version: APP_VERSION
  faraday.request :request_id
  faraday.request :request_headers, accept: "application/vnd.widgets-v2+json"

  # provided by this gem
  faraday.use :extended_logging, logger: Rails.logger

  # provided by faraday_middleware
  faraday.response :json, content_type: /\bjson$/

  # provided by this gem
  faraday.response :selective_errors, on: 425..599, except: 402..499

  faraday.adapter Faraday.default_adapter

end
```

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'faraday-conductivity'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install faraday-conductivity
```

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

Be sure to put this middleware after other middleware that add headers,
otherwise it will log incomplete requests.

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

It's a hack, because it uses a thread local variable, but it works really well.

Don't forget to turn on uuid logging in Rails too, by uncommenting the line in
`config/environments/production.rb`:

``` ruby
# Prepend all log lines with the following tags
config.log_tags = [ :uuid ]
```

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

### Selective Errors

The default `:raise_error` middleware raises errors for every http status above
400. However, status codes like 404 or 422 might not be an actual exceptional
condition. This middleware allows you to specify which status codes you do and
do not want to raise an error for.

You can pass in an array or a range to the `:on` argument. This will default to
400...600. You can specify exceptions with the `:except` argument.

``` ruby
connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
  faraday.response :selective_errors, on: (400...600), except: [404, 409, 410, 412, 422]
end
```

The errors raised will be the same as Faraday, namely
`Faraday::Error::ResourceNotFound` for 404 errors,
`Faraday::Error::ConnectionFailed` for 407 and `Faraday::Error::ClientError` for
the rest.

If you don't specify the `:on` or `:except` options, it will behave exactly like
`:raise_error`. The errors are however "enhanced" with extra information about
the request that normally are lost:

``` ruby
begin
  do_failing_request_here
rescue Faraday::Error::ClientError => error
  puts error.request[:url]
  puts error.request[:method]
  puts error.request[:body]
  puts error.request[:headers]

  puts error.response[:status]
  puts error.response[:body]
  puts error.response[:headers]
  puts error.response_time
end
```

### Request Headers

Allows you to set request headers ahead of time, so you don't have to do this
each time you make a request. You can override it per request of course.

Usage:

``` ruby
connection = Faraday.new(url: "http://widgets.yourapp.com") do |faraday|
  faraday.request :request_headers, accept: "application/json", x_version_number: "10"
end
```

## faraday-conductivity ~> 0.3

The following middlewares have been removed entirely and are no longer
supported, but were available prior in faraday-conductivity versions <= 0.3.

### Repeater

Suggested to use [Faraday's Retry](https://github.com/lostisland/faraday/blob/master/docs/middleware/request/retry.md)
instead.

The Repeater will retry your requests until they succeed. This is handy for
reaching servers that are not too reliable.

``` ruby
connection = Faraday.new(url: "http://slow.website.com") do |faraday|
  faraday.use :repeater, retries: 6, mode: :rapid
end
```

The `retries` parameter specifies how many times to retry before succeeding.

The `mode` parameter specifies how long to wait before retrying. `:rapid` will
retry instantly, `:one`, will wait one second between retries, `:linear` and
`:exponential` will retry longer and longer after every retry.

It's also possible to specify your own pattern by providing a lambda, that
returns the number of seconds to wait. For example:

``` ruby
connection = Faraday.new(url: "http://slow.website.com") do |faraday|
  faraday.use :repeater, retries: 6, pattern: ->(n) { rand < 0.5 ? 10 : 2 }
end
```

You can use the repeater together with the `raise_error` middleware to also
retry after getting 404s and other succeeded requests, but failed statuses.

### Mimetype

This one is deprecated. Use Request Headers instead.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
