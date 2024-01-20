# README
Author: Alvaro Sanchez
## Tools versions
The project uses Ruby 3.3.0 and Rails 7.1.3
## Setup
- After extracting the project, change to the sequra directory using your CLI
- Run `bundle install`

### Import Merchants
The directory `app/services/merchant_importer.rb` contains the class MerchantImporter with a `call`method to import merchants from a CSV file.
It expects the CSV file to have the columns: reference, email, live_on, disbursement_frequency, minimum_monthly_fee

#### Via Rails Console
- Open a terminal and the rails console by running the `rails c`command inside the terminal
- Once the rails console loads, run `MerchantImporter.call('path/to/merchants.csv')`

### Import Orders
The directory `app/services/order_importer.rb` contains a class OrderImporter with a method `call` to import orders from a CSV file.
It expects the CSV file to have the columns: amount, created_at

#### Via Rails Console
- Open a terminal and the rails console by running the `rails c`command inside the terminal
- Once the rails console loads, run `OrderImporter.call('path/to/merchants.csv')`


## Execution
### Generate disbursements
The services directory contains a file named `generate_historic_disbursements.rb` with a class named GenerateHistoricDisbursements and a method `call`.
The `call` method iterates through a date range that matches the dates of the orders created_at property.
For each date, it gathers the merchant's with a daily disbursement frequency or the ones with a weekly disbursement frequency that matches the day of the week of the merchant live_on property.
The method iterates through each gathered merchant and verifies if orders exist for the current merchant in the received date.
If orders exist, it calculates the disbursement amount and creates a disbursement record for the merchant.

#### Via Rails Console
To generate the disbursements, run the following command in the rails console:
`GenerateHistoricDisbursements.call`

## Notes and comments
### Nice to haves
- Add a rake task to import merchants and orders
- Create a form to upload and process the merchant and order's CSV files respectively
- Create a sidekiq job to generate the disbursements everyday before 8:00 UTC


## Total disbursements per year

Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
-----|-------------------------|-------------------------------|----------------------|-----------------------------------------------------------|----------------------------------------------------------|
2022 | 1533                    | 23.639.066,18 €               | 213.540,41 €         | 13                                                        | 329,35 €                                                 |
2023 | 10247                   | 128.417.712,12 €              | 1.166.665,32 €       | 136                                                       | 3.110,19 €                                               |
