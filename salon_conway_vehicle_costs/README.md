This is the code for Deborah Salon and Matthew Wigginton Conway's submission to the 2017 NHTS Data Challenge. Our writeup is [here](writeup/salon_conway_vehicle_costs.pdf). This repository also contains our code.

The code primarily is used to link NHTS data with vehicle cost data from other sources described in the writeup. The following files are present; each file builds upon the previous file, so they are expected to be run in order. Most are Python notebooks, but the registration fees calculation is a Stata do-file.

1. [Merge Fuel Economy](code/Merge Fuel Economy.ipynb)
  This merges the NHTS vehicle file with EPA fuel economy data as well as TrueCar used vehicle sales listings, and assigns a fuel economy and an estimated monetary value to all matched vehicles.
2. [Impute Fuel Economy and Value](code/Impute Fuel Economy and Value.ipynb)
  This notebook uses multiple imputation to estimate fuel economy and value numbers for vehicles that were not matched.
3. [Fuel and Maintenance Costs](code/Fuel and Maintenance Costs.ipynb)
  This notebook estimates the fuel and maintenance costs for each vehicle in the NHTS vehicle file, based on state or PADD region fuel costs, fuel type, AAA maintenance cost estimates, and annual mileage.
4. [Insurance Rates](code/Insurance Rates.ipynb)
  This notebook estimates the insurance rates for each vehicle, based on the value of the vehicle, household income, primary driver age, and US state.
5. [Depreciation, MSRP, and Excise Taxes](code/Depreciation, MSRP, and Excise Taxes.ipynb)
  This notebook estimates the depreciation, MSRP, and, for vehicles registered in Indiana, the excise tax.
6. [Registration Fees](code/reg fees.do)
  This Stata do-file estimates the registration fees for each vehicle, based on state-specific formulae.
7. [Plots](code/Plots.ipynb)
  This produces this plots and summary outputs used in the writeup.

All of the data presented in the writeup is also available in the [summary_output](summary_output) folder:

* [amount_spent_on_vehicles_by_income.csv](summary_output/amount_spent_on_vehicles_by_income.csv)
  The median amount spent on vehicles by households of each NHTS income category.
* [annual_cost_per_vehicle_hist.csv](summary_output/annual_cost_per_vehicle_hist.csv)
  A histogram of the annual cost of operating vehicles in the 2017 NHTS.
* [annual_mileage_of_vehicles_with_average_cost_greater_than_1_50_per_mile_hist.csv](summary_output/annual_mileage_of_vehicles_with_average_cost_greater_than_1_50_per_mile_hist.csv)
  A histogram of the annual mileage of vehicles with operating costs > $1.50 per mile (vehicles which could conceivably be economically replaced by ridehailing)
* [average_cost_per_mile_hist.csv](summary_output/average_cost_per_mile_hist.csv)
  A histogram of the average cost per mile for vehicles in the 2017 NHTS.
* [cost_by_age.csv](summary_output/cost_by_age.csv)
  The median cost of operating a vehicle, by vehicle age.
* [cost_components_by_hh_income.csv](summary_output/cost_components_by_hh_income.csv)
  Components of vehicle operating costs, by household income (means within each income category).
* [cost_components_by_primary_driver_age.csv](summary_output/cost_components_by_primary_driver_age.csv)
  Components of vehicle operating costs, by primary driver age (means within each age category).
* [cost_components_by_vehicle_age.csv](summary_output/cost_components_by_vehicle_age.csv)
  Components of vehicle operating costs, by vehicle age (means within each age category).
* [household_cost_hist.csv](summary_output/household_cost_hist.csv)
  Histogram of the total amount spent by households on vehicle ownership.
* [household_vehicle_cost_by_density.csv](summary_output/household_vehicle_cost_by_density.csv)
  The median cost of vehicle ownership, by population density (medians within each density category).
* [marginal_cost_per_mile_hist.csv](summary_output/marginal_cost_per_mile_hist.csv)
  Histogram of the marginal per-mile cost (fuel and maintenance) of vehicle operation.
* [percent_hh_income_spent_on_vehicles_by_income.csv](summary_output/percent_hh_income_spent_on_vehicles_by_income.csv)
  The median percentage of household income spent on vehicles by households of each NHTS income category.
* [state_median_costs.csv](summary_output/state_median_costs.csv)
  The median cost of vehicle ownership in each state.
