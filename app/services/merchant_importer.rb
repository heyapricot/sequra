require "csv"

class MerchantImporter
  def self.call(path)
    CSV.foreach(path, headers: true, col_sep: ";") do |row|
      Merchant.create!(row.to_hash.except(:id))
    end
  end
end
