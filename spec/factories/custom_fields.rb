FactoryBot.define do
  factory :custom_field do
    association :client

    schema_store do
      {
        "num_bathrooms"    => "number",
        "exterior_material"=> "string",
        "walkway_type"     => ["brick", "concrete", "none", "unknown"],
        "heating_type"     => ["gas", "electric", "oil", "none", "unknown"],
        "floor_type"       => ["hardwood", "carpet", "tile", "unknown"]
      }
    end
  end
end
