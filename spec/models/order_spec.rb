require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:amount) }
  end

  describe "associations" do
    it { should belong_to(:merchant) }
  end
end
