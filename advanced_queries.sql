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