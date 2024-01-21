class GenerateDayDisbursements
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def call
    disbursements = []
    last_seven_days = (date - 6.days..date)
    merchants.each do |merchant|
      merchant_orders = orders_of_the_week.where(
        merchant:,
        created_at: merchant.daily_disbursement_frequency? ? date : last_seven_days
      )

      next if merchant_orders.empty?

      disbursement = nil
      ActiveRecord::Base.transaction do
        disbursement = Disbursement.create!(merchant:, created_at: date)
        merchant_orders.update_all(disbursement_id: disbursement.id)
        disbursement.update!(
          merchant_disbursement_total: merchant_disbursement_total(merchant_orders),
          orders_fee_sum: orders_fee_sum(merchant_orders)
        )
      end

      disbursement.generate_minimum_monthly_fee
      disbursements << disbursement
    end

    disbursements
  end

  private

  def orders_of_the_week
    @orders_of_the_week ||= Order.where(merchant: merchants, created_at: ((date - 6.days).beginning_of_day..date.end_of_day))
  end

  def merchants
    return @merchants if @merchants.present?

    daily_merchants = Merchant.daily_disbursement_frequency
    weekly_merchants = Merchant.weekly_disbursement_frequency.where("EXTRACT(DOW FROM live_on) = ?", map_day_of_the_week_to_integer)

    @merchants = (daily_merchants + weekly_merchants)
    @merchants
  end

  def merchant_disbursement_total(orders)
    orders.map(&:disbursement_amount).sum
  end

  def map_day_of_the_week_to_integer
    date.strftime("%u").to_i % 7
  end

  def orders_fee_sum(orders)
    orders.map(&:sequra_commission).sum
  end
end
