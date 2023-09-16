#I am trying Crop instead of setExtent (doesn't work during extract) or resample (which may distort).  Resample will distort a little bit.
setwd("/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI")
outpath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"
temppath <- "/Users/elisehellwig/Desktop/Temp"

library(terra)
library(geodata)

innames <- c('Elevation', 'Slope', 'TRI', 'NDVIcv', 'NDVIMax', 'Precip0609', 'Precip1005',
            'Tmin01', 'Tmax07', 'Snow', 'Aspen', 'Conifer', 'Meadow', 'Mixed',
            'Rock', 'Shrub0')

rnames <- c('Elevation', 'Slope', 'TRI', 'NDVIcv', 'NDVIMax', 'Precip0609', 'Precip1005',
            'Tmin01', 'Tmax07', 'Snow', 'Conifer', 'Meadow', 'Rock', 'Shrub')

#all files have 30m x 30m resolution but different extents
rast_files <- c("SNV/Topography/Elevation30SNV.tif", #elevation
                "SNV/Topography/Slope30SNV.tif", #slope
                "SNV/Topography/TRI30SNV.tif", #ruggedness
                "SNV/NDVI/NDVICVMeanMax1989_2015SNV.tif", #NDVI coef of var
                "SNV/NDVI/NDVICVMeanMax1989_2015SNV.tif", #Max NDVI
                "SNV/Climate/Precip/precip0609SNV.tif", #growing season precip
                "SNV/Climate/Precip/precip1005SNV.tif", #non growing season precip
                "SNV/Climate/Tmin/Tmin07SNV.tif", #min temp in January
                "SNV/Climate/Tmax/Tmax07SNV.tif", #max temp in July
                "SNV/Climate/Snow/SnowFreeDaysSNV.tif", # days w/o snow on ground
                "SNV/Vegetation/Rasterveg/aspen30m.img", #areas of Aspen land cover
                "SNV/Vegetation/Rasterveg/conifer30m.img", #areas of conifer land cover
                "SNV/Vegetation/Rasterveg/meadow30m.img", #areas of meadow land cover
                "SNV/Vegetation/Rasterveg/mixed30m.img", #areas of mixed type land cover
                "SNV/Vegetation/Rasterveg/rock30m.img", # areas of bare rock
                "SNV/Vegetation/Rasterveg/shrub30m.img") #areas of shrubland

rlist <- lapply(rast_files, rast)

tmin_wc <- worldclim_tile('tmin', lon=-118, lat=36.5, path=temppath)$tile_15_wc2.1_30s_tmin_1 

rlist[[8]] <- tmin_wc$tile_15_wc2.1_30s_tmin_1+273.15

rlist_utm11 <- lapply(rlist, function(r) project(r, crs("epsg:26911")) )


rlist_identical <- lapply(rlist_utm11, resample, rlist_utm11[[1]])

r0 <- rast(rlist_identical)

names(r0) <- innames

r0$Shrub <- r0$Aspen + r0$Mixed + r0$Shrub0

r <- r0[[rnames]]

writeRaster(r, file.path(outpath, 'EnvironmentData.GTiff'), filetype='GTiff',
            overwrite=TRUE)

# 
# #Get Topographical Data 
# Elevation <- rast("TransectRasters/Elevation.tif") 
# Slope <- rast("SNV/Topography/Slope30SNV.tif")
# TRI <- rast("SNV/Topography/TRI30SNV.tif") 
# #PRR <- rast("NicheAnalysis/HabitatData/Topography/prr.tif") - PotentialRelativeRadiation - this layer wasn't in Jan Layers. 
# #Hillshade <- rast("NicheAnalysis/HabitatData/Topography/hillshade.tif")  - this layer wasn't in Jan Layers. 
# 
# #Productivity Data ("vegetation condition")
# #Productivity across growing season
# ##NDVICV is a measure of the variation of this productivity
# NDVICV<- rast("SNV/NDVI/NDVICVMeanMax1989_2015SNV.tif") 
# NDVICV
# #Max productivity
# NDVIMeanMax <- rast("SNV/NDVI/NDVICVMeanMax1989_2015SNV.tif") 
# NDVIMeanMax
# 
# #Get Climate Data
# #GrowingSeasonRainfall
# Precip0609 <- rast("SNV/Climate/Precip/precip0609SNV.tif")
# Precip0609
# 
# #Non-GrowingSeasonPrecip
# Precip1005 <- rast("SNV/Climate/Precip/precip1005SNV.tif")
# Precip1005
# #Min Jan Temp
# #Note, the January data layers only had Tmin for 07 (July), so used a file from Oct.  Checked the dimensions against Elevation, and they are the same.  
# Tmin01<- rast("/Volumes/AvivasDissertation_2018_4158472461/Dissertation/GISData_UpdatedNDVIlayerOct2017/AlpineMammals/NicheAnalysis/HabitatData/Climate/Temp/tmin01.tif") 
# dim(Tmin01)
# dim(Elevation)
# #Max July Temp
# Tmax07 <- rast("SNV/Climate/Tmax/Tmax07SNV.tif") 
# Tmax07
# dim(Tmax07)
# #Snow cover (<15%)
# Snow <- rast("SNV/Climate/Snow/SnowFreeDaysSNV.tif")
# dim(Snow)
# #Habitat
# #Note: January data no longer had tif files for this, use shapefiles instead? #Do NOT USE alpmamveg <- readOGR("SNV/Vegetation/Shapefiles", "alpmamveg") - it causes the computer to freeze.  But the rasters were derived from that file.  
# 
# Aspen <- rast("SNV/Vegetation/Rasterveg/aspen30m.img") 
# dim(Aspen)
# dim(Elevation)
# Conifer <- rast("SNV/Vegetation/Rasterveg/conifer30m.img") 
# Meadow <- rast("SNV/Vegetation/Rasterveg/meadow30m.img")
# Mixed <- rast("SNV/Vegetation/Rasterveg/mixed30m.img") 
# Rock <- rast("SNV/Vegetation/Rasterveg/rock30m.img") 
# Shrub <- rast("SNV/Vegetation/Rasterveg/shrub30m.img") 
# 
# 
# 
# #Save resampled files so that I don't have to resample each time I run this. 
# #writeRaster(tmin01, "SNV/ResampledRasterFiles/tmin0130x30")
# #writeRaster(tmax07, "SNV/ResampledRasterFiles/tmax0730x30")
# #writeRaster(ppt0609, "SNV/ResampledRasterFiles/ppt060930x30")
# #writeRaster(ppt1005, "SNV/ResampledRasterFiles/ppt100530x30")
# #writeRaster(ndvicv, "SNV/ResampledRasterFiles/ndvicv30x30")
# #writeRaster(ndvimeanmax, "SNV/ResampledRasterFiles/ndvimeanmax30x30")
# #writeRaster(conifer, "SNV/ResampledRasterFiles/conifer30x30")
# #writeRaster(meadow, "SNV/ResampledRasterFiles/meadow30x30")
# #writeRaster(rock, "SNV/ResampledRasterFiles/rock30x30")
# writeRaster(mixed, "SNV/ResampledRasterFiles/mixed30x30")
# ?writeRaster
