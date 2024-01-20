FactoryBot.define do
  factory :order do
    association :merchant
    association :disbursement
    amount { Faker::Number.decimal(l_digits: 2) }
  end
end
