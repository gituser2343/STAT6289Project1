library(rvest)
library(dplyr)
library(lubridate)
library(stringr)
library(terra)
library(R.utils)

download_data = function(startDate, startTime, endDate, endTime, eventnum) {
  endDate2 = as.Date(endDate)+1
  startTime = paste0(str_sub(startTime, 1, 3), '00')
  endTime = paste0(str_sub(endTime, 1, 3), '00')
  start = paste0(as.Date(startDate), 'T', startTime, ':00')
  end = paste0(as.Date(endDate), 'T', endTime, ':00')
  start_utc = with_tz(ymd_hms(start, tz="America/New_York"), tz='UTC') 
  end_utc = with_tz(ymd_hms(end, tz="America/New_York"), tz='UTC') 
  
  url = paste0("https://data.cocorahs.org/cocorahs/export/exportreports.aspx?ReportType=Daily&state=DC&startDate=", 
               startDate, "&endDate=", endDate2, "&Format=CSV")
  df1 <- read.csv(url, stringsAsFactors = FALSE)
  if (nrow(df1)>0){
  df1$eventnum = eventnum
  df1$url = url
  }
  else {
    print("0 rows")
  }
  print(url)
  df1
}

DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(event=row_number()) 
df = NULL
for (i in 1:nrow(DCfloodtimes)) {	
df1 = NULL
try({df1 = download_data(startDate = DCfloodtimes$begin_date[i],	
              startTime = DCfloodtimes$begin_time[i],	
              endDate = DCfloodtimes$end_date[i],	
              endTime = DCfloodtimes$end_time[i], eventnum=DCfloodtimes$event[i])
})
if (is.null(df1)) {next}
if (is.null(df)) {df = df1}
else {df = rbind(df, df1)}
}

head(df)
df$eventnum
saveRDS(df, 'data/RDS/cocorahs.rds')

