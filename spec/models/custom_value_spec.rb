require 'rails_helper'

RSpec.describe CustomValue, type: :model do
  subject { build(:custom_value, building: building) }

  let(:client)   { create(:client) }
  let(:building) { create(:building, client: client) }
  
  before do
    create(:custom_field, client: client)
    create(:custom_field, :enum, client: client)
    create(:custom_field, :number, client: client)
  end

  it { is_expected.to belong_to(:building) }
  it { is_expected.to validate_presence_of(:values) }

  describe '#values' do
    it 'assigns a numeric value for number fields' do
      number_field = client.custom_fields.find { |f| f.field_type == 'number' }
      expect(subject.values.fetch(number_field.key)).to be_a(Numeric)
    end

    it 'assigns a string value for freeform fields' do
      freeform_field = client.custom_fields.find { |f| f.field_type == 'freeform' }
      expect(subject.values.fetch(freeform_field.key)).to be_a(String)
    end

    it 'assigns a valid enum value' do
      enum_field = client.custom_fields.find { |f| f.field_type == 'enum' }
      expect(enum_field.enum_options).to include(subject.values.fetch(enum_field.key))
    end
  end
end