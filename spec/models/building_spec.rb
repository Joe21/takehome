require 'rails_helper'

RSpec.describe Building, type: :model do
  let(:client) { create(:client) }

  # subject defined after let to ensure client exists
  subject { build(:building, client: client) }

  it { is_expected.to belong_to(:client).optional }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to define_enum_for(:state).with_values(UsStates::STATES) }

    context 'when a building with the same address exists with the same client' do
      before { create(:building, client: client, address: '123 MAIN ST') }

      it 'is invalid regardless of case' do
        subject.address = '123 Main St'
        expect(subject).not_to be_valid
        expect(subject.errors[:address]).to include('has already been taken')
      end
    end

    context 'when a building with the same address exists with a different client' do
      before { create(:building, client: create(:client), address: '123 MAIN ST') }

      it 'is valid because uniqueness is scoped to client_id' do
        subject.address = '123 Main St'
        expect(subject).to be_valid
      end
    end
    
    context 'when zip_code contains invalid characters' do
      before { subject.zip_code = "12345-ABCD" }

      it { is_expected.to be_invalid }
    end

    context 'when zip_code is valid 5-digit' do
      before { subject.zip_code = "12345" }

      it { is_expected.to be_valid }
    end

    context 'when zip_code is valid 9-digit with extension' do
      before { subject.zip_code = "12345-6789" }

      it { is_expected.to be_valid }
    end

    describe 'custom_field_values validations' do
      before do
        create(:custom_field, client: client, schema_store: {
          "num_bathrooms"   => "number",
          "exterior_material" => "string",
          "walkway_type"    => ["concrete", "gravel", "asphalt"]
        })
      end

      context 'when valid values are provided' do
        before do
          subject.custom_field_values = {
            "num_bathrooms"    => 2,
            "exterior_material" => "Wood",
            "walkway_type"     => "gravel"
          }
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when an invalid number is provided' do
        before { subject.custom_field_values = { "num_bathrooms" => "two" } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:custom_field_values]).to include(/Invalid value for num_bathrooms/)
        end
      end

      context 'when an invalid string is provided' do
        before { subject.custom_field_values = { "exterior_material" => 123 } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:custom_field_values]).to include(/Invalid value for exterior_material/)
        end
      end

      context 'when an invalid enum value is provided' do
        before { subject.custom_field_values = { "walkway_type" => "brick" } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:custom_field_values]).to include(/Invalid enum value for walkway_type/)
        end
      end
    end
  end
end
