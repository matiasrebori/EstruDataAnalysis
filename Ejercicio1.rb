require 'daru'
# daru no tiene un equivalente nlargest, la funcion index_of_min no funciona bien
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
#
# get n largest indexes
indexes = df_total_cases.index_of_max 4
# slice
df_highest = df_total_cases[*indexes]
df_highest.rename 'Casos'
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

# get n largest indexes
indexes = df_cases_per_million.index_of_max 4
# slice
df_highest = df_cases_per_million[*indexes]
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
  # cast the Daru::Array to Numo::NArray to use diff function
  # x = Numo::NArray.cast(df_for_cases[i])
  # # save the result in his corresponding column
  # df_cases_per_day[i] = x.diff
  # Daru::Maths::Statistics::Vector diff
  df_cases_per_day[i] = df_for_cases[i].diff
end

# ---------------------
# last 10 days average all countries section
# ---------------------

# apply mean, round and rename
df_average = df_cases_per_day.tail(10).mean.round.rename('Promedio')
puts 'Promedio diario de casos positivos de los últimos 10 días de todos los países'
puts df_average.head.inspect

# ---------------------
#  correlation, cases per day
# ---------------------

# *********-slower function-************************

# # calculate correlation matrix
# df_for_corr = df_cases_per_day.tail(15)
# corr_matrix = df_for_corr.correlation
# puts corr_matrix
# # get countries with respect to paraguay
# corr = corr_matrix['Paraguay']

# *********-end slower function-********************

# ***********-faster function-********************
# get columns
df_for_corr = df_cases_per_day.tail(15)
columns = df_for_corr.vectors
# clone previus vector structure
corr = df_average.clone_structure.rename('Correlacion')
# temporal dataframe to store paraguay data and the other country
temp = Daru::DataFrame.new
temp['Paraguay'] = Daru::Vector.new(df_for_corr['Paraguay'])
# add one country, calculate correlation, delete country
columns.each do |i|
  temp[i] = Daru::Vector.new(df_for_corr[i])
  # temp.correlation return a 2x2 Daru::Dataframe
  corr_matrix = temp.correlation
  corr_number = corr_matrix['Paraguay']
  corr_number = corr_number[i]
  corr[i] = corr_number
  if i != 'Paraguay'
    temp.delete_vector(i)
  end
end
# ***********-end faster function-********************

# set paraguay with respect to paraguay to -1
corr['Paraguay'] = -1
corr = corr.replace_nils(0)
# sort descendent
corr = corr.sort(ascending: false)
# get first 15 elements
corr = corr.head(15)
puts 'Los países que tienen la mayor correlación en los últimos 15 días, con respecto a Paraguay.'
puts corr.inspect

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
