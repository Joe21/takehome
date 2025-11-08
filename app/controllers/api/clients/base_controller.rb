module Api
  module Clients
    class BaseController < Api::BaseController
      private

      def current_client
        # SPOOF AUTHENTICATION
        @current_client ||= Client.first
      rescue ActiveRecord::RecordNotFound
        render json: { status: :not_found, errors: [ "Client not found" ] }, status: :not_found
      end

      def formatter(result: nil, errors: nil, status: :ok)
        body = { status_code: Rack::Utils::SYMBOL_TO_STATUS_CODE[status] }

        if errors
          body.merge(status: "error", errors:)
        else
          body.merge(status: "success", data: result)
        end
      end
    end
  end
end
