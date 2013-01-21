require "etc"
require "socket"
require "thread"

module Faraday
  module Conductivity
    class UserAgent < Faraday::Middleware

      def initialize(app, options = {})
        super(app)
        @name = options.fetch(:app) { "Faraday" }
        @version = options.fetch(:version) { "0.0" }
      end

      def call(env)
        login    = Etc.getlogin
        hostname = Socket.gethostname
        pid      = Process.pid
        user_agent = "#{@name}/#{@version} (#{hostname}; #{login}; #{pid}) #{RUBY_ENGINE}/#{RUBY_VERSION} (#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"
        env[:request_headers]['User-Agent'] ||= user_agent
        @app.call(env)
      end

    end
  end
end
