-- Create the Province table
CREATE TABLE Province (
    province_id INT PRIMARY KEY,
    province_name VARCHAR(100) NOT NULL
);

-- Create the Municipality table
CREATE TABLE Municipality (
    municipality_id INT PRIMARY KEY,
    municipality_name VARCHAR(100) NOT NULL,
    population INT,
    province_id INT,
    FOREIGN KEY (province_id) REFERENCES Province(province_id)
);

-- Create the Housing_Type table (e.g., social rental, private rental, owner-occupied)
CREATE TABLE Housing_Type (
    housing_type_id INT PRIMARY KEY,
    housing_type_name VARCHAR(100) NOT NULL
);

-- Create the Household_Type table (e.g., students, young adults, families)
CREATE TABLE Household_Type (
    household_type_id INT PRIMARY KEY,
    household_type_name VARCHAR(100) NOT NULL
);

-- Create the Housing_Statistic table
CREATE TABLE Housing_Statistic (
    housing_statistic_id INT PRIMARY KEY,
    year INT NOT NULL,
    average_sale_price DECIMAL(12,2),
    average_monthly_rent DECIMAL(10,2),
    number_of_homes INT,
    municipality_id INT,
    housing_type_id INT,
    FOREIGN KEY (municipality_id) REFERENCES Municipality(municipality_id),
    FOREIGN KEY (housing_type_id) REFERENCES Housing_Type(housing_type_id)
);

-- Create the Affordability_Statistic table
CREATE TABLE Affordability_Statistic (
    affordability_statistic_id INT PRIMARY KEY,
    year INT NOT NULL,
    average_income DECIMAL(12,2),
    average_housing_cost DECIMAL(10,2),
    municipality_id INT,
    household_type_id INT,
    FOREIGN KEY (municipality_id) REFERENCES Municipality(municipality_id),
    FOREIGN KEY (household_type_id) REFERENCES Household_Type(household_type_id)
);

