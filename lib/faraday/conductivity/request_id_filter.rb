module Faraday
  module Conductivity
    class RequestIdFilter

      def self.filter(controller)
        Thread.current[:request_id] = controller.request.uuid
      end

    end
  end
end
