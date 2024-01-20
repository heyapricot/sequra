require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of(:disbursement_frequency) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:live_on) }
    it { should validate_presence_of(:reference) }
    it { should validate_presence_of(:minimum_monthly_fee) }
    it { should validate_numericality_of(:minimum_monthly_fee).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should have_many(:disbursements) }
    it { should have_many(:orders) }
  end
end
