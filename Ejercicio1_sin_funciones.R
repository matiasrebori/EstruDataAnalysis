#library to plot
library(ggplot2)
# escribir el algoritmo
# realizando sus propias funciones (busqueda, minimo, maximo, promedio y correlacion).
# busqueda es solo a nivel vector por lo tanto mi approach no necesita funcion aparte para busqueda

# Read the file
data <- read.csv("total_cases.csv")
# remove unused columns
data <- subset(data, select= -c(World, European.Union, Europe, Asia, North.America, South.America, Africa, Oceania))
# remove date
df_total_cases <- subset(data, select= -date)
# get subset dataframe for last row (last date)
df_total_cases <- tail(df_total_cases, n=1)
df_total_cases <- t(df_total_cases)
colnames(df_total_cases) <- 'Pais'

# ---------------------
# function definition
# ---------------------


nlargesmallest <- function(df, n, mode){
  # if mode == true descending order if not ascending order
  if (mode){
    #order
    indexes <- order(df, decreasing=TRUE)
  }else{
    indexes <- order(df, decreasing=FALSE)
  }
  # extract py value
  py_value <- df['Paraguay',1]
  py <- data.frame( Casos=py_value, row.names='Paraguay' )
  # select the first n sorted indexes
  indexes <- indexes[1:n]
  # select sorted rows trough indexes, same to row names
  df_cases <- data.frame( Casos=df[indexes,1] ,row.names = rownames(df)[indexes] )
  #append py value
  df_cases <- rbind(df_cases,py)
  print(df_cases)
}

# ---------------------
# 4 largest countries + py
# ---------------------

print('Los 4 países con mayores valores de total de casos positivos. + Py')
nlargesmallest(df_total_cases, 4, TRUE)

# ---------------------
# 4 smallest countries + py
# ---------------------

print('Los 4 países con menores valores de total de casos positivos. + Py')
nlargesmallest(df_total_cases, 4, FALSE)

# ---------------------
# cases per million section
# ---------------------

locations <- read.csv("locations.csv")
#deal with caracters in csv, so names are the same in the two dataframes
locations$location <- gsub(' ', '.', locations$location)
locations$location <- gsub('\'', '.', locations$location)
locations$location <- gsub('-', '.', locations$location)
locations$location <- gsub('[()]', '.', locations$location)
# merge, common data is country names so rownames in df_total_cases is same as location column in locations,
df_merge <- merge(x=df_total_cases, y=locations, by.x="row.names", by.y="location")
# mew df with cases per million rounded, every country total cases from last late and his population
df_cases_per_million <- data.frame( casos_por_millon= round (df_merge$Pais*1000000/df_merge$population) )
row.names(df_cases_per_million) <- locations$location
#extract py value
py_value_per_million <- df_cases_per_million['Paraguay',1]
py_per_million <- data.frame( Casos=py_value_per_million, row.names='Paraguay' )

# ---------------------
# 4 largest cases per million + py
# ---------------------

print('los 4 países con mayores casos positivos por millón de habitantes. + Py')
nlargesmallest(df_cases_per_million,4,TRUE)

# ---------------------
# 4 smallest cases per million + py
# ---------------------

print('los 4 países con menores casos positivos por millón de habitantes. + Py')
nlargesmallest(df_cases_per_million,4,FALSE)

# ---------------------
# Ejercicio e , last 10 days average all countries
# ---------------------

df_average <- subset(data, select= -date)
df_average <- tail(df_average, n=11)
# if in the df are NA values replace it with 0
df_average[is.na(df_average)] <- 0
#apply diff function(to get cases per day) to all columns , margin = 1 is loop over rows, na.rm is to not count null
df_average <- apply(df_average,2,diff)

# ---------------------
# function mean definition
# ---------------------

rounded_mean <- function( serie, n){
  x <- sum(serie)
  # r returns the last line if no explicit return is defined
  mean <- round(x/n)
}

# mean and round , margin 2 loop over columns
df_average <- apply(df_average,2, rounded_mean, nrow(df_average))
# make it dataframe structure
df_average <- data.frame( df_average )
# rename column name
colnames(df_average) <- 'Promedio diario de casos'
print('Promedio diario de casos positivos de los últimos 10 días de todos los países')
print(head(df_average))

# ---------------------
# Ejercicio f , correlation cases per day
# ---------------------

# ---------------------
# function corr_formula definition
# ---------------------

# pearson correlation formula is:
# cov(x,y) / sd(x)*sd(y) . cov is covariance between x and y , sd means standard deviation
# nota: podia copiar el codigo de python y adaptar rapidamente, hice otro approach mirando la formula, la documentacion y viendo si las funciones eran compatibles
corr_formula <- function(x,y){
  corr <- cov(x,y) / ( sd(x)*sd(y) )
  # r returns the last line if no explicit return is defined
}

# last 15 rows cases per day
df_corr <- subset(data, select= -date)
df_corr <- tail(df_corr, n=16)
# if in the df are NA values replace it with 0
df_corr[is.na(df_corr)] <- 0
# get cases per day
df_corr <- data.frame(diff(as.matrix(df_corr)))
# correlation function per each column, method is pearson
df_corr <- apply(df_corr,2, corr_formula, df_corr$Paraguay)
# make it dataframe structure
df_corr <- data.frame( df_corr )
#order with descending order, order returns indexes sorted , dataframe is not sorted
indexes <- order(df_corr, decreasing=TRUE)
# select the first 16 sorted indexes start by 2, py will be 1st , result is 15
corr_number <- 11
indexes <- indexes[2:corr_number]
# select sorted rows trough indexes, same to row names
df_corr <- data.frame( Correlacion=df_corr[indexes,1] ,row.names = rownames(df_corr)[indexes] )
print('Los países que tienen la mayor correlación en los últimos 15 días, con respecto a Paraguay.')
print(df_corr)

# ---------------------
# Ejercicio g , grafico
# ---------------------

# raw data
df_plot <- data
# move date to another dataframe
df_date <- subset(data, select= date)
# delete first date, cause when performing diff the first row is deleted, drop=FALSE is to maintain dataframe structure
df_date <- df_date[-c(1),,drop=FALSE]
arr <- c('Paraguay', 'Uruguay', 'Argentina', 'Japan', 'Colombia')
# get specific columns
df_plot <- subset(data, select= arr)
# get cases per day, diff funct
df_plot <- data.frame(diff(as.matrix(df_plot)))
#add date column
df_plot$date <- df_date$date
#replace NA with 0
df_plot[is.na(df_plot)] <- 0
#For line graphs, the data points must be grouped so that it knows which points to connect.
# In this case, it is simple -- all points should be connected, so group=1.
date <- paste('Desde el ', head(df_plot$date,1) , 'hasta el' , tail(df_plot$date,1) )
ggplot(data=df_plot)+
  geom_line(mapping=aes(x=date, y=Paraguay, color="Paraguay",group=1),size=1 ) +
  geom_line(mapping=aes(x=date, y=Uruguay, color="Uruguay", group=1)) +
  geom_line(mapping=aes(x=date, y=Argentina, color="Argentina", group=1)) +
  geom_line(mapping=aes(x=date, y=Japan, color="Japon", group=1)) +
  geom_line(mapping=aes(x=date, y=Colombia, color="Colombia", group=1)) +
  scale_color_manual(values = c(
    'Paraguay' = 'red',
    'Uruguay' = 'yellow',
    'Argentina' = 'green2',
    'Japon' = 'blue4',
    'Colombia' = 'orange3'
    )) +
  labs(color = 'Paises', title = 'Grafico de Dispersion', subtitle = date) +
  labs(x = 'fecha', y = 'casos diarios')
