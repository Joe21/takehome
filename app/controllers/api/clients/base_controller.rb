module Api
  module Clients
    class BaseController < Api::BaseController
      private

      def current_client
        # SPOOF FOR DEVELOPMENT
          return Client.first if Rails.env.development?

        @current_client ||= Client.find(params[:client_id])
      rescue ActiveRecord::RecordNotFound
        render json: { status: :not_found, errors: ['Client not found'] }, status: :not_found
      end

      def formatter(result: nil, errors: nil, status: :ok)
        hash = {
          status: status.to_s,
          status_code: Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
        }
        errors.present? ? hash[:errors] = Array(errors) : hash[:data] = result
        hash
      end
    end
  end
end
