class GenerateDayDisbursements
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def call
    orders = Order.where(merchant: merchants, created_at: date.beginning_of_day..date.end_of_day)
    disbursements = []

    merchants.each do |merchant|
      merchant_orders = orders.where(merchant:)
      next if merchant_orders.empty?

      disbursement = Disbursement.create!(merchant:, created_at: date)
      merchant_orders.update_all(disbursement_id: disbursement.id)
      disbursement.update!(
        merchant_disbursement_total: merchant_disbursement_total(merchant_orders),
        orders_fee_sum: orders_fee_sum(merchant_orders)
      )

      disbursement.generate_minimum_monthly_fee

      disbursements << disbursement
    end

    disbursements
  end

  private

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
