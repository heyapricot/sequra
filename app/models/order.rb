class Order < ApplicationRecord
  belongs_to :disbursement, optional: true
  belongs_to :merchant

  validates_numericality_of :amount, greater_than: 0
  validates_presence_of :amount
end
