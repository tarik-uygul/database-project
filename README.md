 Week 5: Real-World Data Integration & Testing

### 1. Dataset Sources
To test the schema against real-world data, two complementary, openly licensed datasets were sourced from CBS StatLine (A ⊄ B):
* **Dataset A (Housing):** "Bestaande koopwoningen; gemiddelde verkoopprijzen, regio" (Table 83625NED). Contains average sale prices per municipality/year. License: CC BY 4.0.
* **Dataset B (Income):** "Inkomen van huishoudens; huishoudenskenmerken, regio" (Table 86004NED). Contains average household disposable income per municipality. License: CC BY 4.0.

### 2. Data Cleaning and Integration
Raw CSV files required transformation before insertion:
* **Missing Data:** CBS uses '.' for missing values. These were converted to `NULL` (dropped during the Pandas preprocessing) to avoid SQL type mismatch errors.
* **Date Formatting:** Years were extracted as integers to match the `year INT` schema constraint.
* **Naming Conventions:** Regional suffixes like ` (PV)` and ` (GM)` were stripped from strings to standardize municipality names.
* **Constraints Check:** An apostrophe syntax error in municipalities like `'s-Hertogenbosch` was resolved by escaping the character (`''`).

### 3. Normalization (3NF) Validation
The database remains fully normalized up to 3NF. To prevent foreign key constraint violations and data duplication, the unnormalized flat CSV data was inserted hierarchically: `Province` and `Municipality` first, followed by static reference tables (`Housing_Type`), and finally the transactional `Housing_Statistic` and `Affordability_Statistic` tables.

### 4. Query Adjustments & Meaningful Results
When running the original Week 3 queries on the real-world dataset, they returned zero results because the original queries filtered for `'Private rental'` (average_monthly_rent), while the open dataset contained data for owner-occupied homes (`'Bestaande koopwoningen'`). 

To address this limitation and produce meaningful business results, the analytical queries were adapted to evaluate `average_sale_price`. Thresholds were updated accordingly (e.g., searching for regions with average property values > €400,000 rather than rent > €1,200). The updated queries successfully executed and ranked the actual municipalities.