class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders

  validates_presence_of :merchant, :merchant_disbursement_total
  validates_numericality_of :merchant_disbursement_total, greater_than_or_equal_to: 0

  def first_disbursement_of_month?
    last_disbursement_date = created_at - (merchant.daily_disbursement_frequency? ? 1.day : 1.week)

    last_disbursement = Disbursement.find_by(merchant:, created_at: last_disbursement_date)
    return false unless last_disbursement.present?

    last_disbursement.created_at.month != created_at.month
  end

  def generate_minimum_monthly_fee
    return unless first_disbursement_of_month? && should_charge_minimum_monthly_fee?

    monthly_fee_difference = merchant_minimum_monthly_fee - commission_sum
    update_attribute!(:monthly_fee_difference, monthly_fee_difference)
  end

  def should_charge_minimum_monthly_fee?
    commission_sum < merchant_minimum_monthly_fee
  end

  def commission_sum
    @commission_sum ||= orders.map(&:sequra_commission).sum
  end

  def merchant_minimum_monthly_fee
    @merchant_minimum_monthly_fee ||= merchant.minimum_monthly_fee
  end
end
