module Faraday
  module Conductivity
    class RequestIdFilter

      class << self
        def filter(controller)
          Thread.current[:request_id] = controller.request.uuid
        end
        alias_method :before, :filter
      end

    end
  end
end
