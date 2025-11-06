require 'rails_helper'

RSpec.describe CustomField, type: :model do
  subject { build(:custom_field, field_store:) }

  let(:field_store) { {} }

  it { is_expected.to belong_to(:building) }
  it { is_expected.to belong_to(:client) }

  describe 'validations' do
    context 'when field_store is an empty object' do
      it { is_expected.to be_valid }
    end

    context 'when field_store is nil' do
      let(:field_store) { nil }
      it { is_expected.to be_invalid }
    end

    context 'when field_store is not a hash' do
      let(:field_store) { 123 }
      it { is_expected.to be_invalid }
    end

    describe 'field_types' do
      # Key extraction issues
      context 'when field_store key is missing type prefix' do
        let(:field_store) { { "bathrooms" => 2 } }
        it { is_expected.to be_invalid }
      end

      context 'when field_store key has unknown type prefix' do
        let(:field_store) { { "bool::has_pool" => true } }
        it { is_expected.to be_invalid }
      end

      context 'when field_store key has empty type' do
        let(:field_store) { { "::num_bathrooms" => 2 } }
        it { is_expected.to be_invalid }
      end

      context 'when field_store key has empty label' do
        let(:field_store) { { "number::" => 2 } }
        it { is_expected.to be_invalid }
      end

      # Number type validations
      context 'when number field has numeric value' do
        let(:field_store) { { "number::num_bathrooms" => 2 } }
        it { is_expected.to be_valid }
      end

      context 'when number field has non-numeric value' do
        let(:field_store) { { "number::num_bathrooms" => "two" } }
        it { is_expected.to be_invalid }
      end

      # String type validations
      context 'when string field has string value' do
        let(:field_store) { { "string::exterior_material" => "Brick" } }
        it { is_expected.to be_valid }
      end

      context 'when string field has non-string value' do
        let(:field_store) { { "string::exterior_material" => 123 } }
        it { is_expected.to be_invalid }
      end

      # Enum type validations
      context 'when enum field has allowed value' do
        let(:field_store) { { "enum::walkway_type" => "Brick" } }
        it { is_expected.to be_valid }
      end

      context 'when enum field has disallowed value' do
        let(:field_store) { { "enum::walkway_type" => "Stone" } }
        it { is_expected.to be_invalid }
      end

      context 'when enum field is case-insensitive match' do
        let(:field_store) { { "enum::walkway_type" => "brick" } }
        it { is_expected.to be_valid }
      end

      # Multiple fields together
      context 'when multiple valid fields exist' do
        let(:field_store) do
          {
            "number::num_bathrooms" => 2,
            "string::exterior_material" => "Brick",
            "enum::walkway_type" => "Concrete"
          }
        end
        it { is_expected.to be_valid }
      end

      context 'when one invalid field exists among valid fields' do
        let(:field_store) do
          {
            "number::num_bathrooms" => "two",
            "string::exterior_material" => "Brick",
            "enum::walkway_type" => "Concrete"
          }
        end
        it { is_expected.to be_invalid }
      end
    end
  end

  describe '#update_field_store' do
    context 'when merging new valid fields' do
      let(:field_store) { { "number::num_bathrooms" => 2 } }
      it 'updates and saves successfully' do
        expect(subject.update_field_store("string::exterior_material" => "Brick")).to eq(true)
      end
    end

    context 'when merging new invalid fields' do
      let(:field_store) { { "number::num_bathrooms" => 2 } }
      it 'raises validation error' do
        expect {
          subject.update_field_store("number::num_bathrooms" => "two")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#allowed_enum_values' do
    context 'when key exists in enum_config' do
      let(:field_store) { { "enum::walkway_type" => "brick" } }
      it { expect(subject.allowed_enum_values("enum::walkway_type")).to include("brick") }
    end

    context 'when key does not exist in enum_config' do
      let(:field_store) { { "enum::nonexistent_enum" => "Value" } }
      it { expect(subject.allowed_enum_values("enum::nonexistent_enum")).to eq([]) }
    end
  end
end
