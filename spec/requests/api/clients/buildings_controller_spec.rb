RSpec.describe "Api::Clients::Buildings", type: :request do
  subject { send(http_method, url, params:) }
  
  let(:http_method) { :get }
  let(:url) { api_clients_buildings_path }
  let(:params) { { client_id: client.id } }
  let(:client) { create(:client) }
  let(:building) { create(:building, client:) }
  let(:parsed_resp) { JSON.parse(response.body) }  

  describe "index" do
    it 'returns a successful HTTP status' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'the correct json structure' do
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

  # describe "POST /api/clients/buildings" do
  #   it "returns a created placeholder JSON response" do
  #     post api_client_buildings_path(client_id: client.id), params: {
  #       address: "123 Main St",
  #       zip_code: "12345",
  #       state: "AL"
  #     }

  #     expect(response).to have_http_status(:created)
  #     json = JSON.parse(response.body)
  #     expect(json['status']).to eq('created')
  #     expect(json['message']).to eq('Building created (placeholder)')
  #   end
  # end

  # describe "PUT /api/clients/buildings/:id" do
  #   it "returns an updated placeholder JSON response" do
  #     put api_client_buildings_path(client_id: client.id, id: building.id), params: {
  #       address: "123 Main St Updated"
  #     }

  #     expect(response).to have_http_status(:ok)
  #     json = JSON.parse(response.body)
  #     expect(json['status']).to eq('ok')
  #     expect(json['message']).to eq('Building updated (placeholder)')
  #   end
  # end
end
