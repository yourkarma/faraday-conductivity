module Faraday
  module Conductivity
    class RequestId < Faraday::Middleware

      def initialize(app)
        super(app)
      end

      def call(env)
        request_id = Thread.current[:request_id]
        if request_id
          env[:request_headers]['X-Request-Id'] ||= request_id
        end
        @app.call(env)
      end

    end
  end
end
