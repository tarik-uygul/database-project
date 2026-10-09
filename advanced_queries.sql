USE housing_database;


-- Author: @gabrielaroscha
-- Query: Average sale price per municipality in 2025
-- Question: What is the average house sale price in each municipality in 2025?
-- Result: Municipalities ranked from highest to lowest average sale price.
-- Relevance: Identifies differences in housing prices between municipalities,
-- showing where purchasing a home is more expensive and potentially less affordable.

SELECT
    m.municipality_name,
    ROUND(AVG(hs.average_sale_price), 2) AS average_sale_price
FROM Municipality m
JOIN Housing_Statistic hs
    ON m.municipality_id = hs.municipality_id
JOIN Housing_Type ht
    ON hs.housing_type_id = ht.housing_type_id
WHERE ht.housing_type_name = 'Bestaande koopwoningen' -- changed the name to match the housing type in the database
    AND hs.year = 2025
GROUP BY m.municipality_id, m.municipality_name
ORDER BY average_sale_price DESC;


-- Author: @gabrielaroscha
-- Query: Municipalities with above-average house prices in 2025
-- Question: Which municipalities have average house sale prices higher
-- than the overall average recorded in the database in 2025?
-- Result: Municipalities with above-average sale prices, ranked by price.
-- Relevance: Highlights municipalities where housing prices are particularly
-- high compared with the other areas represented in the dataset.

SELECT
    m.municipality_name,
    ROUND(AVG(hs.average_sale_price), 2) AS municipality_average_price
FROM Municipality m
JOIN Housing_Statistic hs
    ON m.municipality_id = hs.municipality_id
WHERE hs.year = 2025
GROUP BY m.municipality_id, m.municipality_name
HAVING AVG(hs.average_sale_price) > (
    SELECT AVG(average_sale_price)
    FROM Housing_Statistic
    WHERE year = 2025
)
ORDER BY municipality_average_price DESC;



-- Author: @gabrielaroscha
-- Query: Municipalities with average house prices above 400,000 euros
-- Question: Which municipalities have an average sale price for existing
-- owner-occupied homes above 400,000 euros in 2025?
-- Result: Municipalities exceeding the 400,000-euro threshold.
-- Relevance: Identifies areas with relatively expensive housing,
-- helping illustrate affordability challenges for potential homebuyers

SELECT
    m.municipality_name,
    ROUND(AVG(hs.average_sale_price), 2) AS average_municipality_price
FROM Municipality m
JOIN Housing_Statistic hs
    ON m.municipality_id = hs.municipality_id
JOIN Housing_Type ht
    ON hs.housing_type_id = ht.housing_type_id
WHERE ht.housing_type_name = 'Bestaande koopwoningen' -- changed the name to match the housing type in the database
    AND hs.year = 2025
GROUP BY m.municipality_id, m.municipality_name
HAVING AVG(hs.average_sale_price) > 400000 -- changed the threshold to match the average sale price in the database
ORDER BY average_municipality_price DESC;



-- Author: @gabrielaroscha
-- Query: Municipalities with house prices above 500,000 euros
-- Question: Which municipalities have at least one housing statistic
-- record with an average sale price above 500,000 euros in 2025?
-- Result: Municipalities meeting the 500,000-euro price condition.
-- Relevance: Highlights expensive housing markets where high purchase
-- prices may create barriers for first-time buyers.

SELECT
    m.municipality_name
FROM Municipality m
WHERE EXISTS (
    SELECT 1
    FROM Housing_Statistic hs
    JOIN Housing_Type ht
        ON hs.housing_type_id = ht.housing_type_id
    WHERE hs.municipality_id = m.municipality_id
        AND ht.housing_type_name = 'Bestaande koopwoningen' -- changed the name to match the housing type in the database
        AND hs.year = 2025
        AND hs.average_sale_price > 500000
)
ORDER BY m.municipality_name;



-------------- Week 6 Select Queries --------------

-- Author: @WirexDae
-- Query: Housing cost burden per household type in 2025
-- This query shows which municipality and household type combinations spend the
--          largest share of their yearly income on housing.
-- Result:  The 10 highest cost burdens, as a percentage of income.
-- This result is highly relevant with our societal problem since it
--          shows the 10 municipalities that are the most affected by the problem.

SELECT
    m.municipality_name,
    ht.household_type_name,
    a.average_income,
    a.average_housing_cost,
    ROUND((a.average_housing_cost * 12) / a.average_income * 100, 2) AS housing_cost_percentage
FROM Affordability_Statistic a
         JOIN Municipality m
              ON a.municipality_id = m.municipality_id
         JOIN Household_Type ht
              ON a.household_type_id = ht.household_type_id
WHERE a.year = 2025
  AND a.average_income > 0
ORDER BY housing_cost_percentage DESC
    LIMIT 10;


-- Author: @WirexDae
-- Query: Sale price growth between 2024 and 2025
-- This query shows how much the average sale price changed per municipality and
--          housing type from 2024 to 2025.
-- Result:  Municipalities with the strongest price growth first.
-- This result is relevant to the societal problem by ordering the Municipalities
--          by the order of them getting affected by housing crisis.

SELECT
    m.municipality_name,
    ht.housing_type_name,
    hs_2024.average_sale_price AS price_2024,
    hs_2025.average_sale_price AS price_2025,
    ROUND(
            (hs_2025.average_sale_price - hs_2024.average_sale_price)
                / hs_2024.average_sale_price * 100, 2
    ) AS growth_percentage
FROM Housing_Statistic hs_2024
         JOIN Housing_Statistic hs_2025
              ON hs_2024.municipality_id = hs_2025.municipality_id
                  AND hs_2024.housing_type_id = hs_2025.housing_type_id
         JOIN Municipality m
              ON hs_2024.municipality_id = m.municipality_id
         JOIN Housing_Type ht
              ON hs_2024.housing_type_id = ht.housing_type_id
WHERE hs_2024.year = 2024
  AND hs_2025.year = 2025
  AND hs_2024.average_sale_price > 0
ORDER BY growth_percentage DESC;

-- Author: @tarik-uygul
-- Query: The Affordability Gap (Price-to-Income Ratio) in 2023
-- This query identifies municipalities where the disparity between house prices
--          and average local incomes is the most extreme.
-- Result:  The 10 municipalities with the highest price-to-income ratios.
-- This result is highly relevant to our societal problem as it pinpoints the
--          exact regions where first-time buyers are most severely priced out.

SELECT 
    m.municipality_name,
    hs.average_sale_price,
    ast.average_income,
    ROUND(hs.average_sale_price / ast.average_income, 2) AS price_to_income_ratio
FROM Municipality m
JOIN Housing_Statistic hs 
    ON m.municipality_id = hs.municipality_id
JOIN Affordability_Statistic ast 
    ON m.municipality_id = ast.municipality_id
WHERE hs.year = 2023 
  AND ast.year = 2023
ORDER BY price_to_income_ratio DESC
LIMIT 10;


-- Author: @tarik-uygul
-- Query: Accessible Housing Markets (High Income, Low Price) in 2023
-- This query finds regions where the local average income is above the national
--          average, but average house prices remain below the national average.
-- Result:  A list of municipalities offering the best purchasing power.
-- This result provides an actionable solution to the housing crisis by highlighting
--          economically viable regions for families and young professionals to relocate.

SELECT 
    m.municipality_name,
    ast.average_income,
    hs.average_sale_price
FROM Municipality m
JOIN Affordability_Statistic ast 
    ON m.municipality_id = ast.municipality_id
JOIN Housing_Statistic hs 
    ON m.municipality_id = hs.municipality_id
WHERE ast.year = 2023 
  AND hs.year = 2023
  AND ast.average_income > (SELECT AVG(average_income) FROM Affordability_Statistic WHERE year = 2023)
  AND hs.average_sale_price < (SELECT AVG(average_sale_price) FROM Housing_Statistic WHERE year = 2023)
ORDER BY hs.average_sale_price ASC;



-- Author: @gabrielaroscha
-- Query: Municipalities with decreasing house prices
-- Question: Which municipalities experienced a decrease in average
-- house sale prices between 2024 and 2025?
-- Relevance: Identifies areas where housing prices became lower,
-- providing insight into differences in housing market trends.

SELECT
    m.municipality_name,
    h2024.average_sale_price AS price_2024,
    h2025.average_sale_price AS price_2025
FROM Municipality m
JOIN Housing_Statistic h2024
    ON m.municipality_id = h2024.municipality_id
JOIN Housing_Statistic h2025
    ON m.municipality_id = h2025.municipality_id
    AND h2024.housing_type_id = h2025.housing_type_id
WHERE h2024.year = 2024
    AND h2025.year = 2025
    AND h2025.average_sale_price < h2024.average_sale_price
ORDER BY m.municipality_name;



-- Author: @gabrielaroscha
-- Query: Average house sale price by year
-- This query calculates the average house sale price
-- for each year available in the database.
-- Relevance: Helps identify long-term housing price trends
-- and understand how rising prices contribute to the housing crisis.

SELECT
    year,
    ROUND(AVG(average_sale_price), 2) AS average_house_price
FROM Housing_Statistic
WHERE average_sale_price IS NOT NULL
GROUP BY year
ORDER BY year;
