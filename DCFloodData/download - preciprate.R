library(rvest)
library(dplyr)
library(lubridate)
library(stringr)
library(terra)
library(R.utils)

setwd("C:\\Users\\vxb18\\OneDrive\\Desktop\\STAT 6289\\Project 1\\DCFloodData2")

download_data = function(startDate, startTime, endDate, endTime, folder) {
  startMinutes = as.numeric(str_sub(startTime, 4,5))
  if (!(startMinutes %% 2==0)) {
    startMinutes = startMinutes - 1
    if (startMinutes<=9) {startTime = paste0(str_sub(startTime, 1, 3), '0', startMinutes)}
    else {startTime = paste0(str_sub(startTime, 1, 3), startMinutes)}
  }
  endMinutes = as.numeric(str_sub(endTime, 4,5))
  if (!(endMinutes %% 2==0)) {
    endMinutes = endMinutes - 1
    if (endMinutes<=9) {endTime = paste0(str_sub(endTime, 1, 3), '0', endMinutes)}
    else {endTime = paste0(str_sub(endTime, 1, 3), endMinutes)}
  }
  start = paste0(as.Date(startDate), 'T', startTime, ':00')
  end = paste0(as.Date(endDate), 'T', endTime, ':00')
  start_utc = with_tz(ymd_hms(start, tz="America/New_York"), tz='UTC') 
  end_utc = with_tz(ymd_hms(end, tz="America/New_York"), tz='UTC') 
  dt = start_utc
  folder = paste0('data/',folder)
  dir.create(folder)
  print(paste(start,end))
  print(paste(start_utc,end_utc))
  while (dt<=end_utc) {
    fname = paste0('PrecipRate_00.00_', format(dt, '%Y%m%d-%H%M%S'), '.grib2.gz')
    fname2 = str_sub(fname, 1, str_length(fname)-3)
    url = paste0("https://mtarchive.geol.iastate.edu/", format(dt, '%Y/%m/%d'), '/mrms/ncep/PrecipRate/', fname)
    print(paste('...downloading ', fname))
    tryCatch({
    download.file(url, destfile = paste0(folder,'/', fname), mode = "wb")
    gunzip(paste0(folder, '/', fname), destname = paste0(folder, '/', fname2), overwrite = TRUE, remove = FALSE)
    }, error = function(e) {message("Error: ", e$message)})
    dt = dt + minutes(2)
  }
}
DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(event=row_number(), year = year(as.Date(begin_date))) %>%
  subset(year>=2015)
head(DCfloodtimes)
for (i in 1:nrow(DCfloodtimes)) {	
download_data(startDate = DCfloodtimes$begin_date[i],	
              startTime = DCfloodtimes$begin_time[i],	
              endDate = DCfloodtimes$end_date[i],	
              endTime = DCfloodtimes$end_time[i], folder=paste0('event', DCfloodtimes$event[i]))
}



