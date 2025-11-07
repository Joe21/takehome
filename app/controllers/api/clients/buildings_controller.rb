module Api
  module Clients
    class BuildingsController < ApplicationController
      # http://localhost:3000/api/clients/1/buildings
      def index
        render json: { status: :ok, buildings: [] }
      end

      def create
        render json: { status: :created, message: 'Building created (placeholder)' }
      end

      def update
        render json: { status: :updated, message: 'Building updated (placeholder)' }
      end
    end
  end
end
