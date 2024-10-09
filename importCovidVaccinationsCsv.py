import pandas as pd
from mysqlconnector import create_connection

# Load CSV file using pandas
csv_file_path = 'CovidVaccinations.csv'
df = pd.read_csv(csv_file_path)

# For reference, inspect data types
print("Data Types of Each Column in file: ")
print(df.dtypes)

# Remove leading/trailing spaces from column names
df.columns = df.columns.str.strip()

# Clean up any newline characters
df.replace({'\n': '', '\r': ''}, regex=True, inplace=True)

# replace NaN with None, treated as NULL in MySQL
df = df.where(pd.notnull(df), None)

# Connect to DB
connection = create_connection()
cursor = connection.cursor()

# Map pandas dtypes to MySQL data types
def map_dtype_to_mysql(dtype):
    match str(dtype):
        case 'object':
            return 'VARCHAR(100)'
        case 'int64':
            return 'INT'
        case 'float64':
            return 'FLOAT'
        case 'bool':
            return 'BOOLEAN'
        case 'datetime64[ns]':
            return 'DATETIME'
        case _:
            return 'TEXT'

# Drop table if it exists
table_name = 'covidvaccinations'
drop_table_query = f"DROP TABLE IF EXISTS {table_name};"
cursor.execute(drop_table_query)
print(f"Table {table_name} dropped if existed")

# Generate column definitions based on df dtype
columns = ', '.join([f"{col} {map_dtype_to_mysql(dtype)}" for col, dtype in df.dtypes.items()])
print(columns)

# Create table query
create_table_query = f"CREATE TABLE {table_name} ({columns});"
print(f"Created table {table_name}")
cursor.execute(create_table_query)

# Insert data into MySQL table
# Convert df to list of tuples to insert
for i, row in df.iterrows():
    row_values = ', '.join(['%s'] * len(row))
    # Convert row to tuple and ensure NaNs are properly replaced with None
    row_tuple = tuple(None if pd.isna(value) else value for value in row)
    insert_query = f"INSERT INTO {table_name} VALUES ({row_values})"
    cursor.execute(insert_query, row_tuple)

# Commit the changes and close the connection
connection.commit()
cursor.close()
connection.close()
print("Connection closed.")

print(f"Data from {csv_file_path} has been successfully imported into MySQL table '{table_name}'")
