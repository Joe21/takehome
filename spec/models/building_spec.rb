require 'rails_helper'

RSpec.describe Building, type: :model do
  subject { build(:building) }  

  it { is_expected.to belong_to(:client).optional }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_uniqueness_of(:address).scoped_to(:client_id).case_insensitive }
    it { is_expected.to validate_presence_of(:zip_code) }

    context 'when contains invalid strings' do
      before { subject.zip_code = "12345-ABCD" }

      it { is_expected.to be_invalid }
    end
  end
end