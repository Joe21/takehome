require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { build(:client, name:) }

  let(:name) { "Acme Co." }

  it { is_expected.to have_many(:buildings) }
  it { is_expected.to have_many(:custom_fields).dependent(:destroy) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    context 'when name ends with whitespace' do
      let(:name) { super() + "    "}

      before { subject.validate }

      it { is_expected.to be_valid }

      it 'strips whitespaces from the name' do
        expect(subject.name[-1]).not_to eq(' ')
      end
    end

    context 'when a case-insensitive duplicate already exists' do
      let(:dupe_client) { create(:client, name: name.downcase) }

      before { dupe_client }

      it { is_expected.to be_invalid }
    end
  end
end
