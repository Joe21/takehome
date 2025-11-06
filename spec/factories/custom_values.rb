FactoryBot.define do
  factory :custom_value do
    association :building

    # Populate values hash after the building and its client exist
    after(:build) do |custom_value|
      client = custom_value.building.client
      
      custom_value.values = client.custom_fields.each_with_object({}) do |field, hash|
        hash[field.key] = case field.field_type
        when 'number'
          rand(1..5) + [0, 0.5].sample
        when 'freeform'
          Faker::Lorem.word
        when 'enum'
          field.enum_options.sample
        end
      end
    end
  end
end
