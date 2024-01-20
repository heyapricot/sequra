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

  describe "#first_disbursement_of_month?" do
    context "when the merchant has a daily disbursement frequency" do
      let!(:merchant) do
        create(:merchant, disbursement_frequency: Merchant.disbursement_frequencies[:daily])
      end

      context "when a disbursement from the previous month exists" do
        let(:creation_date) { 1.month.ago.end_of_month }
        let!(:previous_disbursement) { create(:disbursement, merchant:, created_at: creation_date) }
        let(:disbursement) { create(:disbursement, merchant:, created_at: creation_date + 1.day) }

        it "returns true" do
          expect(disbursement.first_disbursement_of_month?).to eq(true)
        end
      end

      context "when a disbursement from the previous month does not exist" do
        let(:disbursement) { create(:disbursement) }

        it "returns false" do
          expect(disbursement.first_disbursement_of_month?).to eq(false)
        end
      end
    end

    context "when the merchant has a weekly disbursement frequency" do
      let!(:merchant) do
        create(:merchant, disbursement_frequency: Merchant.disbursement_frequencies[:weekly])
      end

      context "when a disbursement from the previous month exists" do
        let(:creation_date) { 1.month.ago.end_of_month }
        let!(:previous_disbursement) { create(:disbursement, merchant:, created_at: creation_date) }

        context "when a week has passed from the latest disbursement" do
          let(:disbursement) { create(:disbursement, merchant:, created_at: creation_date + 7.days) }

          it "returns true" do
            expect(disbursement.first_disbursement_of_month?).to eq(true)
          end
        end

        context "when a week has not passed from the latest disbursement" do
          let(:disbursement) { create(:disbursement, merchant:, created_at: creation_date + 6.days) }

          it "returns false" do
            expect(disbursement.first_disbursement_of_month?).to eq(false)
          end
        end
      end
    end
  end
end
