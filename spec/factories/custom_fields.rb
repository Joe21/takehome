FactoryBot.define do
  factory :custom_field do
    association :client
    association :building
    field_store do
      {
        "number::num_bathrooms" => 2,
        "string::exterior_material" => "Brick",
        "enum::walkway_type" => "concrete"
      }
    end
  end
end
