import pandas as pd

# ==========================================
# 1. Load and Clean Dataset A (Housing Prices)
# ==========================================
# Try reading with different skiprows to find the actual header
df_housing = pd.read_csv('housing_prices.csv', sep=';', skiprows=4)

# Force rename the very first column to 'Region' to avoid any spelling/space issues
df_housing.rename(columns={df_housing.columns[0]: 'Region'}, inplace=True)

# Dynamically find all columns that are just numbers (the years)
year_cols = [col for col in df_housing.columns if str(col).strip().isdigit()]
df_housing = df_housing[['Region'] + year_cols]

# Unpivot (melt) the table
df_housing = df_housing.melt(id_vars=["Region"], var_name="year", value_name="average_sale_price")

# Clean up Region names (remove the ' (PV)' or ' (GM)' and strip spaces)
df_housing['region_clean'] = df_housing["Region"].astype(str).str.replace(r' \([A-Z]+\)', '', regex=True).str.strip()

# Convert price to number, forcing errors (like '.') to NaN, then drop NaNs
df_housing['average_sale_price'] = pd.to_numeric(df_housing['average_sale_price'], errors='coerce')
df_housing = df_housing.dropna(subset=['average_sale_price'])


# ==========================================
# 2. Load and Clean Dataset B (Income)
# ==========================================
# Based on the screenshot, the header is on row 7, so we skip 6 rows
df_income = pd.read_csv('income.csv', sep=';', skiprows=6)
df_income.rename(columns={df_income.columns[0]: 'Region'}, inplace=True)

# Dynamically find the column that contains '1 000 euro' and 'Gemiddeld'
income_cols = [col for col in df_income.columns if '1 000 euro' in str(col) and 'Gemiddeld' in str(col)]
income_col = income_cols[0] if income_cols else df_income.columns[3] # Fallback to 4th column

df_income = df_income[['Region', income_col]].copy()
df_income['year'] = 2023
df_income['region_clean'] = df_income["Region"].astype(str).str.replace(r' \([A-Z]+\)', '', regex=True).str.strip()

# Convert income to euros and handle missing data
df_income['average_income'] = pd.to_numeric(df_income[income_col].astype(str).str.replace(',', '.'), errors='coerce') * 1000
df_income = df_income.dropna(subset=['average_income'])


# ==========================================
# 3. Generate SQL INSERT Statements
# ==========================================
# Combine all unique clean municipalities from both datasets
all_municipalities = set(df_housing['region_clean']).union(set(df_income['region_clean']))
muni_map = {name: i+1 for i, name in enumerate(all_municipalities)}

with open('real_world_data.sql', 'w') as f:
    f.write("-- 1. Insert Municipalities\n")
    for name, m_id in muni_map.items():
        # Dummy province_id 1 used here
        f.write(f"INSERT INTO Municipality (municipality_id, municipality_name, province_id) VALUES ({m_id}, '{name}', 1);\n")
        
    f.write("\n-- 2. Insert Housing Types (Static)\n")
    f.write("INSERT INTO Housing_Type (housing_type_id, housing_type_name) VALUES (1, 'Bestaande koopwoningen');\n")
    
    f.write("\n-- 3. Insert Household Types (Static)\n")
    f.write("INSERT INTO Household_Type (household_type_id, household_type_name) VALUES (1, 'Particuliere huishoudens');\n")

    f.write("\n-- 4. Insert Housing Statistics\n")
    stat_id = 1
    for _, row in df_housing.iterrows():
        m_id = muni_map.get(row['region_clean'])
        if m_id:
            f.write(f"INSERT INTO Housing_Statistic (housing_statistic_id, year, average_sale_price, municipality_id, housing_type_id) "
                    f"VALUES ({stat_id}, {row['year']}, {row['average_sale_price']}, {m_id}, 1);\n")
            stat_id += 1

    f.write("\n-- 5. Insert Affordability Statistics\n")
    aff_id = 1
    for _, row in df_income.iterrows():
        m_id = muni_map.get(row['region_clean'])
        if m_id:
            f.write(f"INSERT INTO Affordability_Statistic (affordability_statistic_id, year, average_income, municipality_id, household_type_id) "
                    f"VALUES ({aff_id}, {row['year']}, {row['average_income']}, {m_id}, 1);\n")
            aff_id += 1

print("SQL file 'real_world_data.sql' generated successfully!")