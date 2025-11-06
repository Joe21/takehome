require 'rails_helper'

RSpec.describe CustomField, type: :model do
  subject { build(:custom_field, client: create(:client)) }

  it { is_expected.to belong_to(:client) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key).scoped_to(:client_id).case_insensitive }
    it { is_expected.to validate_presence_of(:field_type) }
    it { is_expected.to validate_inclusion_of(:field_type).in_array(%w[number freeform enum]) }

    context 'when field_type is enum' do
      let(:field_type) { 'enum' }
      let(:enum_options) { [] }

      before { subject.assign_attributes(field_type:, enum_options:) }

      context 'with valid enum_options' do
        let(:enum_options) { ['Brick', 'Concrete', 'None'] }
        
        it { is_expected.to be_valid }
      end

      context 'with empty enum_options' do
        let(:enum_options) { [] }

        it { is_expected.to be_invalid }
      end
    end

    context 'when field_type is not enum' do
      before { subject.enum_options = [] }

      it { is_expected.to be_valid }
    end

    context 'when another client has the same key' do
      before do
        other_client = create(:client)
        create(:custom_field, client: other_client, key: 'living_room_color')
        subject.key = 'living_room_color'
        subject.client = create(:client)
      end

      it { is_expected.to be_valid }
    end

    context 'when the same client has the same key' do
      before do
        create(:custom_field, client: subject.client, key: 'LIVING_ROOM_COLOR')
        subject.key = 'living_room_color'
      end

      it { is_expected.to be_invalid }
    end
  end
end
