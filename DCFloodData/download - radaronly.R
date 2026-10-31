library(rvest)
library(dplyr)
library(lubridate)
library(stringr)
library(terra)
library(R.utils)

download_data = function(startDate, startTime, endDate, endTime, folder) {
  startTime = paste0(str_sub(startTime, 1, 3), '00')
  endTime = paste0(str_sub(endTime, 1, 3), '00')
  start = paste0(as.Date(startDate), 'T', startTime, ':00')
  end = paste0(as.Date(endDate), 'T', endTime, ':00')
  start_utc = with_tz(ymd_hms(start, tz="America/New_York"), tz='UTC') 
  end_utc = with_tz(ymd_hms(end, tz="America/New_York"), tz='UTC') 
  dt = start_utc
  folder = paste0('data/RadarOnly_QPE_01H/',folder)
  dir.create(folder)
  print(paste(start,end))
  print(paste(start_utc,end_utc))
  while (dt<=end_utc) {
    fname = paste0('RadarOnly_QPE_01H_00.00_', format(dt, '%Y%m%d-%H%M%S'), '.grib2.gz')
    fname2 = str_sub(fname, 1, str_length(fname)-3)
    url = paste0("https://mtarchive.geol.iastate.edu/", format(dt, '%Y/%m/%d'), '/mrms/ncep/RadarOnly_QPE_01H/', fname)
    print(paste('...downloading ', fname))
    tryCatch({
    download.file(url, destfile = paste0(folder,'/', fname), mode = "wb")
    gunzip(paste0(folder, '/', fname), destname = paste0(folder, '/', fname2), overwrite = TRUE, remove = FALSE)
    }, error = function(e) {message("Error: ", e$message)})
    dt = dt + minutes(60)
  }
}
DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(event=row_number(), year = year(as.Date(begin_date))) %>%
  subset(as.Date(begin_date)>=as.Date('2014-01-01'))

head(DCfloodtimes)
for (i in 1:nrow(DCfloodtimes)) {	
download_data(startDate = DCfloodtimes$begin_date[i],	
              startTime = DCfloodtimes$begin_time[i],	
              endDate = DCfloodtimes$end_date[i],	
              endTime = DCfloodtimes$end_time[i], folder=paste0('event', DCfloodtimes$event[i]))
}




