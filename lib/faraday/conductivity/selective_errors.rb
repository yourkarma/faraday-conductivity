module Faraday
  module Conductivity

    module Error

      attr_accessor :request, :response, :response_time

      def initialize(*)
        @request  = {}
        @response = {}
        super
      end

      def message
        if @wrapped_exception
          "#{@wrapped_exception.class}: #{super}"
        else
          "#{request[:method].to_s.upcase} #{request[:url]} responded with status #{response[:status]}"
        end
      end

      def inspect
        "<#{self.class}> #{message}"
      end

    end

    # Use this to raise errors on certain HTTP statuses. These are basically
    # the same errors as Faraday raises when you use the "raise_error"
    # middleware, but with added fields to better inspect what went wrong.
    #
    # Examples:
    #
    #   # specify an array
    #   faraday.response :selective_errors, on: [422,500]
    #   # or a range:
    #   faraday.response :selective_errors, on: 500...600
    #   # specify errors:
    #   faraday.response :selective_errors, except: [404,422]
    #
    # Rescueing the errors:
    #
    #   begin
    #     do_request
    #   rescue Faraday::Conductivity::Error => error
    #     puts error.request[:url]
    #     puts error.request[:method]
    #     puts error.request[:body]
    #     puts error.request[:headers]
    #
    #     puts error.response[:status]
    #     puts error.response[:body]
    #     puts error.response[:headers]
    #   end
    class SelectiveErrors < Faraday::Middleware

      ClientErrorStatuses = (400...500).freeze
      ServerErrorStatuses = (500...600).freeze

      def initialize(app, options = {})
        @app    = app
        @on     = options.fetch(:on) { ClientErrorStatuses }
        @except = options.fetch(:except) { [] }
      end

      def call(env)
        # capture request because it will be modified during the request
        request = {
          :method  => env[:method],
          :url     => env[:url],
          :body    => env[:body],
          :headers => env[:request_headers],
        }

        start_time = Time.now

        @app.call(env).on_complete do
          status = env[:status]

          if should_raise_error?(status)
            error = case status
                    when 400
                      Faraday::BadRequestError.new(response_values(env))
                    when 401
                      Faraday::UnauthorizedError.new(response_values(env))
                    when 403
                      Faraday::ForbiddenError.new(response_values(env))
                    when 404
                      Faraday::ResourceNotFound.new(response_values(env))
                    when 407
                      # mimic the behavior that we get with proxy requests with HTTPS
                      msg = %(407 "Proxy Authentication Required")
                      Faraday::ProxyAuthError.new(msg, response_values(env))
                    when 409
                      Faraday::ConflictError.new(response_values(env))
                    when 422
                      Faraday::UnprocessableEntityError.new(response_values(env))
                    when ClientErrorStatuses
                      Faraday::ClientError.new(response_values(env))
                    when ServerErrorStatuses
                      Faraday::ServerError.new(response_values(env))
                    when nil
                      Faraday::NilStatusError.new(response_values(env))
                    end

            error.extend Error
            error.response = response_values(env)
            error.request = request
            error.response_time = Time.now - start_time

            raise error
          end

        end
      end

      def response_values(env)
        { status: env.status, headers: env.response_headers, body: env.body }
      end

      def should_raise_error?(status)
        @on.include?(status) && !@except.include?(status)
      end

    end
  end
end
