class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders

  validates_presence_of :merchant, :merchant_disbursement_total
  validates_numericality_of :merchant_disbursement_total, greater_than_or_equal_to: 0
end
