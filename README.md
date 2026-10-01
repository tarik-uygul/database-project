# Database Project – Dutch Housing Affordability

## Project Overview

This project focuses on the Dutch housing crisis and housing affordability. The database is designed to store and analyse housing, municipality and household affordability data.

### Week 1 – Societal Problem

The societal problem is the Dutch housing crisis. Rising house prices and rental costs make affordable housing more difficult to find, especially for students, young adults and first-time buyers. Other relevant stakeholders include renters, homeowners, housing associations, banks, municipalities and the Dutch government.

The complete Week 1 societal problem definition and supporting articles are available here:

[Week 1 – Societal Problem](week1_societal_problem.pdf)

### Week 2 – ERD and Normalization

The database design was normalized up to 3NF.

- **1NF:** Repeating or multiple values were separated so each field contains one value.
- **2NF:** Attributes such as municipality names were separated from statistics data.
- **3NF:** Province information was stored in a separate `Province` table instead of repeating province names for every municipality.

The complete normalization explanation and ERD are available here:

[Week 2 – ERD and Normalization](week2_erd_normalization.pdf)

### Week 3 – Schema and SQL

The relational schema was implemented in MySQL with primary keys, foreign keys and appropriate data types. Mock data, basic SQL operations and advanced queries were added to test the database.

Relevant files:

- [`housing_database.sql`](housing_database.sql)
- [`mock_data.sql`](mock_data.sql)
- [`basic_operations.sql`](basic_operations.sql)
- [`advanced_queries.sql`](advanced_queries.sql)

### Week 4 – Stakeholder Presentation

The database was presented to stakeholders. The presentation included example query results, limitations, assumptions and possible future improvements.

[Week 4 – Stakeholder Presentation](Screen Recording 2026-09-26 at 11.06.42)

# Week 5 – Real-World Data Integration & Testing

### 1. Dataset Sources

To test the schema against real-world data, two complementary, openly licensed datasets were sourced from CBS StatLine. The datasets contain different types of information, so neither dataset is a subset of the other.

- **Dataset A (Housing):** *Bestaande koopwoningen; gemiddelde verkoopprijzen, regio* (Table 83625NED). Contains average sale prices per municipality and year. CBS metadata last changed: 17-02-2026. License: CC BY 4.0.
- **Dataset B (Income):** *Inkomen van huishoudens; huishoudenskenmerken, regio* (Table 86004NED). Contains average household disposable income per municipality. CBS metadata last changed: 08-10-2025. License: CC BY 4.0.

Both datasets contain at least 50 rows of unique data.

### 2. Data Cleaning and Integration

The raw CSV files required transformation before insertion into the database:

- **Missing Data:** Non-numeric missing values such as `.` were converted to missing values during numeric conversion, and rows without the required value were removed.
- **Date/Year Formatting:** The datasets use years rather than full dates. Housing year labels were converted to integers, while the income dataset was stored with year `2023`.
- **Naming Conventions:** National, province-level and source rows were removed where needed, and municipality names were cleaned.
- **Duplicate Records:** Both datasets were checked for duplicate municipality/year records. No duplicates were found.
- **Income Values:** Income values were given in thousands of euros and were converted to euros before insertion.
- **Constraints Check:** Municipality names containing apostrophes, such as `'s-Hertogenbosch`, were escaped before generating SQL statements.

After cleaning, the housing dataset contained **383 rows** and the income dataset contained **155 rows**.

The cleaned data is generated into [`real_world_data.sql`](real_world_data.sql) using [`clean_data.py`](clean_data.py).

### 3. Normalization (3NF) Validation

The database was checked again after inserting the real-world data and remains normalized up to 3NF.

Municipalities, housing types and household types are stored in separate tables. The `Housing_Statistic` and `Affordability_Statistic` tables reference these tables using foreign keys instead of repeating the same descriptive information.

The real-world data was inserted using this existing normalized structure, so no new normalization violations were introduced.

### 4. Query Adjustments & Meaningful Results

The Week 3 queries were tested again using the real-world data. The original queries were designed around rental data, while the real-world housing dataset contains sale prices for existing owner-occupied homes.

The queries were adapted to use `average_sale_price` and the housing type `Bestaande koopwoningen`. A `2025` filter was also added where required.

The original province-level query could not be used because the imported real-world data does not include province IDs for municipalities. This query was therefore adapted to compare municipalities instead.

After these changes, all four example queries returned meaningful results using the real-world data.

### 5. Limitations and Future Work

The Week 4 limitations were reviewed after adding the real-world data.

The original mock database contained only a small number of municipalities. The real-world datasets now provide much broader municipality coverage, but they still do not cover every housing characteristic needed for a complete affordability analysis.

Another limitation is that housing prices and income are represented as averages. Individual households and different areas within the same municipality can have very different financial situations. Average income and average housing prices should therefore only be treated as broad indicators of affordability.

The future work from Week 4 was also reviewed. Integrating real housing data from two different sources has now been completed. Adding more affordability-focused queries, improving the database based on feedback, and finalizing the project for submission remain future work.
