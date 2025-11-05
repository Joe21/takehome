FactoryBot.define do
  factory :building do
    association :client

    sequence(:address) { |n| "#{Faker::Address.street_address} #{n}" }
    zip5 { Faker::Address.zip_code[0..4] } 
    state { Building.states.keys.sample }

    # optional: sequence for uniqueness
    sequence(:address) { |n| "123 Main St #{n}" }
  end
end