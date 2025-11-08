## Delete in dependency order (if needed)
# Building.delete_all
# CustomField.delete_all
# Client.delete_all

# Seed 5 Clients
clients = [ 'Alpha Co.', 'Bravo Co.', 'Charlie Co.', 'Delta Co.', 'Echo Co.' ].map do |name|
  client = Client.find_or_create_by!(name:)
  puts client.inspect
  puts "\n"
  client
end
puts "------------ CLIENTS SEEDED SUCCESSFULLY ------------\n\n"

# Seed a small sample of custom fields for each client
clients.each do |client|
  case client.name
  when 'Alpha Co.'
    custom_fields = client.custom_fields.find_or_create_by!(schema_store: {
      "num_bathrooms"    => "number",
      "exterior_material" => "string",
      "walkway_type"     => [ "concrete", "gravel", "asphalt" ]
    })
    puts custom_fields.inspect
    puts "\n"
  when 'Bravo Co.'
    custom_fields = client.custom_fields.find_or_create_by!(schema_store: {
      "interior_material" => "string",
      "bedroom_count"     => "number"
    })
    puts custom_fields.inspect
    puts "\n"
  when 'Charlie Co.'
    custom_fields = client.custom_fields.find_or_create_by!(schema_store: {
      "bedroom_window_type" => [ "single", "double", "triple" ],
      "indoor_pool_sqft"    => "number"
    })
    puts custom_fields.inspect
    puts "\n"
  when 'Delta Co.'
    custom_fields = client.custom_fields.find_or_create_by!(schema_store: {
      "num_solar_panels"        => "number",
      "energy_efficiency_rating" => [ "A", "B", "C", "D" ]
    })
    puts custom_fields.inspect
    puts "\n"
  when 'Echo Co.'
    custom_fields = client.custom_fields.find_or_create_by!(schema_store: {
      "year_built" => "number",
      "was_church" => [ "yes", "no" ]
    })
  end
end
puts "------------ CUSTOM FIELDS SEEDED SUCCESSFULLY ------------\n\n"

# Seed a small sample of buildings for each client that contain values for the custom fields
clients.each do |client|
  puts "Seeding buildings for client: #{client.name}"

  case client.name
  when 'Alpha Co.'
    buildings = [
      { address: "1 State Street", zip_code: "10001", state: "NY", custom_field_values: { "num_bathrooms"=>2, "exterior_material"=>"Brick", "walkway_type"=>"concrete" } },
      { address: "1 Saint Street", zip_code: "10002", state: "NY", custom_field_values: { "num_bathrooms"=>3, "exterior_material"=>"Wood", "walkway_type"=>"gravel" } }
    ]
  when 'Bravo Co.'
    buildings = [
      { address: "2-3 Bla bla Blvd", zip_code: "20001", state: "NJ", custom_field_values: { "interior_material"=>"Oak", "bedroom_count"=>4 } },
      { address: "222 Bay Terrace", zip_code: "20002", state: "NJ", custom_field_values: { "interior_material"=>"Pine", "bedroom_count"=>3 } }
    ]
  when 'Charlie Co.'
    buildings = [
      { address: "333 Charlie Rd", zip_code: "30001", state: "GA", custom_field_values: { "bedroom_window_type"=>"double", "indoor_pool_sqft"=>500 } },
      { address: "333 Charlie Blvd", zip_code: "30002", state: "GA", custom_field_values: { "bedroom_window_type"=>"triple", "indoor_pool_sqft"=>750 } }
    ]
  when 'Delta Co.'
    buildings = [
      { address: "111 Evergreen Terrace", zip_code: "40001", state: "IL", custom_field_values: { "num_solar_panels"=>20, "energy_efficiency_rating"=>"A" } },
      { address: "111 Everblue Terrace", zip_code: "40002", state: "IL", custom_field_values: { "num_solar_panels"=>15, "energy_efficiency_rating"=>"B" } }
    ]
  when 'Echo Co.'
    buildings = [
      { address: "123 Elm Str", zip_code: "50001", state: "CA", custom_field_values: { "year_built"=>1920, "was_church"=>"yes" } },
      { address: "123 Oak Street", zip_code: "50002", state: "CA", custom_field_values: { "year_built"=>1985, "was_church"=>"no" } }
    ]
  end

  buildings.each do |attrs|
    building = client.buildings.find_or_create_by!(address: attrs[:address]) do |b|
      b.zip_code = attrs[:zip_code]
      b.state = attrs[:state]
      b.custom_field_values = attrs[:custom_field_values]
    end
    puts "Seeded building: #{building.address} with custom fields: #{building.custom_field_values.inspect}\n"
  end
  puts "-------------------------------------------------------"
end

puts "\n------------ BUILDINGS SEEDED SUCCESSFULLY ------------\n"
