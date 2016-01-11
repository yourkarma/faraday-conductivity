require 'forwardable'

module Faraday
  module Conductivity
    class DefaultLogFormatter
      def build_message(request_type, headers, body)
        format_headers(request_type, headers) + "\n\n" +
          format_body(request_type, body)
      end

      private

      def format_headers(request_type, headers)
        prettified_headers = prettify_headers(headers)
        "#{ request_type } Headers:\n----------------\n#{ prettified_headers.join("\n") }"
      end

      def format_body(request_type, body)
        "#{ request_type } Body:\n----------------\n#{ body }"
      end

      def prettify_headers(headers)
        length = headers.map {|k,v| k.to_s.size }.max
        headers.map { |name, value| "#{name.to_s.ljust(length)} : #{value}" }
      end
    end
  end
end
