# Gesti�n de marcos de datos con dplyr - Herramientas b�sicas
library(dplyr)

# 1. La funci�n select() ------------------------------------------------------

# esta es una base de datos sobre poluci�n y clima de los a�os 1987 hasta 2005,
# los datos fueron recolectados a diario.

## Lectura
chicago <- readRDS("./data/chicago.rds")
dim(chicago)
str(chicago)
names(chicago)

# Una de las cosas que se puede hacer con la funci�n select() es seleccionar
# columnas de un dataframe a partir de sus nombres y no de sus �ndices.

## Selecci�n de las primeras 3 columnas de la base de datos
head(select(chicago, city:dptp))

# En resumen, select() puede ser usado para tomar subconjuntos de una base de 
# datos teniendo como referencia simplemente los normbes de las columnas

## Selecci�n de todas las columnas excepto las 3 primeras
head(select(chicago, -(city:dptp)))

## El c�digo equivalente con el paquete base de R ser�a 
i <- match("city", names(chicago))
j <- match("dptp", names(chicago))
head(chicago[, -(i:j)])

# 2. La funci�n filter() --------------------------------------------------------

# La funci�n filter() se usa b�sicamente para tomar subconjuntos de filas de una
# base de datos a partir de condiciones l�gicas

## selecci�n de las filas del data frame chicago para las cuales la variable
## pm25mean2 tiene un valor mayor a 30
chic.f <- filter(chicago, pm25tmean2 > 30)

## Uso de la funci�n select() para mostrar solo las primeras 3 columnas del
## subconjunto de datos sacado anteriormente
head(select(chic.f, 1:3, pm25tmean2), 10)

# Se pueden usar condiciones l�gicas complicadas para la extracci�n de filas
# que cumplan condiciones espec�ficas.
# 3. La funci�n arrange() -------------------------------------------------------

# La funci�n arrange() basicamente se usa para reordenar las filas de un dataframe
# a partir de los valores de una columna. Reordenar las filas de un marco de datos
# (mientras se conserva el orden correspondiente de otras columnas) es normalmente
# una molestia en R.

## Ordenamiento del dataframe chicago de acuerdo a la variable date
chicago <- arrange(chicago, date)
head(select(chicago, date, pm25tmean2), 3)
tail(select(chicago, date, pm25tmean2), 3)

# Se puede usar tambi�n las funci�n desc para ordenar de manera descendente.

## Ordenamiento del dataframe chicago de acuerdo a la variable date de manera
## descendente.
chicago <- arrange(chicago, desc(date))
head(select(chicago, date, pm25tmean2), 3)
tail(select(chicago, date, pm25tmean2), 3)

# 4. La funci�n rename() --------------------------------------------------------

# Renombrar variables en R es sorprendentemente d�ficil de hacer.

chicago <- readRDS("./data/chicago.rds")
head(chicago)

## Renombramiento de las columnas  dptp y pm25mean2 como dewpoint y pm25,
## respectivamente.
chicago <- rename(chicago, dewpoint = dptp, pm25 = pm25tmean2)

head(chicago)

# 5. La funci�n mutate() --------------------------------------------------------

# La funci�n mutate() es usada para transformar variables existentes o crear 
# nuevas variables

## Creaci�n de la variable pm25detrend, que es el valor promedio de la variable
## pm25
chicago <- mutate(chicago, pm25detrend = mean(pm25, na.rm=TRUE))
head(chicago)

# 6. La funci�n group_by() ------------------------------------------------------

# La funci�n group_by() b�sicamente permite dividir bases de datos de acuerdo a
# ciertas variables categ�ricas.

## Creaci�n de la variable tempcat que divide los datos en hot o cold de 
## acuerdo a la temperatura registrada ese d�a (tmpd).
chicago <- mutate(chicago, tempcat = factor(1 * (tmpd > 80), labels = c("cold", "hot")))

## Creaci�n de un nuevo data frame con la agrupaci�n de los datos seg�n la 
## variable tempcat
hotcold <- group_by(chicago, tempcat)
head(hotcold)

# 7. La funci�n summarize() ---------------------------------------------------

# La funci�n summarize() genera estad�sticos de resumen de diferentes variables
# en un data frame, posiblemente sin estratos.


summarize(hotcold, pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2),
          no2 = median(no2tmean2))

# Tambi�n podr�a clasificar el conjunto de datos en otras variables, por 
# ejemplo, si se quisiera hacer un resumen de cada a�o en el conjunto de datos,
# podr�amos hacer lo siguiente:

## Creaci�n de la variable year en el data frame
chicago <- mutate(chicago, year = as.POSIXlt(date)$year + 1900)

## Creaci�n del data frame years a partir de la agrupaci�n de la variable years
years <- group_by(chicago, year)

## Creaci�n del marco de datos con el resumen de cada a�o
summarize(years, pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2),
           no2 = median(no2tmean2))

# 8. El operador de tuber�a %>% ------------------------------------------------------------

# El operador %>% es implementado por el paquete dplyr y permite encadenar 
# distintas operaciones juntas, de forma que se pueda leer m�s f�cilmente las
# operaciones que se est�n realizando.

## El siguiente comando, usa la funci�n mutate para crear la varaible month,
## luego se hace agrupaci�n a partir de esta variable con la funci�n group_by
## y por �ltimo, se generan estad�sticos de resumen para algunas variables
## a partir de los grupos hechos con anterioridad.
chicago %>% mutate(month = as.POSIXlt(date)$mon + 1) %>% group_by(month) %>% 
        summarize(pm25 = mean(pm25, na.rm = TRUE), 
                  o3 = max(o3tmean2, na.rm = TRUE), 
                  no2 = median(no2tmean2, na.rm = TRUE))

# Es bueno notar que al usar el operador de tuber�a, solo se necesita 
# especificar el data frame con el que se trabaja al inicio del c�digo.

# El operador de tuber�a es una herramienta muy �til ya que previene la 
# asignaci�n de variables temporales que luego son necesitadas por otras 
# funciones.

