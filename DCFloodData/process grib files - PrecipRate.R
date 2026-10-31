
library(rvest)
library(dplyr)
library(lubridate)
library(stringr)
library(terra)
library(R.utils)

setwd("C:\\Users\\vxb18\\OneDrive\\Desktop\\STAT 6289\\Project 1\\DCFloodData2")

DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(eventnum=row_number()) 
gribInfo = function(path){
  path_list = str_split(path, "/")[[1]]
  product = path_list[2]
  eventnum1 = as.numeric(str_sub(path_list[3], 6))
  event = DCfloodtimes[DCfloodtimes$eventnum==eventnum1,]
  dates = convert_dates(event)
  time = str_sub(path_list[4], str_length(product)+8)
  time = str_split(str_sub(time, 1, str_length(time)-6), '-')[[1]]
  time = paste0(as.Date(time[1], format='%Y%m%d'), 'T', str_sub(time[2], 1, 2), ':', 
                str_sub(time[2], 3, 4), ':', str_sub(time[2], 5, 6))
  time_utc = ymd_hms(time, tz="UTC")
  time_edt =  with_tz(time_utc, tz="America/New_York") 
  list('product'=product, 'eventnum'=eventnum1, 'time_edt'=time_edt, 'time_utc'=time_utc, filename=path_list[4],
       'event_start_edt'= dates$start_edt, 'event_end_edt'= dates$end_edt, 'event_start_utc' = dates$start_utc,
       'event_end_utc'=dates$end_utc)
}
process_grib_file = function(grib_file_path){
  print(paste0('...processing ', grib_file_path))
  print(Sys.time())
  df = as.data.frame(rast(grib_file_path), xy = TRUE)
  names(df)[3] = 'value'
  df = subset(df, abs(y-36)<=0.1 & abs(x-(-77))<=0.1)
  info = gribInfo(grib_file_path)
  rownames(df) = NULL
  df$product= info$product
  df$eventnum = info$eventnum
  df$time_edt = info$time_edt
  df$time_utc = info$time_utc
  df$filename = info$filename
  df$event_start_edt = info$event_start_edt
  df$event_end_edt = info$event_end_edt
  df$event_start_utc = info$event_start_utc
  df$event_end_utc = info$event_end_utc
  df
}
convert_dates = function(df){
start = paste0(as.Date(df$begin_date), 'T', df$begin_time, ':00')
end = paste0(as.Date(df$end_date), 'T', df$end_time, ':00')
start_edt = ymd_hms(start, tz="America/New_York")
end_edt = ymd_hms(end, tz="America/New_York")
start_utc = with_tz(start_edt, tz='UTC') 
end_utc = with_tz(end_edt, tz='UTC')
list('start_edt'=start_edt, 'end_edt'=end_edt, 'start_utc' = start_utc,
     'end_utc'=end_utc)
}

process_files = function(product){
events = list.files(paste0('data/', product))
processed_events = str_sub(str_sub(list.files(paste0('data/RDS/', product)), str_length(product)+2), 1, -5)
events = events[!(events %in% processed_events)]
print(events)
for (i in 1:length(events)) {
files = list.files(paste0('data/', product, '/', events[i]))
df = NULL
for (j in 1:length(files)) {
path = paste0('data/', product, '/', events[i], '/', files[j])
if (str_sub(files[j], length(files[j])-3)!='gz') {
tryCatch({
df1 = process_grib_file(path)
if (is.null(df)) {df = df1}
else {df = rbind(df, df1)}
}, error = function(e) {print(paste('Error message:', e$message))})
}
}
saveRDS(df, paste0('data/RDS/', product, '/', product, '_', events[i], '.rds'))
}
}

PrecipRate = process_files('PrecipRate')

df = NULL
for (file in list.files('data/RDS/PrecipRate')) {
  df1 = readRDS(paste0('data/RDS/PrecipRate/', file))
  if (is.null(df1)) {
    print(paste0('null file: ', file))
    next}
  if (is.null(df)) {df = df1}
  else {df = rbind(df, df1)}
}
head(df)
saveRDS(df, 'data/RDS/PrecipRate.rds')