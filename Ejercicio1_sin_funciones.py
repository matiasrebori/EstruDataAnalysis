import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# escribir el algoritmo
# realizando sus propias funciones (busqueda, minimo, maximo, promedio y correlacion).
# to sort dict
import operator
# Read the file
df_total_cases = pd.read_csv("total_cases.csv", low_memory=False)
# list of anything that isn't a country
arr = ['World', 'European Union', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania']
# delete from dataframe
for i in arr:
    df_total_cases = df_total_cases.drop(columns=i)
data = df_total_cases
data = data.drop(columns='date')
number_rows = data.index.stop - 1
# get subset dataframe for last row (last date)
df = data.iloc[number_rows]
# get number of total cases from paraguay
py = df.loc['Paraguay']

'''
    ##### function ######
'''


def nlargesmall_est(largest, serie, n):
    # py value
    py = int(serie.loc['Paraguay'])
    x = serie.to_dict()
    # sort dict
    if largest is True:
        # descending order
        sorted_x = sorted(x.items(), key=operator.itemgetter(1), reverse=True)
    else:
        # ascending order
        sorted_x = sorted(x.items(), key=operator.itemgetter(1), reverse=False)
    # array for index
    index = np.empty(n, dtype=object)
    # array for the values
    values = np.empty(n, dtype=object)
    for i in range(n):
        index[i] = sorted_x[i][0]
        values[i] = sorted_x[i][1]
    # new ordered series
    s = pd.Series(data=values, index=index)
    tempy = pd.Series(data=[py], index=['Paraguay'])
    s = s.append(tempy)
    print(s)


'''
    ##### 4 smallest countries + py ######
'''
print('Los 4 países con menores valores de total de casos positivos. + Py')
nlargesmall_est(False, df, 4)


'''
    ##### 4 largest countries + py ######
'''
print('Los 4 países con mayores valores de total de casos positivos. + Py')
nlargesmall_est(True, df, 4)


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
# s_population = s_population.drop(columns='International')
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
s_population = s_population.drop(index='International')
s_cases_per_million = s_cases_per_million.drop(index='International')
print('los 4 países con mayores casos positivos por millón de habitantes. + Py')
nlargesmall_est(True, s_cases_per_million, 4)
'''
    ##### 4 smallest cases per million + py ######
'''
print('los 4 países con menores casos positivos por millón de habitantes. + Py')
nlargesmall_est(False, s_cases_per_million, 4)

'''
    ##### Ejercicio e , last 10 days average all countries ######
'''


def rounded_mean(series, n):
    x = series
    x = sum(x)
    mean = round(x/n)
    return mean


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
    s_mean[i] = rounded_mean(s_diary_cases.to_list(), len(s_diary_cases.index))
# print all rows
# pd.set_option('display.max_rows', None)
print(s_mean)

'''
    ##### Ejercicio f , correlation cases per day######
'''


# last 15 rows cases per day
df_corr = data.tail(16).diff()
# delete null row
df_corr = df_corr.drop(index=df_corr.index.start)
# pearson correlation formula, let be xi , yi individual sample point
# numerator is sum from n=1 to n ( ( xi - mean(x )*( yi - mean(y) ) )
# denominator is sqrt( std(x)*std(y) ) where st(x) d is sum from i = i to n ( xi - mean(x) )^2


def correlation(x, y):
    # this calculates correlation between to data arrays
    x = x
    n = len(x)
    # Finding the mean of the series x and y
    mean_x = sum(x)/float(len(x))
    mean_y = sum(y) / float(len(y))
    cov = 0
    std_x = 0
    std_y = 0
    for i in range(n):
        cov += (x[i]-mean_x)*(y[i]-mean_y)
        std_x += (x[i]-mean_x)**2
        std_y += (y[i] - mean_y) ** 2
    std_x = std_x**0.5
    std_y = std_y ** 0.5
    denominator = std_x*std_y

    def safe_div(numerator, denominator):
        if denominator == 0:
            return 0
        else:
            return numerator / denominator

    return safe_div(cov, denominator)


def corr(df, sample):
    # apply correlation to every column
    # columns name to iterate
    columns_name = df.columns.to_list()
    # series that store correlation
    s_result = pd.Series(index=columns_name, dtype='float64')
    for i in columns_name:
        # calculate correlation for every country
        s_result[i] = correlation(df[i].array, df[sample].array)
    return s_result


s_corr = corr(df_corr, 'Paraguay')
# hide paraguay result when doing nlargest
s_corr['Paraguay'] = -1
print('Los países que tienen la mayor correlación en los últimos 15 días, con respecto a Paraguay.')
print(s_corr.nlargest(10))

'''
    ##### Ejercicio g , grafico ######
'''
arr = ['Paraguay', 'Brazil', 'Argentina', 'Bolivia', 'Uruguay']
df_plot = pd.DataFrame(dtype='float64')
for i in arr:
    df_plot[i] = df_total_cases[i]
df_plot = df_plot.diff()
df_plot.insert(loc=0, column='date', value=df_total_cases['date'])
df_plot.plot(x='date', y=arr)
plt.show()

