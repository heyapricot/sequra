FactoryBot.define do
  factory :merchant do
    reference { Faker::Company.name }
    email { Faker::Internet.email }
    live_on { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    disbursement_frequency { Merchant.disbursement_frequencies.keys.sample }
    minimum_monthly_fee { 0.0 }
  end
end
