#I am trying Crop instead of setExtent (doesn't work during extract) or resample (which may distort).  Resample will distort a little bit.
setwd("/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_March27_2019ClippedToTransects/TransectRasters")
outpath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"

library(terra)

#all files have 30m x 30m resolution but different extents
rast_files <- c("Elevation.tif", #elevation
                #"Aspect.tif", #aspect
                "Slope.tif", #slope
                "TRI.tif", #ruggedness
                "NDVIcv.tif", #NDVI coef of var
                "NDVIMax.tif", #NDVI
                "Precip0609.tif", #growing season precip
                "Precip1005.tif", #non growing season precip
                "Tmin01.tif", #min temp in January
                "Tmax07.tif", #max temp in July
                "Snow.tif", # days w/o snow on ground
                "Aspen.tif", #areas of Aspen land cover
                "Conifer.tif", #areas of conifer land cover
                "Meadow.tif", #areas of meadow land cover
                "Mixed.tif", #areas of mixed type land cover
                "Rock.tif", # areas of bare rock
                "Shrub.tif") #areas of shrubland


x <- rast(rast_files)


rlist <- lapply(rast_files, rast)


min_extent <- Reduce(function(r1, r2) intersect(ext(r1), ext(r2)), rlist)

r_croplist <- lapply(rlist, crop, min_extent)

r <- rast(r_croplist)

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
# NDVIMeanMax <- rast("SNV/NDVI/NDVIMeanMax1989_2015SNV.tif") 
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
