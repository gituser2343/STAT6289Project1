library(rhdf5)
library(stringr)
library(dplyr)
library(lubridate)

if (file.exists("data/DCFloodEvents.h5")) {
  file.remove("data/DCFloodEvents.h5")
}
h5createFile("data/DCFloodEvents.h5")

#flood events
DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(event=row_number()) 
h5write(DCfloodtimes, file = "data/DCFloodEvents.h5", name = 'DCfloodtimes')
h5writeAttribute("The starting date/time and ending date/time for 125 flood events in the District of Columbia between 1996 and 2025.", "data/DCFloodEvents.h5", 'description', 'DCfloodtimes')

get_date_range = function(dates){
  dt =  as.POSIXct(dates, tz='America/New_York')
  dt_range = c(min(dt), max(dt))
  paste(dt_range, collapse=' - ')
}
get_events = function(events){
paste(sort(unique(events)), collapse=', ')
}

add_attributes = function(dates, events, name){
h5writeAttribute(get_date_range(dates), "data/DCFloodEvents.h5", 'Date range', name)
h5writeAttribute(get_events(events), "data/DCFloodEvents.h5", 'Events', name)
}

#raster
h5createGroup("data/DCFloodEvents.h5", "raster")

#MultiSensor_QPE_01H_Pass2
MultiSensor_QPE_01H_Pass2 = readRDS("data/RDS/MultiSensor_QPE_01H_Pass2.rds")
MultiSensor_QPE_01H_Pass2 = MultiSensor_QPE_01H_Pass2 %>% select(x,y,value,eventnum,time_edt) %>%
  mutate(time_edt = format(time_edt, "%Y-%m-%d %H:%M:%S")) %>% rename(latitude=y, longitude=x)
head(MultiSensor_QPE_01H_Pass2)
h5write(MultiSensor_QPE_01H_Pass2, file = "data/DCFloodEvents.h5", name = 'raster/MultiSensor_QPE_01H_Pass2')
h5writeAttribute("NOAA National Severe Storms Laboratory (NSSL) Multi-Radar/Multi-Sensor System (MRMS): Multi-sensor accumulation 1-hour (1-hour latency), mm", "data/DCFloodEvents.h5", 'description', 'raster/MultiSensor_QPE_01H_Pass2')
h5writeAttribute("mm", "data/DCFloodEvents.h5", 'units', 'raster/MultiSensor_QPE_01H_Pass2')
h5writeAttribute("longitude, latitude, value, eventnum, time_edt", "data/DCFloodEvents.h5", 'variables', 'raster/MultiSensor_QPE_01H_Pass2')
add_attributes(MultiSensor_QPE_01H_Pass2$time_edt, MultiSensor_QPE_01H_Pass2$eventnum,
               name = 'raster/MultiSensor_QPE_01H_Pass2')

#PrecipRate
PrecipRate = readRDS("data/RDS/PrecipRate.rds") 
PrecipRate = PrecipRate %>% select(x,y,value,eventnum,time_edt) %>%
  mutate(time_edt = format(time_edt, "%Y-%m-%d %H:%M:%S")) %>% rename(latitude=y, longitude=x)
head(PrecipRate)
h5write(PrecipRate, file = "data/DCFloodEvents.h5", name = 'raster/PrecipRate')
h5writeAttribute("NOAA National Severe Storms Laboratory (NSSL) Multi-Radar/Multi-Sensor System (MRMS): Radar Precipitation Rate, mm/hr", "data/DCFloodEvents.h5", 'description', 'raster/PrecipRate')
h5writeAttribute("mm/hr", "data/DCFloodEvents.h5", 'units', 'raster/PrecipRate')
h5writeAttribute("longitude, latitude, value, eventnum, time_edt", "data/DCFloodEvents.h5", 'variables', 'raster/PrecipRate')
add_attributes(PrecipRate$time_edt, PrecipRate$eventnum, name = 'raster/PrecipRate')

#Time-series
h5createGroup("data/DCFloodEvents.h5", "time-series")
USGS = readRDS("data/RDS/USGS.rds")
USGS = USGS %>% mutate(time_edt = with_tz(time, tz="America/New_York"), eventnum = as.numeric(str_sub(flood_event, 6))) %>%
  mutate(time_edt = format(time_edt, "%Y-%m-%d %H:%M:%S"))

#Flow rate
FlowRate = subset(USGS, measure=='Flow rate (cubic ft/s)') %>%
  select(monitoring_location_id, time_edt, value, eventnum,location) 
head(FlowRate)
h5write(FlowRate, file = "data/DCFloodEvents.h5", name = 'time-series/FlowRate')
h5writeAttribute("U.S. Geological Survey (USGS) Water Data - Discharge, cubic feet per second", "data/DCFloodEvents.h5", 'description', 'time-series/FlowRate')
h5writeAttribute("cubic feet per second", "data/DCFloodEvents.h5", 'units', 'time-series/FlowRate')
h5writeAttribute("monitoring_location_id, time_edt, value, eventnum, location", "data/DCFloodEvents.h5", 'variables', 'time-series/FlowRate')
h5writeAttribute("USGS-01648000, USGS-01651800, USGS-01648010, USGS-01651770, USGS-01651827, USGS-01651760", "data/DCFloodEvents.h5", 'stations', 'time-series/FlowRate')
add_attributes(FlowRate$time_edt, FlowRate$eventnum, name = 'time-series/FlowRate')

#Gage Height
GageHeight = subset(USGS, measure=='Gage Height (ft)') %>%
  select(monitoring_location_id, time_edt, value, eventnum,location) 
head(GageHeight)
h5write(GageHeight, file = "data/DCFloodEvents.h5", name = 'time-series/GageHeight')
h5writeAttribute("U.S. Geological Survey (USGS) Water Data - Gage height, feet", "data/DCFloodEvents.h5", 'description', 'time-series/GageHeight')
h5writeAttribute("ft", "data/DCFloodEvents.h5", 'units', 'time-series/GageHeight')
h5writeAttribute("monitoring_location_id, time_edt, value, eventnum, location", "data/DCFloodEvents.h5", 'variables', 'time-series/GageHeight')
h5writeAttribute("USGS-01648000, USGS-01651800, USGS-01647600, USGS-01648010, USGS-01651770, USGS-01651827, USGS-01651760", "data/DCFloodEvents.h5", 'stations', 'time-series/GageHeight')
add_attributes(GageHeight$time_edt, GageHeight$eventnum, name = 'time-series/GageHeight')

#CoCoRaHS (Community Collaborative Rain, Hail, and Snow Network) daily precipitation reports.
cocorahs = readRDS("data/RDS/cocorahs.rds") %>% select(-url) %>% mutate(value=TotalPrecipAmt, 
dt=paste0( ObservationDate, ObservationTime), time_edt=format(as.POSIXct(dt, format = "%Y-%m-%d %I:%M %p", 
  tz = "America/New_York"), "%Y-%m-%d %H:%M:%S")) %>% select(time_edt, eventnum, Longitude, Latitude, value, StationNumber)
head(cocorahs, 1)
h5write(cocorahs, file = "data/DCFloodEvents.h5", name = 'time-series/cocorahs')
h5writeAttribute("CoCoRaHS (Community Collaborative Rain, Hail, and Snow Network) daily precipitation reports.", 
                 "data/DCFloodEvents.h5", 'description', 'time-series/cocorahs')
h5writeAttribute("time_edt, eventnum, Longitude, Latitude, value, StationNumber", "data/DCFloodEvents.h5", 'variables', 
                 'time-series/cocorahs')
add_attributes(cocorahs$time_edt, cocorahs$eventnum,
               name = 'time-series/cocorahs')



h5readAttributes("data/DCFloodEvents.h5", "DCfloodtimes")
h5readAttributes("data/DCFloodEvents.h5", "raster/MultiSensor_QPE_01H_Pass2")
h5readAttributes("data/DCFloodEvents.h5", "raster/PrecipRate")
h5readAttributes("data/DCFloodEvents.h5", "time-series/FlowRate")
h5readAttributes("data/DCFloodEvents.h5", "time-series/GageHeight")
h5readAttributes("data/DCFloodEvents.h5", "time-series/cocorahs")


