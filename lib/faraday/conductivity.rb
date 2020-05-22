require "faraday"

require "faraday/conductivity/version"

require "faraday/conductivity/extended_logging"
require "faraday/conductivity/request_id"
require "faraday/conductivity/request_id_filter"
require "faraday/conductivity/user_agent"
require "faraday/conductivity/selective_errors"
require "faraday/conductivity/request_headers"

module Faraday
  module Conductivity
  end

  Faraday::Middleware.register_middleware :extended_logging => Faraday::Conductivity::ExtendedLogging
  Faraday::Request.register_middleware    :request_id       => Faraday::Conductivity::RequestId
  Faraday::Request.register_middleware    :request_headers  => Faraday::Conductivity::RequestHeaders
  Faraday::Request.register_middleware    :user_agent       => Faraday::Conductivity::UserAgent
  Faraday::Response.register_middleware   :selective_errors => Faraday::Conductivity::SelectiveErrors
end

