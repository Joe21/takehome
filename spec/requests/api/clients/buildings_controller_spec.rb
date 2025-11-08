RSpec.describe "Api::Clients::Buildings", type: :request do
  subject { send(http_method, url, params:, as: :json) }

  let(:http_method) { :get }
  let(:url) { api_clients_buildings_path }
  let(:params) { { client_id: client.id } }
  let(:building) { create(:building, client:) }
  let(:parsed_resp) { JSON.parse(response.body) }  

  # For spoofed authentication, current_client is always Client.first
  let!(:client) { create(:client) }

  describe "index" do
    it 'returns a successful HTTP status' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct json structure' do
      subject
      expect(parsed_resp.keys).to include('status', 'status_code', 'data')
    end
    
    it 'calls the Buildings::Index use case' do
      use_case = instance_double(Buildings::Index, call: { buildings: [] })
      allow(Buildings::Index).to receive(:new).with(client).and_return(use_case)
      subject
      expect(Buildings::Index).to have_received(:new).with(client)
      expect(use_case).to have_received(:call)
    end

    context 'when an error occurs' do
      before do
        allow(Buildings::Index).to receive(:new).with(client).and_raise(
          Buildings::Index::Error.new("Stranger Danger!!")
        )
      end


      it 'does not raise an exception' do
        expect { subject }.not_to raise_error
      end

      it 'returns an unsuccessful HTTP status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns a response with errors' do
        subject
        expect(parsed_resp).to include('errors')
      end
    end
  end

  describe 'create' do
    let(:http_method) { :post }
    let(:url) { api_clients_buildings_path }
    let(:params) do
      {
        address: '1 Real Building 1st Real Ave',
        zip_code: '12345',
        state: 'NY',
        custom_field_values: { 'parking_spots' => 10, 'material' => 'brick' }
      }
    end

    before do
      # Seed the custom fields for validation
      create(:custom_field, client: client, schema_store: { 'parking_spots' => 'number' })
      create(:custom_field, client: client, schema_store: { 'material' => 'string' })
    end

    it 'returns a created HTTP status' do
      subject
      expect(response).to have_http_status(:created)
    end

    it 'returns the correct json structure' do
      subject
      expect(parsed_resp.keys).to include('status', 'status_code', 'data')
      expect(parsed_resp['data']).to include('building')
      expect(parsed_resp['data']['building']).to include('id', 'address', 'zip_code', 'state', 'custom_field_values')
    end

    it 'calls the Buildings::Create use case' do
      use_case = instance_double(Buildings::Create, call: { building: build(:building, client: client) })
      allow(Buildings::Create).to receive(:new).and_return(use_case)
      subject
      expect(Buildings::Create).to have_received(:new).with(client, kind_of(ActionController::Parameters))
      expect(use_case).to have_received(:call)
    end

    context 'when a validation error occurs' do
      let(:params) do
        {
          address: '1 Real Building 1st Real Ave',
          zip_code: '12345',
          state: 'NY',
          custom_field_values: { 'parking_spots' => 10, 'material' => 'brick', 'bad_field' => 1000 }
        }
      end

      it 'returns 422 unprocessable entity' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        subject
        expect(parsed_resp['errors'].first).to match(/Invalid custom field keys:/)
      end
    end
  end

  describe 'update' do
    let(:http_method) { :put }
    let(:url) { api_clients_building_path(building.id) }
    let(:params) do
      {
        address: 'Updated Building 2nd Ave',
        zip_code: '54321',
        state: 'NY',
        custom_field_values: { 'parking_spots' => 20, 'material' => 'concrete' }
      }
    end

    before do
      create(:building, client: client)
      # Seed the custom fields for validation
      create(:custom_field, client: client, schema_store: { 'parking_spots' => 'number' })
      create(:custom_field, client: client, schema_store: { 'material' => 'string' })
    end

    it 'returns a successful HTTP status' do
      subject
      expect(response).to have_http_status(:ok)
    end


    it 'returns the correct json structure' do
      subject
      expect(parsed_resp.keys).to include('status', 'status_code', 'data')
      expect(parsed_resp['data']).to include('building')
      expect(parsed_resp['data']['building']).to include('id', 'address', 'zip_code', 'state', 'custom_field_values')
    end

    it 'calls the Buildings::Update use case' do
      use_case = instance_double(Buildings::Update, call: { building: building })
      allow(Buildings::Update).to receive(:new).and_return(use_case)
      subject
      expect(Buildings::Update).to have_received(:new).with(client, building.id.to_s, kind_of(ActionController::Parameters))
      expect(use_case).to have_received(:call)
    end

    context 'when building is not found' do
      let(:url) { api_clients_building_path(9999) }

      it 'returns 422 unprocessable entity' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        subject
        expect(parsed_resp['errors'].first).to match(/Building not found/)
      end
    end

    context 'when a validation error occurs' do
      let(:params) do
        {
          address: '',
          zip_code: '54321',
          state: 'NY',
          custom_field_values: { 'parking_spots' => 'invalid', 'material' => 'concrete' }
        }
      end

      it 'returns 422 unprocessable entity' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        subject
        expect(parsed_resp['errors'].first).to match(/Invalid value for parking_spots/)
      end
    end
  end
end
