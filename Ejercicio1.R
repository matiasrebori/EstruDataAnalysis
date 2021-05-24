library(doBy)
library(ggplot2)
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
#extract py value
py_value <- df_total_cases['Paraguay',1]
py <- data.frame( Casos=py_value, row.names='Paraguay' )


    ##### 4 smallest countries + py ######

# get 4 samllest
df_smallest_cases <- df_total_cases[which.minn(df_total_cases,4),]
# insert in a dataframe structure
df_smallest_cases <- data.frame( Casos=df_smallest_cases )
#append py
df_smallest_cases <- rbind(df_smallest_cases,py)
print('Los 4 países con menores valores de total de casos positivos. + Py')
print(df_smallest_cases)



    ##### 4 largest countries + py ######


# get 4 largest
df_higher_cases <- df_total_cases[which.maxn(df_total_cases,4),]
# insert in a dataframe structure
df_higher_cases <- data.frame( Casos=df_higher_cases )
#append py
df_higher_cases <- rbind(df_higher_cases,py)
print('Los 4 países con mayores valores de total de casos positivos. + Py')
print(df_higher_cases)


    ##### cases per million section ######

# read csv
locations <- read.csv("locations.csv")
#deal with caracters in csv, so names are the same in the two dataframes
locations$location <- gsub(' ', '.', locations$location)
locations$location <- gsub('\'', '.', locations$location)
locations$location <- gsub('-', '.', locations$location)
locations$location <- gsub('[()]', '.', locations$location)
# merge, common data is country names so rownames in df_total_cases is same as location column in locations,
df_merge <- merge(x=df_total_cases, y=locations, by.x="row.names", by.y="location")
# new df with cases per million rounded, every country total cases from last late and his population
df_cases_per_million <- data.frame( row.names=rownames(df_total_cases), Casos= round (df_merge$Pais*1000000/df_merge$population) )
#extract py value
py_value_per_million <- df_cases_per_million['Paraguay',1]
py_per_million <- data.frame( Casos=py_value_per_million, row.names='Paraguay' )



    ##### 4 largest cases per million + py ######

# get nlargest indexes
sorted <- which.maxn(df_cases_per_million[,'Casos'],4)
# make dataframe
df_cases <- data.frame( Casos=df_cases_per_million[sorted,1] ,row.names = rownames(df_cases_per_million)[sorted] )
# append py
df_cases <- rbind(df_cases,py_per_million)
print('los 4 países con mayores casos positivos por millón de habitantes. + Py')
print(df_cases)



    ##### 4 smallest cases per million + py ######


sorted <- which.minn(df_cases_per_million[,'Casos'],4)
df_cases <- data.frame( Casos=df_cases_per_million[sorted,1] ,row.names = rownames(df_cases_per_million)[sorted] )
df_cases <- rbind(df_cases,py_per_million)
print('los 4 países con menores casos positivos por millón de habitantes. + Py')
print(df_cases)



    ##### Ejercicio e , last 10 days average all countries ######


df_average <- subset(data, select= -date)
df_average <- tail(df_average, n=11)
#apply diff function(to get cases per day) to all columns , margin = 1 is loop over rows, na.rm is to not count null
df_average <- apply(df_average,2,diff,na.rm=TRUE)
# mean and round
df_average <- apply(df_average,2,mean,na.rm=TRUE)
df_average <- sapply(df_average, round)
# make it dataframe structure
df_average <- data.frame( df_average )
# rename column name
colnames(df_average) <- 'Promedio diario de casos'
print('Promedio diario de casos positivos de los últimos 10 días de todos los países.')
print(head(df_average))



    ##### Ejercicio f , correlation cases per day ######



# last 15 rows cases per day
df_for_corr <- subset(data, select= -date)
df_for_corr <- tail(df_for_corr, n=16)
# get cases per day
df_for_corr <- data.frame(diff(as.matrix(df_for_corr)))
# define new dataframe with colnames loaded
df_corr <- data.frame(matrix(ncol = ncol(df_for_corr), nrow = 1))
colnames(df_corr) <- colnames(df_for_corr)
# correlation function per each column, default method is pearson, complete.obs to not computate null values
for (i in colnames(df_for_corr)){
    # temp is matrix[1,1]
    temp <- cor(df_for_corr[i],df_for_corr$Paraguay, use='complete.obs')
    df_corr[i] <- temp[1]
}
df_corr <- t(df_corr)
# colnames(df_corr) <- 'Correlacion con respecto a paraguay'
#order with ascending order, order returns indexes sorted , dataframe is not sorted
indexes <- order(df_corr, decreasing=TRUE)
# select the first 11 sorted indexes, cause paraguay will be 1st
indexes <- indexes[1:11]
# select sorted rows trough indexes, same to row names
df_corr <- data.frame( Correlacion=df_corr[indexes,1] ,row.names = rownames(df_corr)[indexes] )
print('Los países que tienen la mayor correlación en los últimos 15 días, con respecto a Paraguay.')
print(tail(df_corr,10))



    ##### Ejercicio g , grafico ######

print('Grafico')
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