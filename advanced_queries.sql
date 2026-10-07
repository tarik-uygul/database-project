USE housing_database;


-- Show the average sale price per municipality in 2025

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


-- Find municipalities whose average sale price in 2025
-- is higher than the overall average sale price in 2025

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



-- Find municipalities where the average sale price of existing homes
-- in 2025 is greater than 400,000 euros

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



-- Find municipalities that have at least one housing statistic record for existing homes that
-- record above 500,000 euros in 2025

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