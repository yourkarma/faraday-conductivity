module Faraday
  module Conductivity
    class Repeater < Faraday::Middleware

      PATTERNS = {
        :rapid       => lambda { |n| 0 },
        :one         => lambda { |n| 1 },
        :linear      => lambda { |n| n },
        :exponential => lambda { |n| n ** 2 },
      }

      def initialize(app, options = {})
        @app = app
        @retries = options[:retries] || 10

        if mode = options[:mode]
          @pattern = build_pattern(PATTERNS.fetch(mode))
        elsif pattern = options[:pattern]
          @pattern = build_pattern(pattern)
        else
          @pattern = build_pattern(PATTERNS.fetch(:exponential))
        end
      end

      def call(env)
        tries = 0
        begin
          @app.call(env)
        rescue Faraday::Error::ClientError, SystemCallError
          if tries < @retries
            tries += 1
            @pattern.wait(tries)
            retry
          else
            raise
          end
        end
      end

      def build_pattern(pattern)
        Pattern.new(pattern)
      end

      class Pattern

        def initialize(pattern)
          @pattern = pattern
        end

        def wait(num)
          seconds = @pattern.call(num)
          if seconds != 0
            sleep num
          end
        end

      end

    end
  end
end
