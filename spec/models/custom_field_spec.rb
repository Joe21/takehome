require 'rails_helper'

RSpec.describe CustomField, type: :model do
  subject { build(:custom_field, schema_store:) }

  let(:schema_store) { {} }

  it { is_expected.to belong_to(:client) }

  describe 'validations' do
    context 'when schema_store is nil' do
      let(:schema_store) { nil }
      it { is_expected.to be_invalid }
    end

    context 'when schema_store is not a hash' do
      let(:schema_store) { 123 }
      it { is_expected.to be_invalid }
    end

    context 'when schema_store is a hash' do
      context 'with a blank key' do
        let(:schema_store) { { "" => "string" } }
        it { is_expected.to be_invalid }
      end

      context 'with an invalid value type' do
        let(:schema_store) { { "num_bathrooms" => "cats and dogs" } }
        it { is_expected.to be_invalid }
      end

      context "with a value 'number'" do
        let(:schema_store) { { "num_bathrooms" => "number" } }
        it { is_expected.to be_valid }
      end

      context "with a value 'string'" do
        let(:schema_store) { { "exterior_material" => "string" } }
        it { is_expected.to be_valid }
      end

      context 'with an an empty array' do
        let(:schema_store) { { "walkway_type" => [] } }
        it { is_expected.to be_invalid }
      end

      context 'with an array containing invalid types' do
        let(:schema_store) { { "walkway_type" => ["string string", 123] } }
        it { is_expected.to be_invalid }
      end

      context 'with an array containing only valid strings' do
        let(:schema_store) { { "walkway_type" => ["brick", "concrete", "none"] } }
        it { is_expected.to be_valid }
      end
    end
  end
end
