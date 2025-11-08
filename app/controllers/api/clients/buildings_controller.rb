module Api
  module Clients
    class BuildingsController < BaseController
      def index
        result = Buildings::Index.new(current_client).call
        render json: formatter(result: result), status: :ok
      rescue Buildings::Index::Error => e
        # INSERT ERROR MONITORING ex: Rollbar / Sentry
        render json: formatter(errors: [e.message]), status: :unprocessable_entity
      end

      def create
        result = Buildings::Create.new(current_client, building_params).call
        render json: formatter(result: { building: result[:building] }), status: :created
      # Handle clientside 422 
      rescue Buildings::Create::ValidationError => e
        render json: formatter(errors: [e.message]), status: :unprocessable_entity
      # Handle internal 500's
      rescue Buildings::Create::Error => e
        # INSERT ERROR MONITORING ex: Rollbar / Sentry
        render json: formatter(errors: [e.message]), status: :internal_server_error
      end

      def update
        result = Buildings::Update.new(current_client, params[:id], building_params).call
        render json: formatter(result: { building: result[:building] }), status: :ok
      rescue Buildings::Update::BuildingNotFoundError => e
        render json: formatter(errors: [e.message]), status: :unprocessable_entity
      # Handle clientside 422
      rescue Buildings::Update::ValidationError => e
        render json: formatter(errors: [e.message]), status: :unprocessable_entity
      # Handle internal 500's
      rescue Buildings::Update::Error => e
        # INSERT ERROR MONITORING ex: Rollbar / Sentry
        render json: formatter(errors: [e.message]), status: :internal_server_error
      end

      private

      def building_params
        params.permit(:address, :zip_code, :state, custom_field_values: {})
      end
    end
  end
end
