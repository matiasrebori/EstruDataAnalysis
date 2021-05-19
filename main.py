import pandas as pd
import matplotlib.pyplot as plt
# Read the file
df_total_cases = pd.read_csv("total_cases.csv", low_memory=False)
# list of anything that isn't a country
arr = ['World', 'European Union', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania']
# delete from dataframe
for i in arr:
    df_total_cases = df_total_cases.drop(columns=i)
data = df_total_cases
data = data.drop(columns='date')
number_rows = len(data) - 1
# get subset dataframe for last row (last date)
df = data.iloc[number_rows]
# get number of total cases from paraguay
py = df.loc['Paraguay']
# sort new dataframe descending order
# df = df.sort_values(ascending=False, na_position='last')

'''
    ##### 4 largest countries + py ######
'''

# temporal Series for the query
temp = df.nlargest(4)
# new Series to append temp with py data
tempy = pd.Series(data=[py], index=['Paraguay'])
# append
temp = temp.append(tempy)
# make new dataframe
temp = temp.to_frame(name='Los 4 países con mayores valores de total de casos positivos. + Py')
print(temp)

'''
    ##### 4 smallest countries + py ######
'''

temp = df.nsmallest(4).append(tempy)
temp = temp.to_frame(name='Los 4 países con menores valores de total de casos positivos. + Py')
print(temp)

'''
    ##### cases per million section ######
'''

# Read the file
df_locations = pd.read_csv("locations.csv", low_memory=False)
# get total cases for last row (last date) in file total_cases
df_cases = data.iloc[number_rows]
# make it a series
s_cases = pd.Series(data=df_cases, name='casos')
# series with same index but data is number of population
s_population = pd.Series(data=df_locations['population'].array, index=df_locations['location'].array, name='population')
# empty array to store result values
arr = []
for i in df_cases.index:
    arr.append(s_cases[i]*1000000/s_population[i])
# result series
s_cases_per_million = pd.Series(data=arr, index=df_locations['location'].array, name='casos por millon')
# round data
s_cases_per_million = s_cases_per_million.round()
# get number of total cases from paraguay
py = s_cases_per_million.loc['Paraguay']
tempy = pd.Series(data=[py], index=['Paraguay'])

'''
    ##### 4 largest cases per million + py ######
'''

temp = s_cases_per_million.nlargest(4).append(tempy)
temp = temp.to_frame(name='los 4 países con mayores casos positivos por millón de habitantes. + Py')
print(temp)

'''
    ##### 4 smallest cases per million + py ######
'''

temp = s_cases_per_million.nsmallest(4).append(tempy)
temp = temp.to_frame(name='los 4 países con menores casos positivos por millón de habitantes. + Py')
print(temp)

'''
    ##### Ejercicio e , last 10 days average all countries ######
'''
# get subset dataframe with last 11 rows to process
df_average = df_total_cases.tail(11)
# index numbers for getting dates
first_index = df_average.index[1]
last_index = df_average.index[-1]
# text getting dates
days_date = 'fecha inicio: ' + df_average['date'][first_index] + ' hasta: ' + df_average['date'][last_index]
# del date column
df_average = df_average.drop(columns='date')
print('\nPromedio diario de casos positivos de los últimos 10 días de todos los países.\n' + days_date + '\n')
# get index in form of list
index = df_average.index.tolist()
# pop first element, we need 11 records to process but result is 10 rows
index.pop(0)
# temporal series to save diary cases
s_diary_cases = pd.Series(index=index, dtype='float64')
# result series with mean for every country
s_mean = pd.Series(index=df_average.columns, dtype='float64', name='promedio')
for i in df_average.columns:
    for j in index:
        # calculate diary cases per country: date 2 diary cases = date 2 total cases - date 1 total cases
        s_diary_cases[j] = df_average[i][j] - df_average[i][j-1]
    # find de average per country
    s_mean[i] = s_diary_cases.mean().round()
# print all rows
# pd.set_option('display.max_rows', None)
print(s_mean)

'''
    ##### Ejercicio f , correlation cases per day######
'''
# last 15 rows cases per day
df_corr = data.tail(16).diff()
#delete null row
df_corr = df_corr.drop(index=df_corr.index.start)
# result series
s_corr = pd.Series(index=df_corr.columns, dtype='float64', name='correlacion')
# perform correlation on every column with py
for i in df_corr.columns:
    s_corr[i] = df_corr[i].corr(df_corr['Paraguay'])
s_corr['Paraguay'] = 0
print('Buscar cuales son los países que tienen la mayor correlación, con respecto a su curva de casos positivos en los últimos 15 días, con respecto a Paraguay.')
print(s_corr.nlargest(10))
# df_corr = df_corr.corr().loc[:,'Paraguay']
# print(df_corr.nlargest(10))

'''
    ##### Ejercicio g , grafico ######
'''
arr = ['Paraguay', 'Brazil', 'Argentina', 'Bolivia', 'Uruguay']
df_plot = pd.DataFrame(dtype='float64')
for i in arr:
    df_plot[i]=df_total_cases[i]
df_plot = df_plot.diff()
df_plot.insert(loc=0, column='date', value=df_total_cases['date'])
df_plot.plot(x='date', y=arr)
plt.show()
