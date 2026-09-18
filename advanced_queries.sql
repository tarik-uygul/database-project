USE housing_database;


-- Show the average private rental price per municipality in 2025

SELECT
    m.municipality_name,
    AVG(hs.average_monthly_rent) AS average_private_rent
FROM Municipality m
JOIN Housing_Statistic hs
    ON m.municipality_id = hs.municipality_id
JOIN Housing_Type ht
    ON hs.housing_type_id = ht.housing_type_id
WHERE hs.year = 2025
    AND ht.housing_type_name = 'Private rental'
GROUP BY m.municipality_id, m.municipality_name
ORDER BY average_private_rent DESC;


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



-- Find provinces where the average private monthly rent
-- in 2025 is greater than 1200 euros

SELECT
    p.province_name,
    ROUND(AVG(hs.average_monthly_rent), 2) AS average_private_rent
FROM Province p
JOIN Municipality m
    ON p.province_id = m.province_id
JOIN Housing_Statistic hs
    ON m.municipality_id = hs.municipality_id
JOIN Housing_Type ht
    ON hs.housing_type_id = ht.housing_type_id
WHERE hs.year = 2025
    AND ht.housing_type_name = 'Private rental'
GROUP BY p.province_id, p.province_name
HAVING AVG(hs.average_monthly_rent) > 1200
ORDER BY average_private_rent DESC;



-- Find municipalities that have a private rental
-- record above 1200 euros per month in 2025

SELECT
    m.municipality_name
FROM Municipality m
WHERE EXISTS (
    SELECT 1
    FROM Housing_Statistic hs
    JOIN Housing_Type ht
        ON hs.housing_type_id = ht.housing_type_id
    WHERE hs.municipality_id = m.municipality_id
        AND hs.year = 2025
        AND ht.housing_type_name = 'Private rental'
        AND hs.average_monthly_rent > 1200
)
ORDER BY m.municipality_name;



