require "rails_helper"

RSpec.describe GenerateDayDisbursements, type: :service do
  describe "#call" do
    context "when a merchant has a daily disbursement frequency" do
      let!(:merchant) { create(:merchant, disbursement_frequency: Merchant.disbursement_frequencies[:daily]) }

      context "when orders exist for the given merchant and the given date" do
        let(:date) { Date.current }
        let!(:previous_orders) { (date - 2.days...date).flat_map{ |day| create(:order, merchant:, created_at: day) } }
        let!(:orders) { create_list(:order, 2, merchant:, created_at: date) }
        subject { described_class.new(date).call }

        it "creates a disbursement" do
          expect { subject }.to change { Disbursement.count }.by(1)
        end

        it "associates the orders of the current day to the disbursement" do
          expect(subject.first.orders).to match_array orders
        end

        it "does not associate orders older than the current day to the disbursement" do
          expect(subject.first.orders).not_to include previous_orders
        end

        it "sets the merchant_disbursement_total to the sum of the orders disbursement_amount" do
          expect(subject.first.merchant_disbursement_total).to be_within(0.01).of(orders.map(&:disbursement_amount).sum)
        end

        it "sets the orders_fee_sum to the sum of the orders sequra_commission" do
          expect(subject.first.orders_fee_sum).to be_within(0.01).of(orders.map(&:sequra_commission).sum)
        end
      end

      context "when orders exist for the given merchant on a previous date" do
        let(:previous_date) { Date.current - 1.day }
        let!(:previous_orders) { create_list(:order, 2, merchant:, created_at: previous_date) }

        context "when orders do not exist for the given merchant and the date given to initialize GenerateDayDisbursements " do
          let(:current_date) { Date.current }
          subject { described_class.new(current_date).call }

          it "does not create a disbursement" do
            expect { subject }.to_not change { Disbursement.count }
          end
        end
      end
    end

    context "when a merchant has a weekly disbursement frequency" do
      let!(:merchant) { create(:merchant, disbursement_frequency: Merchant.disbursement_frequencies[:weekly]) }

      context "when the current weekday is the same as the merchant's live_on date" do
        let(:date) { merchant.live_on + 14.days }

        context "when past orders exist for the given merchant" do
          let!(:past_orders) do
            create(:order, merchant:, created_at: merchant.live_on + 7.days)
            create(:order, merchant:, created_at: merchant.live_on + 6.days)
          end

          context "when orders from the last 7 days exist for the given merchant" do
            let!(:orders) do
              (merchant.live_on + 8.days..merchant.live_on + 14.days).flat_map do |date|
                create(:order, merchant:, created_at: date)
              end
            end

            subject { described_class.new(date).call }

            it "creates a disbursement" do
              expect { subject }.to change { Disbursement.count }.by(1)
            end

            it "associates the orders from the last 7 days to the disbursement" do
              expect(subject.first.orders).to match_array orders
            end

            it "does not associate orders older than 7 days from the date given" do
              expect(subject.first.orders).not_to include past_orders
            end

            it "sets the merchant_disbursement_total to the sum of the orders disbursement_amount" do
              expect(subject.first.merchant_disbursement_total).to be_within(0.01).of(orders.map(&:disbursement_amount).sum)
            end

            it "sets the orders_fee_sum to the sum of the orders sequra_commission" do
              expect(subject.first.orders_fee_sum).to be_within(0.01).of(orders.map(&:sequra_commission).sum)
            end
          end
        end
      end

      context "when the current weekday is not the same day that the merchant's live_on date" do
        let(:date) { merchant.live_on + 15.days }

        context "when orders exist for the given merchant and the given date" do
          let!(:orders) { create_list(:order, 2, merchant:, created_at: date) }
          subject { described_class.new(date).call }

          it "does not create a disbursement" do
            expect { subject }.to_not change { Disbursement.count }
          end
        end
      end
    end
  end
end
