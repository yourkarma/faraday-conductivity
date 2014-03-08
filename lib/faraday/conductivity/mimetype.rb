module Faraday
  module Conductivity
    # Deprecated. Use RequestHeaders
    class Mimetype < Faraday::Middleware

      def initialize(app, options = {})
        super(app)
        @accept = options.fetch(:accept)
      end

      def call(env)
        env[:request_headers]['Accept'] ||= @accept
        @app.call(env)
      end

    end
  end
end
