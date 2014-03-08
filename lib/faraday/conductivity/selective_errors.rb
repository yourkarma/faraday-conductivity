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

      ClientErrorStatuses = 400...600

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
            response = {
              :status  => env[:status],
              :body    => env[:body],
              :headers => env[:response_headers],
            }
            error = case status
              when 404
                Faraday::Error::ResourceNotFound.new(response)
              when 407
                # mimic the behavior that we get with proxy requests with HTTPS
                Faraday::Error::ConnectionFailed.new(%{407 "Proxy Authentication Required "})
              else
                Faraday::Error::ClientError.new(response)
              end
            error.extend Error
            error.response = response
            error.request = request
            error.response_time = Time.now - start_time
            raise error

          end

        end
      end

      def should_raise_error?(status)
        @on.include?(status) && !@except.include?(status)
      end

    end
  end
end
