import pandas as pd

# ==========================================
# 1. Load and Clean Dataset A (Housing Prices)
# ==========================================
df_housing = pd.read_csv('housing_prices.csv', sep=';', skiprows=3)

df_housing.rename(columns={df_housing.columns[0]: 'Region'}, inplace=True)

# Remove province rows and the source row
df_housing = df_housing[
    ~df_housing['Region'].astype(str).str.contains(r'\(PV\)|^Bron:', regex=True, na=False)
].copy()

# Find the year columns
year_cols = [col for col in df_housing.columns if str(col).strip().isdigit()]
df_housing = df_housing[['Region'] + year_cols]

# Unpivot the table
df_housing = df_housing.melt(
    id_vars=['Region'],
    var_name='year',
    value_name='average_sale_price'
)

# Clean region names
df_housing['region_clean'] = (
    df_housing['Region']
    .astype(str)
    .str.replace(r' \((gemeente|[A-Z]\.)\)$', '', regex=True)
    .str.strip()
)

# Convert values to numbers and remove missing values
df_housing['year'] = pd.to_numeric(df_housing['year'], errors='coerce')
df_housing['average_sale_price'] = pd.to_numeric(
    df_housing['average_sale_price'],
    errors='coerce'
)
df_housing = df_housing.dropna(subset=['year', 'average_sale_price'])
df_housing['year'] = df_housing['year'].astype(int)

# Check and remove duplicates
housing_duplicates = df_housing.duplicated(
    subset=['region_clean', 'year']
).sum()
df_housing = df_housing.drop_duplicates(
    subset=['region_clean', 'year']
)


# ==========================================
# 2. Load and Clean Dataset B (Income)
# ==========================================
df_income = pd.read_csv('income.csv', sep=';', skiprows=6)
df_income.rename(columns={df_income.columns[0]: 'Region'}, inplace=True)

# Remove national, province and source rows
df_income = df_income[
    (df_income['Region'] != 'Nederland') &
    ~df_income['Region'].astype(str).str.contains(r'\(PV\)|^Bron:', regex=True, na=False)
].copy()

# Average disposable income column
income_col = '1 000 euro.2'

df_income = df_income[['Region', income_col]].copy()
df_income['year'] = 2023

# Clean region names
df_income['region_clean'] = (
    df_income['Region']
    .astype(str)
    .str.replace(r' \((gemeente|[A-Z]\.)\)$', '', regex=True)
    .str.strip()
)

# Convert income to euros and remove missing values
df_income['average_income'] = pd.to_numeric(
    df_income[income_col].astype(str).str.replace(',', '.'),
    errors='coerce'
) * 1000
df_income = df_income.dropna(subset=['average_income'])

# Check and remove duplicates
income_duplicates = df_income.duplicated(
    subset=['region_clean', 'year']
).sum()
df_income = df_income.drop_duplicates(
    subset=['region_clean', 'year']
)


# ==========================================
# 3. Generate SQL INSERT Statements
# ==========================================
all_municipalities = sorted(
    set(df_housing['region_clean']).union(set(df_income['region_clean']))
)
muni_map = {name: i + 1 for i, name in enumerate(all_municipalities)}

with open('real_world_data.sql', 'w', encoding='utf-8') as f:
    f.write("USE housing_database;\n\n")

    f.write("-- 1. Insert Municipalities\n")
    for name, m_id in muni_map.items():
        safe_name = name.replace("'", "''")
        f.write(
            f"INSERT INTO Municipality (municipality_id, municipality_name) "
            f"VALUES ({m_id}, '{safe_name}');\n"
        )

    f.write("\n-- 2. Insert Housing Types (Static)\n")
    f.write(
        "INSERT INTO Housing_Type (housing_type_id, housing_type_name) "
        "VALUES (1, 'Bestaande koopwoningen');\n"
    )

    f.write("\n-- 3. Insert Household Types (Static)\n")
    f.write(
        "INSERT INTO Household_Type (household_type_id, household_type_name) "
        "VALUES (1, 'Particuliere huishoudens');\n"
    )

    f.write("\n-- 4. Insert Housing Statistics\n")
    stat_id = 1
    for _, row in df_housing.iterrows():
        m_id = muni_map.get(row['region_clean'])
        if m_id:
            f.write(
                f"INSERT INTO Housing_Statistic "
                f"(housing_statistic_id, year, average_sale_price, municipality_id, housing_type_id) "
                f"VALUES ({stat_id}, {row['year']}, {row['average_sale_price']}, {m_id}, 1);\n"
            )
            stat_id += 1

    f.write("\n-- 5. Insert Affordability Statistics\n")
    aff_id = 1
    for _, row in df_income.iterrows():
        m_id = muni_map.get(row['region_clean'])
        if m_id:
            f.write(
                f"INSERT INTO Affordability_Statistic "
                f"(affordability_statistic_id, year, average_income, municipality_id, household_type_id) "
                f"VALUES ({aff_id}, {row['year']}, {row['average_income']:.2f}, {m_id}, 1);\n"
            )
            aff_id += 1

print("Housing duplicates found:", housing_duplicates)
print("Income duplicates found:", income_duplicates)
print("Housing rows:", len(df_housing))
print("Income rows:", len(df_income))
print("SQL file 'real_world_data.sql' generated successfully!")
