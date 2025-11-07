module Api
  module Clients
    class BaseController < Api::BaseController
      private

      def current_client
        @current_client ||= Client.find(params[:client_id])
      rescue ActiveRecord::RecordNotFound
        render json: { status: :not_found, errors: ['Client not found'] }, status: :not_found
      end
    end
  end
end
