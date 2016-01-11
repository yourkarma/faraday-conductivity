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
        @formatter = options.fetch(:formatter) {
          DefaultLogFormatter.new
        }
      end

      def call(env)
        start_time = Time.now
        debug { request_info(env) }
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
        "Started %s request to: %s" % [ env[:method].to_s.upcase, env[:url] ]
      end

      def response_info(env, response_time)
        "Response from %s %s; Status: %d; Time: %.1fms" % [ env[:method].to_s.upcase, env[:url], env[:status], (response_time * 1_000.0) ]
      end

      def request_debug(env)
        @formatter.build_message("Request", env[:request_headers], env[:body])
      end

      def response_debug(env)
        @formatter.build_message("Response", env[:response_headers], env[:body])
      end

    end
  end
end
