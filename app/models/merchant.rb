class Merchant < ApplicationRecord
  enum :disbursement_frequency, {"daily" => "DAILY", "weekly" => "WEEKLY"}, suffix: true

  validates_presence_of :disbursement_frequency,
    :email,
    :live_on,
    :minimum_monthly_fee,
    :reference

  validates_numericality_of :minimum_monthly_fee, greater_than_or_equal_to: 0
end
