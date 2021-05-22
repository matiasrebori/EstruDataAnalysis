require 'daru'
# read the file
data = Daru::DataFrame.from_csv('total_cases.csv')
# get number of rows, shape return array with number of rows and ncols
nrows = data.shape[0] - 1
# get subset dataframe for last row (last date)
df_total_cases = data.row[nrows]
# remove unused columns
arr = ['date', 'World', 'European Union', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania']
arr.each do |i|
  df_total_cases.delete_at(i)
end
df_total_cases.rename 'Casos'

# ---------------------
# 4 largest countries + py
# ---------------------

# sort descendent
df_highest = df_total_cases.sort(ascending: false)
df_highest.rename 'Casos'
# get first 4 elements
df_highest = df_highest.head(4)
# concat py value
df_highest.concat(df_total_cases['Paraguay'], 'Paraguay')
# print
puts 'Los 4 países con mayores valores de total de casos positivos. + Py'
puts df_highest.inspect

# ---------------------
# 4 smallest countries + py
# ---------------------

# sort asc
df_smallest = df_total_cases.sort
df_smallest.rename 'Casos'
# get first 4 elements
df_smallest = df_smallest.head(4)
# concat py value
df_smallest.concat(df_total_cases['Paraguay'], 'Paraguay')
# print
puts 'Los 4 países con menores valores de total de casos positivos. + Py'
puts df_smallest.inspect

# ---------------------
# cases per million section
# ---------------------

# read csv
locations = Daru::DataFrame.from_csv('locations.csv')
# new vector with population data an index its same as df_total_cases, now population and df_total_cases has same index
population = Daru::Vector.new(locations['population'], index: df_total_cases.index, name: :population)
# operation between vectors
df_cases_per_million = df_total_cases * 1000000 / population
df_cases_per_million.rename('Casos por millon')
puts df_cases_per_million.inspect