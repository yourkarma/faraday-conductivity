require "faraday"

require "faraday/conductivity/version"

require "faraday/conductivity/extended_logging"
require "faraday/conductivity/mimetype"
require "faraday/conductivity/request_id"
require "faraday/conductivity/request_id_filter"
require "faraday/conductivity/user_agent"
require "faraday/conductivity/repeater"
require "faraday/conductivity/selective_errors"

module Faraday
  module Conductivity
  end

  Faraday::Middleware.register_middleware :extended_logging => Faraday::Conductivity::ExtendedLogging
  Faraday::Middleware.register_middleware :repeater         => Faraday::Conductivity::Repeater
  Faraday::Request.register_middleware    :mimetype         => Faraday::Conductivity::Mimetype
  Faraday::Request.register_middleware    :request_id       => Faraday::Conductivity::RequestId
  Faraday::Request.register_middleware    :user_agent       => Faraday::Conductivity::UserAgent
  Faraday::Response.register_middleware   :selective_errors => Faraday::Conductivity::SelectiveErrors
end

