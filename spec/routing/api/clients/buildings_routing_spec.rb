require 'rails_helper'

RSpec.describe Api::Clients::BuildingsController, type: :routing do
  subject { send(method, url) }

  let(:method) { :get }
  let(:url) { '/api/clients/buildings' }

  describe 'GET #index' do
    it { is_expected.to route_to('api/clients/buildings#index') }
  end

  describe 'POST #create' do
    let(:method) { :post }

    it { is_expected.to route_to('api/clients/buildings#create') }
  end

  describe 'PUT #update' do
    let(:method) { :put }
    let(:url) { "/api/clients/buildings/#{building_id}" }
    let(:building_id) { '2' }

    it { is_expected.to route_to('api/clients/buildings#update', id: building_id) }
  end
end
