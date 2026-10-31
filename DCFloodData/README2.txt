Description of files and folders

DC_flood_times.csv                                
File with events
                   
Programs to download data and create an rds file in data folder.  Each type can be run independently but if there are two programs first run download then process.   
1. download - multisensor.R 
process grib files - MultiSensor_QPE_01H_Pass2.R

2. download - preciprate.R                          
process grib files - PrecipRate.R

3. USGS.r  
  
4. download - cocorahs.R                                         
       
Program to create hdf5 database from rds files
create_hdf5_database.R             

Program to generate plots from hdf5 file
plots.R

data    
This is where files will be downloaded to and other files written to
                                          
plots
Visualizations



Contents of data/DCFloodEvents.h5
$`raster/MultiSensor_QPE_01H_Pass2`
$`raster/MultiSensor_QPE_01H_Pass2`$`Date range`
[1] "2020-11-12 04:00:00 - 2025-07-19 18:00:00"

$`raster/MultiSensor_QPE_01H_Pass2`$Events
[1] "99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125"

$`raster/MultiSensor_QPE_01H_Pass2`$description
[1] "NOAA National Severe Storms Laboratory (NSSL) Multi-Radar/Multi-Sensor System (MRMS): Multi-sensor accumulation 1-hour (1-hour latency), mm"

$`raster/MultiSensor_QPE_01H_Pass2`$units
[1] "mm"

$`raster/MultiSensor_QPE_01H_Pass2`$variables
[1] "longitude, latitude, value, eventnum, time_edt"


$`raster/PrecipRate`
$`raster/PrecipRate`$`Date range`
[1] "2015-06-27 15:24:00 - 2025-07-19 18:34:00"

$`raster/PrecipRate`$Events
[1] "67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125"

$`raster/PrecipRate`$description
[1] "NOAA National Severe Storms Laboratory (NSSL) Multi-Radar/Multi-Sensor System (MRMS): Radar Precipitation Rate, mm/hr"

$`raster/PrecipRate`$units
[1] "mm/hr"

$`raster/PrecipRate`$variables
[1] "longitude, latitude, value, eventnum, time_edt"


$`time-series/FlowRate`
$`time-series/FlowRate`$`Date range`
[1] "1996-01-19 11:00:00 - 2025-07-19 18:34:00"

$`time-series/FlowRate`$Events
[1] "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125"

$`time-series/FlowRate`$description
[1] "U.S. Geological Survey (USGS) Water Data - Discharge, cubic feet per second"

$`time-series/FlowRate`$stations
[1] "USGS-01648000, USGS-01651800, USGS-01648010, USGS-01651770, USGS-01651827, USGS-01651760"

$`time-series/FlowRate`$units
[1] "cubic feet per second"

$`time-series/FlowRate`$variables
[1] "monitoring_location_id, time_edt, value, eventnum, location"


$`time-series/GageHeight`
$`time-series/GageHeight`$`Date range`
[1] "2008-05-12 - 2025-07-19 18:34:00"

$`time-series/GageHeight`$Events
[1] "39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125"

$`time-series/GageHeight`$description
[1] "U.S. Geological Survey (USGS) Water Data - Gage height, feet"

$`time-series/GageHeight`$stations
[1] "USGS-01648000, USGS-01651800, USGS-01647600, USGS-01648010, USGS-01651770, USGS-01651827, USGS-01651760"

$`time-series/GageHeight`$units
[1] "ft"

$`time-series/GageHeight`$variables
[1] "monitoring_location_id, time_edt, value, eventnum, location"


$`time-series/cocorahs`
$`time-series/cocorahs`$`Date range`
[1] "2006-06-25 07:00:00 - 2025-07-20 08:00:00"

$`time-series/cocorahs`$Events
[1] "35, 36, 37, 38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125"

$`time-series/cocorahs`$description
[1] "CoCoRaHS (Community Collaborative Rain, Hail, and Snow Network) daily precipitation reports."

$`time-series/cocorahs`$variables
[1] "time_edt, eventnum, Longitude, Latitude, value, StationNumber"


