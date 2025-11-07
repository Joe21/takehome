require 'rails_helper'

RSpec.describe Api::BuildingsController, type: :routing do
  let(:client_id) { '1' }
  let(:building_id) { '2' }

  describe 'index' do
    subject { { get: "/api/clients/#{client_id}/buildings" } }

    it { is_expected.to route_to('api/buildings#index', client_id:) }
  end

  describe 'create' do
    subject { { post: "/api/clients/#{client_id}/buildings" } }

    it { is_expected.to route_to("api/buildings#create", client_id:) }
  end

  describe 'update' do
    subject { { put: "/api/clients/#{client_id}/buildings/#{building_id}" } }

    it { is_expected.to route_to('api/buildings#update', client_id:, id: building_id) }
  end  
end
