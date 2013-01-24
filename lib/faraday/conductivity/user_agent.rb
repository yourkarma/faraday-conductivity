require "etc"
require "socket"

module Faraday
  module Conductivity
    class UserAgent < Faraday::Middleware

      def initialize(app, options = {})
        super(app)
        @name = options.fetch(:app) { "Faraday" }
        @version = options.fetch(:version) { "0.0" }
        @environment = options.fetch(:environment) { Environment.new }
      end

      def call(env)
        env[:request_headers]['User-Agent'] ||= user_agent
        @app.call(env)
      end

      def user_agent
        [ app, ruby ].join(' ')
      end

      def app
        "#{@name}/#{@version} (#{@environment.hostname}; #{@environment.login}; #{@environment.pid})"
      end

      def ruby
        "#{RUBY_ENGINE}/#{RUBY_VERSION} (#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"
      end

    end

    class Environment

      def login
        Etc.getlogin
      end

      def hostname
        Socket.gethostname
      end

      def pid
        Process.pid
      end

    end
  end
end
