require "rails_helper"

RSpec.describe Disbursement, type: :model do
  describe "validations" do
    it { should validate_presence_of(:merchant) }
    it { should validate_presence_of(:merchant_disbursement_total) }
    it { should validate_numericality_of(:merchant_disbursement_total).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:merchant) }
    it { should have_many(:orders) }
  end
end
