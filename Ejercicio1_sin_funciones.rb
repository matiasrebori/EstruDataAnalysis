require 'daru'

# escribir el algoritmo
# realizando sus propias funciones (busqueda, minimo, maximo, promedio y correlacion).

# read the file
data = Daru::DataFrame.from_csv('total_cases.csv')
# get number of rows, shape return array with number of rows and ncols
nrows = data.shape[0] - 1
# get vector from dataframe last row (last date)
df_total_cases = data.row[nrows]

# remove unused columns
arr = ['date', 'World', 'European Union', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania']
arr.each do |i|
  df_total_cases.delete_at(i)
end
df_total_cases.rename 'Casos'

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
# cases per million section
# ---------------------

# read csv
locations = Daru::DataFrame.from_csv('locations.csv')
locations = locations['population']
# new vector with population data an index its same as df_total_cases, now population and df_total_cases has same index
population = Daru::Vector.new(locations, index: df_total_cases.index, name: :population)
# operation between vectors to get total cases per million
df_cases_per_million = df_total_cases * 1_000_000 / population
df_cases_per_million.delete_at('International')
df_cases_per_million.rename('Casos por millon')
# round elements
df_cases_per_million = df_cases_per_million.round

# ---------------------
# 4 largest cases per million + py
# ---------------------

# sort descendent
df_highest = df_cases_per_million.sort(ascending: false)
# get first 4 elements
df_highest = df_highest.head(4)
# concat py value
df_highest.concat(df_cases_per_million['Paraguay'], 'Paraguay')
# print
puts 'los 4 países con mayores casos positivos por millón de habitantes. + Py'
puts df_highest.inspect

# ---------------------
# 4 smallest cases per million + py
# ---------------------

# sort asc
df_smallest = df_cases_per_million.sort
# get first 4 elements
df_smallest = df_smallest.head(4)
# concat py value
df_smallest.concat(df_cases_per_million['Paraguay'], 'Paraguay')
# print
puts 'los 4 países con menores casos positivos por millón de habitantes. + Py'
puts df_smallest.inspect

# ---------------------
# find cases per day section
# ---------------------

# clone df , if not any mod to df_for_cases affect data
df_for_cases = data.clone

# diff deletes the first row, so we too
first_row = 0

# delete unused columns
arr.each do |i|
  df_for_cases.delete_vector(i)
end
# clone the structure to a new dataframe
df_cases_per_day = df_for_cases.clone_structure
# delete first row to fit in diff result

df_cases_per_day.delete_row(first_row)

# loop over every column and do diff
columns = df_for_cases.vectors
columns.each do |i|
  df_cases_per_day[i] = df_for_cases[i].diff
end

# ---------------------
# last 10 days average all countries section
# ---------------------

def rounded_mean(arr)
  cant = arr.count
  total = arr.sum
  if cant != 0
    res = total / cant
    res = res.round
  else
    res = 0
  end
  res
end

# apply mean, round and rename
df_average = df_cases_per_day.tail(10).rename('Promedio')
# apply mean
puts 'Promedio diario de casos positivos de los últimos 10 días de todos los países'
# clone structure
df_avg = df_total_cases.clone
# get indexes
columns = df_avg.index.to_a
# iterate over every column
columns.each do |i|
  df_avg[i] = rounded_mean df_average[i]
end
puts df_avg.inspect

# ---------------------
#  correlation, cases per day
# ---------------------

def correlation(x, y)
  # this calculates correlation between to data arrays
  n = x.count
  # Finding the mean of the series x and y
  mean_x = x.sum / n
  mean_y = y.sum / n
  cov = 0
  std_x = 0
  std_y = 0
  range = [*0..n - 1]
  range.each do |i|
    cov += (x[i] - mean_x) * (y[i] - mean_y)
    std_x += (x[i] - mean_x)**2
    std_y += (y[i] - mean_y)**2
  end
  std_x **= 0.5
  std_y **= 0.5
  numerator = cov
  denominator = std_x * std_y
  if denominator != 0
    return numerator / denominator
  else
    return 0
  end
end

# get columns
df_for_corr = df_cases_per_day.tail(15)
columns = df_for_corr.vectors
# clone previous vector structure
df_corr = df_total_cases.clone_structure
df_corr.rename 'Correlacion'
# iterate
columns.each { |i| df_corr[i] = correlation(df_for_corr['Paraguay'], df_for_corr[i]) }
df_corr['Paraguay'] = -1
puts 'Los países que tienen la mayor correlación en los últimos 15 días, con respecto a Paraguay.'
puts df_corr.sort(ascending: false).head(15).inspect

# ---------------------
# Graph
# ---------------------

require 'matplotlib/pyplot'
plt = Matplotlib::Pyplot
# get the countries to plot, cases per day
df_for_plot = df_cases_per_day['Paraguay', 'Norway', 'Lithuania', 'Israel', 'Ireland']
# replace nil with 0
df_for_plot = df_for_plot.replace_values(nil, 0)
# date string
date = "desde: #{data['date'][0]} hasta: #{data['date'][nrows]}"
# array that stores days
x_axis = [*0..nrows - 1]
# begin to plot
plt.suptitle 'Grafico de Lineas'
plt.title date
plt.xlabel 'dias'
plt.ylabel 'casos por dia'
plt.plot x_axis, df_for_plot['Paraguay'].to_a, label: 'Paraguay'
plt.plot x_axis, df_for_plot['Norway'].to_a, label: 'Norway'
plt.plot x_axis, df_for_plot['Israel'].to_a, label: 'Israel'
plt.plot x_axis, df_for_plot['Lithuania'].to_a, label: 'Lithuania'
plt.plot x_axis, df_for_plot['Ireland'].to_a, label: 'Ireland'
plt.legend
plt.show
