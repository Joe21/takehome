require 'rails_helper'

RSpec.describe Buildings::Index do
  subject { described_class.new(client).call }

  let(:client) { create(:client, name: 'Acme Co') }

  let!(:custom_field1) { create(:custom_field, client:, schema_store: { "rock_wall_size" => "number", "rock_wall_length" => "number" }) }
  let!(:custom_field2) { create(:custom_field, client:, schema_store: { "brick_color" => "string", "brick_count" => "number" }) }

  let!(:buildings) do
    [
      create(:building, client:, state: 'NY', zip_code: '12345', custom_field_values: {
        "rock_wall_size" => 15,
        "rock_wall_length" => 26,
        "brick_color" => "",
        "brick_count" => 0
      }),
      create(:building, client:, state: 'CA', zip_code: '90210', custom_field_values: {
        "rock_wall_size" => 0,
        "rock_wall_length" => 0,
        "brick_color" => "red",
        "brick_count" => 120
      })
    ]
  end

  let!(:other_client_buildings) do
    other_client = create(:client, name: 'Glass Walls Inc')
    create(:custom_field, client: other_client, schema_store: { "glass_window_count" => "number" })
    create(:building, client: other_client, state: 'TX', zip_code: '75001', custom_field_values: {
      "glass_window_count" => 10
    })
  end

  describe '#call' do
    let(:first_building) { subject[:buildings].first }
    let(:result_ids) { subject[:buildings].map { |b| b[:id] } }
    let(:all_custom_fields) { client.custom_fields.flat_map { |cf| cf.schema_store.keys }.uniq }
    let(:field_values) {}

    it 'returns only buildings for the current client' do
      expect(result_ids).to match_array(buildings.map(&:id))
    end

    it 'returns buildings with expected keys including client_name and all custom fields' do
      expect(first_building.keys).to include(:id, :client_name, :address, :zip_code, :state, *all_custom_fields)
      expect(first_building[:client_name]).to eq('Acme Co')
    end

    it 'fills missing custom fields with empty strings or zeros' do
      subject[:buildings].each do |b|
        all_custom_fields.each do |key|
          expect(b).to have_key(key)
          expect(b[key]).to be_a(String).or be_a(Integer)
        end
      end
    end

    it 'includes the correct custom field values for each building' do
      field_values = subject[:buildings].map { |b| all_custom_fields.index_with { |k| b[k] } }
      expect(field_values).to include({
        "rock_wall_size" => 15,
        "rock_wall_length" => 26,
        "brick_color" => "",
        "brick_count" => 0
      })
      expect(field_values).to include({
        "rock_wall_size" => 0,
        "rock_wall_length" => 0,
        "brick_color" => "red",
        "brick_count" => 120
      })
    end

    it 'does not include custom fields from other clients' do
      subject[:buildings].each do |b|
        expect(b.keys).not_to include("glass_window_count")
      end
    end

    context 'when an error occurs' do
      before do
        allow(client).to receive(:buildings).and_raise(StandardError, 'Something went wrong')
      end

      it 'raises Buildings::Index::Error' do
        expect { subject }.to raise_error(Buildings::Index::Error, 'Something went wrong')
      end
    end
  end
end
