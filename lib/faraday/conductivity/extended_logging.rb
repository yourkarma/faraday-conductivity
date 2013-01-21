require 'forwardable'

module Faraday
  module Conductivity
    class ExtendedLogging < Faraday::Middleware

      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      def initialize(app, options = {})
        @app = app
        @logger = options.fetch(:logger) {
          require 'logger'
          ::Logger.new($stderr)
        }
      end

      def call(env)
        start_time = Time.now
        info  { request_info(env) }
        debug { request_debug(env) }
        @app.call(env).on_complete do
          end_time = Time.now
          response_time = end_time - start_time
          info  { response_info(env, response_time) }
          debug { response_debug(env) }
        end
      end

      private

      def request_info(env)
        "Started #{env[:method].to_s.upcase} request to: #{env[:url]}"
      end

      def response_info(env, response_time)
        "Response from #{env[:url]}; Status: #{env[:status]}; Time: %.1fms" % (response_time * 1_000.0)
      end

      def request_debug(env)
        <<-MESSAGE
          Request Headers:
          ----------------
          #{format_headers env[:request_headers]}

          Request Body:
          -------------
          #{env[:body]}
        MESSAGE
      end

      def response_debug(env)
        <<-MESSAGE
          Response Headers:
          -----------------
          #{format_headers env[:response_headers]}

          Response Body:
          --------------
          #{env[:body]}
        MESSAGE
      end

      def format_headers(headers)
        length = headers.map {|k,v| k.to_s.size }.max
        headers.map { |name, value| "#{name.to_s.ljust(length)} : #{value.inspect}" }.join("\n")
      end

    end
  end
end
