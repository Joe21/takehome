FactoryBot.define do
  factory :building do
    association :client

    sequence(:address) { |n| "#{Faker::Address.street_address} #{n}" }
    zip_code { Faker::Number.number(digits: 5).to_s }
    state { Building.states.keys.sample.to_s }
  end
end