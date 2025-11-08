module Api
  module Clients
    class BuildingsController < BaseController
      def index
        result = Buildings::Index.new(current_client).call
        render json: formatter(result: result)
      rescue Buildings::Index::Error => e
        # (Rollbar / Sentry Error reporting happens here Rollbar.error(e, client_id: current_client.id, action: 'index')
        render json: formatter(errors: [e.message]), status: :unprocessable_entity
      end

      # def create
      #   result = Buildings::Create.new(current_client, building_params).call
      #   render json: format_response(result), status: :created
      # end

      # def update
      #   result = Buildings::Update.new(current_client, building_params).call
      #   render json: format_response(result), status: :created
      # end

      private

      def building_params
        params.permit(:address, :zip_code, :state, custom_field_values: {})
      end
    end
  end
end
