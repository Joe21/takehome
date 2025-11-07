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
  end
end
