class Order < ApplicationRecord
  belongs_to :disbursement, optional: true
  belongs_to :merchant

  validates_numericality_of :amount, greater_than: 0
  validates_presence_of :amount

  def disbursement_amount
    amount - sequra_commission
  end

  def sequra_commission
    amount * sequra_commission_rate
  end

  def sequra_commission_rate
    case amount
    when 0..50
      0.01
    when 51..300
      0.0095
    else
      0.0085
    end
  end
end
