import pandas as pd

# Read the file
data = pd.read_csv("total_cases.csv", low_memory=False )
# transpose for ease use of dataframe
df = data.transpose()
# list of anything that isn't a country
arr = ['date', 'World', 'European Union', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania']
# delete from df
for i in arr:
    df = df.drop(index=i)

number_columns = len(df.columns) - 1
df.sort_values(by = number_columns, ascending=False, na_position='last', inplace = True)
print(df)
df1 = df[number_columns]

# datapy = data['Paraguay']
# datapy = datapy.iloc[ number_rows ]
# df = data.iloc[ number_rows ]
# print(datapy)


