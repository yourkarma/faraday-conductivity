module Faraday
  module Conductivity
    class SelectiveErrors < Faraday::Middleware

      ClientErrorStatuses = 400...600

      def initialize(app, options = {})
        @app    = app
        @on     = options.fetch(:on) { ClientErrorStatuses }
        @except = options.fetch(:except) { [] }
      end

      def call(env)
        # capture request_body because not accessible afterwards
        request_body = env[:body]
        @app.call(env).on_complete do
          if should_raise_error?(env[:status])
            raise_error(env, request_body)
          end
        end
      end

      def should_raise_error?(status)
        @on.include?(status) && !@except.include?(status)
      end

      def raise_error(env, request_body)
        case env[:status]
        when 404
          raise Faraday::Error::ResourceNotFound, response_values(env, request_body)
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        else
          raise Faraday::Error::ClientError, response_values(env, request_body)
        end
      end

      def response_values(env, request_body)
        {
          :url              => env[:url],
          :status           => env[:status],
          :request_body     => request_body,
          :request_headers  => env[:request_headers],
          :response_headers => env[:response_headers],
          :response_body    => env[:body],
        }
      end

    end
  end
end
