FactoryBot.define do
  factory :custom_field do
    association :client

    # Default freeform
    field_type { 'freeform' }
    label { 'Living room color' }
    sequence(:key) { |n| "living_room_color_#{n}" } # ensure uniqueness
    enum_options { [] }
    active { true }

    trait :number do
      field_type { 'number' }
      label { "Number of Bathrooms" }
      sequence(:key) { |n| "num_bathrooms_#{n}" }
    end

    trait :enum do
      field_type { 'enum' }
      label { "Type of Walkway" }
      sequence(:key) { |n| "walkway_type_#{n}" }
      enum_options { ['Brick', 'Concrete', 'None'] }
    end
  end
end
