class GenerateHistoricDisbursements
  START_DATE = "04/09/2022".to_date
  END_DATE = "07/11/2023".to_date

  def self.call
    (START_DATE..END_DATE).each do |date|
      GenerateDayDisbursements.new(date).call
    end
  end
end
