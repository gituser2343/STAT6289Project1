library(terra)
library(ggplot2)
library(rhdf5)
library(dplyr)
library(ggplot2)
library(tidyr)

#List the available events, sources, variables, stations, date ranges, and relevant metadata
get_info = function(){
  l = list()
sources = c("raster/MultiSensor_QPE_01H_Pass2", "raster/PrecipRate", "time-series/FlowRate", "time-series/GageHeight",
            'time-series/cocorahs')
for (source in sources){
l[[source]] = h5readAttributes("data/DCFloodEvents.h5", source)}
l
}
get_info()

#Retrieve a raster by event, source, and observation date/time, returning its spatial coordinates and units.
retrieve_raster = function(source, target_datetime, target_event=NA){
df = h5read("data/DCFloodEvents.h5", paste0('raster/', source))
target_datetime = as.POSIXct(target_datetime, tz = "America/New_York")
df1 = subset(df, (is.na(target_event) | eventnum==target_event) & time_edt==format(target_datetime, "%Y-%m-%d %H:%M:%S")) %>%
  select(longitude, latitude, value)
df1
}
retrieve_raster('PrecipRate', as.POSIXct('2020-12-25 02:20:00', tz = "America/New_York"))

#Visualize a stored precipitation raster with geographic context, legend, and informative title
visualize_raster = function(source, product, target_datetime) {
  rast = retrieve_raster(paste0(source), as.POSIXct('2020-12-25 02:20:00', tz = "America/New_York"))
  ggplot(rast, aes(x = longitude, y = latitude, fill = value)) +
  geom_raster() +
  scale_fill_viridis_c() +
  coord_quickmap() +
  theme_minimal() +
  labs(fill = product, title = paste0(product, ' in DC on ', format(target_datetime, '%B %e, %Y %I:%M:%S %p')))
}
visualize_raster('PrecipRate', 'Radar Precipitation Rate (mm/hr)', as.POSIXct('2020-12-25 02:20:00', tz = "America/New_York"))
ggsave('plots/raster-example.png')

#Retrieve a stored station or gauge time series for a selected event and time window.
retrieve_time_series = function(source, target_event, time_window, stationID=NULL){
time_window = as.POSIXct(time_window, tz = "America/New_York")
df = h5read("data/DCFloodEvents.h5", paste0('time-series/', source))
df1 = df %>% mutate(time_edt = as.POSIXct(time_edt, tz = "America/New_York"))
if (is.null(stationID)) {df1 = subset(df1, eventnum==target_event & 
               time_edt>=time_window[1] & time_edt<=time_window[2])}
else {
df1 = subset(df1, monitoring_location_id==stationID & eventnum==target_event & 
               time_edt>=time_window[1] & time_edt<=time_window[2])
}
df1
}
retrieve_time_series('FlowRate', 100, c('2020-12-25 03:46:00','2020-12-25 03:51:00'), stationID='USGS-01651770')
retrieve_time_series('FlowRate', 100, c('2020-12-25 03:46:00','2020-12-25 03:51:00'))

#Plot a stored time series with appropriate time-zone labels, units, and missing-data indications.
visualize_time_series = function(source, target_event, time_window, measure, title){
  df1 = retrieve_time_series(source, target_event, time_window)
  min = as.POSIXct(min(df$time_edt), tz = "America/New_York")
  max = as.POSIXct(max(df$time_edt), tz = "America/New_York")
  title = paste(title, format(min, '%B %e, %Y %I:%M:%S %p'), 'to', 
  format(max, '%B %e, %Y %I:%M:%S %p'))
ggplot(df1, aes(x = time_edt, y = value, color = location, group = location)) +
  geom_line() +
  geom_point() +
  theme_minimal() +
  labs(x = "Time (NYC)", y = measure, color = "Location", title=title)
}
visualize_time_series('FlowRate', 100, c('2010-12-25 03:46:00','2029-12-25 03:51:00'), 
                      title='USGS Water Data', measure = 'Discharge, cubic feet per second')
  
ggsave('plots/ts-example.png')

#Produce a compact summary of data coverage and missingness by source and event
data_coverage = function(name){
df = h5read("data/DCFloodEvents.h5", name)
out = df %>% mutate(miss=ifelse(is.na(value), 1, 0)) %>% group_by(eventnum) %>% summarize(n=n(), nmiss=sum(miss))
DCfloodtimes = read.csv("DC_flood_times.csv") %>% mutate(eventnum=row_number()) 
DCfloodtimes = merge(DCfloodtimes, out, by='eventnum', all=T) %>% mutate(n=ifelse(is.na(n),0,n), 
        nmiss=ifelse(is.na(nmiss),0,nmiss), navail = n-nmiss) 
title2=paste(sum(DCfloodtimes$nmiss), 'missing out of', sum(DCfloodtimes$n), 'and',
             nrow(subset(DCfloodtimes, n>0)), 'events covered out of 125')
df_long <- DCfloodtimes %>% rename(`Available`=navail, `Missing`=nmiss) %>%
  pivot_longer(
    cols = c(`Available`, `Missing`),      
    names_to = "status",        
    values_to = "count")
plot = ggplot(df_long, aes(x = eventnum, y = count, fill = status)) +
  geom_col(position = "stack") +  
  labs(
    title = paste0('Coverage and missingness for ', name),
    x = "Event",
    y = "Count",
    fill = "Status",
    caption=title2
  ) +
  theme_minimal()
list(DCfloodtimes, plot)
}


data_coverage("raster/MultiSensor_QPE_01H_Pass2")
ggsave("plots/MultiSensor_QPE_01H_Pass2.png")
data_coverage("raster/PrecipRate")
ggsave("plots/PrecipRate.png")
data_coverage("time-series/FlowRate")
ggsave("plots/FlowRate.png")
data_coverage("time-series/GageHeight")
ggsave("plots/GageHeight.png")
data_coverage("time-series/cocorahs")
ggsave("plots/cocorahs.png")

