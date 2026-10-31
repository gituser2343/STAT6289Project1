#install.packages('stringr')
library(dplyr)
library(stringr)
library(dataRetrieval)
library(lubridate)
library(stringr)

Sys.setenv(API_USGS_PAT = "bFg9GwqBWQMpppWcCfkFkmcK9npPWnQg8MPLQGwj")
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
  start_edt = ymd_hms(start, tz="America/New_York")
  end_edt = ymd_hms(end, tz="America/New_York")
  start_utc = with_tz(start_edt, tz='UTC') 
  end_utc = with_tz(end_edt, tz='UTC')
  str = paste0(format(start_utc, "%Y-%m-%dT%H:%M:%SZ"), '/',
  format(end_utc, "%Y-%m-%dT%H:%M:%SZ"))
  print(str)
  sensor_data1 = read_waterdata_continuous(monitoring_location_id = stationIDs, 
                                          parameter_code = c('00060','00065','00045'), time =  str)
  if (nrow(sensor_data1)>0){
    sensor_data1$start_utc = start_utc
    sensor_data1$end_utc = end_utc
    sensor_data1$start_edt = start_edt
    sensor_data1$end_edt = end_edt
    sensor_data1$flood_event = folder
  }
  return(sensor_data1)
}

stationIDs = stations = c('USGS-01647600', # Potomac River at Wisconsin Ave, Washington, DC
                          'USGS-01648000', # Rock Creek at Sherrill Drive Washington, DC
                          'USGS-01648010', # Rock Creek at Joyce Rd Washington, DC
                          'USGS-01651760', # Anacostia River at Kenilworth at Washington, DC
                          'USGS-01651770', # Hickey Run at National Arboretum at Washington, DC
                          'USGS-01651800', # Watts Branch at Washington, DC
                          'USGS-01651827'  # Anacostia River near Buzzard Point at Washington, DC
                          )
                          
DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(event=row_number()) 
DCfloodtimes$begin_time[31] = "01:59"
successful_events = c()
sensor_data = NULL
for (i in 1:nrow(DCfloodtimes)) {	
  print(DCfloodtimes[i,])
  sensor_data1 = download_data(startDate = DCfloodtimes$begin_date[i],	
                startTime = DCfloodtimes$begin_time[i],	
                endDate = DCfloodtimes$end_date[i],	
                endTime = DCfloodtimes$end_time[i], folder=paste0('event', DCfloodtimes$event[i]))
  if (nrow(sensor_data1)>0) {
  if (is.null(sensor_data)) {sensor_data = sensor_data1}
  else {sensor_data = rbind(sensor_data, sensor_data1)}
  }
}

#statistic_id is 00011 - instantaneous or point values
sensor_data2 = as.data.frame(sensor_data) %>% mutate(location = case_when(
  monitoring_location_id=='USGS-01647600'~'Potomac River at Wisconsin Ave, Washington, DC',
  monitoring_location_id=='USGS-01648000'~'Rock Creek at Sherrill Drive Washington, DC',
  monitoring_location_id=='USGS-01648010'~'Rock Creek at Joyce Rd Washington, DC',
  monitoring_location_id=='USGS-01651760'~'Anacostia River at Kenilworth at Washington, DC',
  monitoring_location_id=='USGS-01651770'~'Hickey Run at National Arboretum at Washington, DC',
  monitoring_location_id=='USGS-01651800'~'Watts Branch at Washington, DC',
  monitoring_location_id=='USGS-01651827'~'Anacostia River near Buzzard Point at Washington, DC'
  ),
  measure = case_when(parameter_code == '00060' ~ 'Flow rate (cubic ft/s)',
                      parameter_code == '00065' ~ 'Gage Height (ft)')) %>%
  select(-approval_status, -method_category, -time_series_id, -statistic_id, -qualifier)

saveRDS(sensor_data2, "data/RDS/USGS.rds")
