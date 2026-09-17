-- Add a new province
INSERT INTO Province (province_id, province_name)
VALUES (0, 'Limburg');

-- Add a new municipality linked to the province
INSERT INTO Municipality (municipality_id, municipality_name, population, province_id)
VALUES (0, 'Maastricht', 0, 0);

-- Add a housing type
INSERT INTO Housing_Type (housing_type_id, housing_type_name)
VALUES (0, 'housing');

-- Add a household type
INSERT INTO Household_Type (household_type_id, household_type_name)
VALUES (0, 'housing');

-- Add a housing statistic record
INSERT INTO Housing_Statistic (housing_statistic_id, year, average_sale_price, average_monthly_rent, number_of_homes, municipality_id, housing_type_id)
VALUES (0, 0, 0, 0, 0, 0, 0);

-- Add an affordability statistic record
INSERT INTO Affordability_Statistic (affordability_statistic_id, year, average_income, average_housing_cost, municipality_id, household_type_id)
VALUES (0, 0, 00, 0, 0, 0);


-- Update the population for a municipality
UPDATE Municipality
SET population = 0
WHERE municipality_id = 0;

-- Update monthly rent and number of homes for a specific housing statistic record
UPDATE Housing_Statistic
SET average_monthly_rent = 0,
    number_of_homes = 0,
    average_sale_price = 0
WHERE housing_statistic_id = 0;

-- Update the statistics for an affordability record
UPDATE Affordability_Statistic
SET average_income = 0,
    average_housing_cost = 0
WHERE affordability_statistic_id = 0;


-- Remove an affordability record
DELETE FROM Affordability_Statistic
WHERE affordability_statistic_id = 0;

-- Remove a housing statistic record
DELETE FROM Housing_Statistic
WHERE housing_statistic_id = 0;

-- only delete from the ones below after you delete their child references otherwise it will throw an error!!!!!

-- Remove a municipality
DELETE FROM Municipality
WHERE municipality_id = 0;

-- Remove a province
DELETE FROM Province
WHERE province_id = 0;

-- Remove a housing type
DELETE FROM Housing_Type
WHERE housing_type_id = 0;

-- Remove household type
DELETE FROM Household_Type
WHERE household_type_id = 0;