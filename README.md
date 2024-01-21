# README
Author: Alvaro Sanchez
## Tools versions
The project uses Ruby 3.3.0 and Rails 7.1.3. 
In addition, postgresql version 16 was used while developing. Ignore rails' default Dockerfile.
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
### Currency precision
- While there are recommendations for using the [Money gem](https://rubymoney.github.io/money/), I don't have personal experience with it so I didn't use it. 
- A money format exists in potgresql but I read multiple recommendations to avoid using it and use the decimal format instead.
- Following the previous recommendation, I set a default precision of 8 and a scale of 2 for the amount column in the disbursements table. It wasn't until later that I saw orders had more than a million records. Given that Information I would change the precision and scale and have a discussion about what fits the business needs.
- I also want to foster an agreement for a rounding strategy in calculations like the sequra commission.  

### Nice to haves
- Add a rake task to import merchants and orders
- Create a form to upload and process the merchant and order's CSV files respectively
- Create a sidekiq job to generate the disbursements everyday before 8:00 UTC
- A frontend to generate and display the disbursements table.
- Given the time constraints, I decided to focus on the core of the problem.

### Querying data
- The sum of sequra comission, disbursed quantiy and the monthly fee difference is stored in the disbursement table. Speed is gained by having the calculation result stored instead of generated everytime it's required. The tradeoff is that there is the possibility of a mismatch between the stored data and the live data if an order is altered or destroyed. 
- A method could be called to recalculate and update a disbursement if any of their associated orders is altered to mitigate the scenario mentioned above.
- Get the data for the table below the command `Disbursement.where(created_at: ("01/01/2023".to_date.."31/12/2023".to_date))`was used to get the data from the year 2023.
- Once the query was performed, the required columns, merchant_disbursement_total and orders_fee_sum were summed. If the query abve was stored to a variable named `dis`you can run `dis.sum(:merchant_disbursement_total)` to get the sum of the amount disbursed to merchants.
- To gather the disbursements that involved a minimum monthly fee you can do a sub query like this: `dis.where("monthly_fee_difference > ?", 0)`


## Total disbursements per year

Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
-----|-------------------------|-------------------------------|----------------------|-----------------------------------------------------------|----------------------------------------------------------|
2022 | 1547                    | 37.513.789,25 €               | 338.907,53 €         | 19                                                        | 466,62 €                                                 |
2023 | 10350                   | 187.418.811,04 €              | 1.698.491,74 €       | 168                                                       | 3.656,09 €                                               |
