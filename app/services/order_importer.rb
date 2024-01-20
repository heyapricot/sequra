require "csv"

class OrderImporter
  def self.call(path)
    CSV.foreach(path, headers: true, col_sep: ";") do |row|
      merchant = Merchant.find_by!(reference: row["merchant_reference"])
      Order.create!(
        merchant:,
        **row.to_hash.slice("amount", "created_at")
      )
    end
  end
end
