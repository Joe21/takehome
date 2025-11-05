# spec/factories/custom_values.rb
FactoryBot.define do
  factory :custom_value do
    association :building

    values do
      building.client.custom_fields.each_with_object({}) do |field, hash|
        next unless field.active

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
