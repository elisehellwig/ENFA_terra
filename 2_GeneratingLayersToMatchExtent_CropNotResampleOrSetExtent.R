#I am trying Crop instead of setExtent (doesn't work during extract) or resample (which may distort).  Resample will distort a little bit.
setwd("/Volumes/AvivasDissertation_2018_4158472461/Dissertation/GISData_Jan2018UpdatedNDVI") 

library(rgdal)
library(raster)

#Get Topographical Data 
Elevation <- raster("SNV/Topography/Elevation30SNV.tif") 
Elevation
Slope <- raster("SNV/Topography/Slope30SNV.tif") 
Slope
TRI <- raster("SNV/Topography/TRI30SNV.tif") 
#PRR <- raster("NicheAnalysis/HabitatData/Topography/prr.tif") - PotentialRelativeRadiation - this layer wasn't in Jan Layers. 
#Hillshade <- raster("NicheAnalysis/HabitatData/Topography/hillshade.tif")  - this layer wasn't in Jan Layers. 

#Productivity Data ("vegetation condition")
#Productivity across growing season
##NDVICV is a measure of the variation of this productivity
NDVICV<- raster("SNV/NDVI/NDVICVMeanMax1989_2015SNV.tif") 
NDVICV
#Max productivity
NDVIMeanMax <- raster("SNV/NDVI/NDVIMeanMax1989_2015SNV.tif") 
NDVIMeanMax

#Get Climate Data
#GrowingSeasonRainfall
Precip0609 <- raster("SNV/Climate/Precip/precip0609SNV.tif")
Precip0609

#Non-GrowingSeasonPrecip
Precip1005 <- raster("SNV/Climate/Precip/precip1005SNV.tif")
Precip1005
#Min Jan Temp
#Note, the January data layers only had Tmin for 07 (July), so used a file from Oct.  Checked the dimensions against Elevation, and they are the same.  
Tmin01<- raster("/Volumes/AvivasDissertation_2018_4158472461/Dissertation/GISData_UpdatedNDVIlayerOct2017/AlpineMammals/NicheAnalysis/HabitatData/Climate/Temp/tmin01.tif") 
dim(Tmin01)
dim(Elevation)
#Max July Temp
Tmax07 <- raster("SNV/Climate/Tmax/Tmax07SNV.tif") 
Tmax07
dim(Tmax07)
#Snow cover (<15%)
Snow <- raster("SNV/Climate/Snow/SnowFreeDaysSNV.tif")
dim(Snow)
#Habitat
#Note: January data no longer had tif files for this, use shapefiles instead? #Do NOT USE alpmamveg <- readOGR("SNV/Vegetation/Shapefiles", "alpmamveg") - it causes the computer to freeze.  But the rasters were derived from that file.  

Aspen <- raster("SNV/Vegetation/Rasterveg/aspen30m.img") 
dim(Aspen)
dim(Elevation)
Conifer <- raster("SNV/Vegetation/Rasterveg/conifer30m.img") 
Meadow <- raster("SNV/Vegetation/Rasterveg/meadow30m.img")
Mixed <- raster("SNV/Vegetation/Rasterveg/mixed30m.img") 
Rock <- raster("SNV/Vegetation/Rasterveg/rock30m.img") 
Shrub <- raster("SNV/Vegetation/Rasterveg/shrub30m.img") 

#Give all layers the same CRS.  Assume all should be like Elevation. 
?spTransform
?projectRaster
crs(Elevation)
crs(TRI)
crs(NDVICV)##
NDVICV1 <- projectRaster(Elevation, NDVICV)
NDVICV2 <- projectRaster(NDVICV, crs = "+proj=utm +zone=11 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
crs(NDVIMeanMax)##
crs(Precip1005)
crs(Precip0609)
crs(Tmax07)
crs(Tmin01)##
crs(Snow)##
crs(Aspen)##
crs(Conifer)##
projectRaster()

#In order to crop, the resultion needs to be the same in all rasters.  I am checking that below. 
#First, making a list with all of the variables. 
variable <- c(Elevation, Slope, TRI, NDVICV, NDVIMeanMax, Precip1005, Precip0609, Tmax07, Tmin01, Snow, Aspen, Conifer, Meadow, Mixed, Rock, Shrub)

#The function "res" does not work on lists, so I need to use sapply to apply the res function across each item in the list.  
sapply(variable, res)
res(variable)
head(variable)

# All rasters have the same resolution, so we can use crop.  This will crop all rasters to the raster with the smallest extent.  This will not distort the data, or give phantom rows, and will be much faster than resample.  

#Give all the rasters the same extent.  Note: could not just do (extent(variable) for similar reasons to res.)
#First, see what the extents of all variables are. 
a <- sapply(variable, extent)

#The following return just the individual extents of xmin, xmax, ymin, ymax
b <- sapply(variable, function(v) {
  xmin(extent(v))
})
c <- sapply(variable, function(v) {
  xmax(extent(v))
})
d <- sapply(variable, function(v) {
  ymin(extent(v))
})
e <- sapply(variable, function(v) {
  ymax(extent(v))
})
#Then I get the value of the highest xmin and ymin, and the lowest xmax and ymax.  This is because I want to find a rectangle that is the smallest overall extent.  With xmin and ymin, you want the largest values, because those are towards the interior of the rectangle of the raster.  
xmin <- max(b)
xmax <- min(c)
ymin <- max(d)
ymax <- min(e)

#Now I need to create a new object using these dimensions, and I will crop to this. 
?Extent
MinExtent <- extent(xmin, xmax, ymin, ymax)
class(MinExtent)
#MinExtent is an Extent object representing the minimum dimensions of the layers that I have.  
#variable <- c(Elevation, Slope, TRI, NDVICV, NDVIMeanMax, Precip1005, Precip0609, Tmax07, Tmin01, Snow, Aspen, Conifer, Meadow, Mixed, Rock, Shrub)
#Now crop
#CropVarList <- sapply (variable, crop, MinExtent) - tried this, but then when I compareRaster, it said they had different extents.  So just doing it individually.  
elevation <- crop(Elevation, MinExtent)
slope <- crop(Slope, MinExtent)
tri <- crop(TRI, MinExtent)
ndvicv <- crop(NDVICV, MinExtent)
ndvimeanmax <- crop(NDVIMeanMax, MinExtent)
ppt1005 <- crop(Precip1005, MinExtent)
ppt0609 <- crop(Precip0609, MinExtent)
tmax07 <- crop(Tmax07, MinExtent)
tmin01 <- crop(Tmin01, MinExtent)
snow <- crop(Snow, MinExtent)
aspen <- crop(Aspen, MinExtent)
conifer <- crop(Conifer, MinExtent)
meadow <- crop(Meadow, MinExtent)
mixed <- crop(Mixed, MinExtent)
rock <- crop(Rock, MinExtent)
shrub <- crop(Shrub, MinExtent)

#tmax07 and tmin01 are still off by one column using crop, so I'm going to resample those.  Even though the dim() are identical for ppt1005, ppt0609, ndvimeanmax, ndvicv, conifer, meadow, rock (when compared to elevation), I am getting "different extent" errors.  So running resample on these.  But because of the crop, it should not distort with resample.    
#tmax07 <- resample(tmax07, elevation)
#tmin01 <- resample(tmin01, elevation)
#ppt1005 <- resample(ppt1005, elevation)
#ppt0609 <- resample(ppt0609, elevation)
#ndvimeanmax <- resample (ndvimeanmax, elevation)
#ndvicv <- resample (ndvicv, elevation)
#conifer <- resample (conifer, elevation)
#meadow <- resample (meadow, elevation)
#rock <- resample(rock, elevation)

ompareRaster(c(elevation,tri,slope,ppt1005,ppt0609,tmin01,tmax07,snow,ndvimeanmax,ndvicv,aspen,conifer,meadow,mixed,rock,shrub))

compareRaster(elevation, shrub)
crs(elevation)
crs(shrub,)
crs(shrub)
dim(elevation)
dim(tri)
dim(slope)
dim(ppt1005)
dim(ppt0609)
dim(tmin01)
dim(tmax07)
dim(snow)
dim(ndvimeanmax)
dim(ndvicv)
dim(aspen)
dim(conifer)
dim(meadow)
dim(mixed)
dim(rock)
dim(shrub)

#Save resampled files so that I don't have to resample each time I run this. 
#writeRaster(tmin01, "SNV/ResampledRasterFiles/tmin0130x30")
#writeRaster(tmax07, "SNV/ResampledRasterFiles/tmax0730x30")
#writeRaster(ppt0609, "SNV/ResampledRasterFiles/ppt060930x30")
#writeRaster(ppt1005, "SNV/ResampledRasterFiles/ppt100530x30")
#writeRaster(ndvicv, "SNV/ResampledRasterFiles/ndvicv30x30")
#writeRaster(ndvimeanmax, "SNV/ResampledRasterFiles/ndvimeanmax30x30")
#writeRaster(conifer, "SNV/ResampledRasterFiles/conifer30x30")
#writeRaster(meadow, "SNV/ResampledRasterFiles/meadow30x30")
#writeRaster(rock, "SNV/ResampledRasterFiles/rock30x30")
writeRaster(mixed, "SNV/ResampledRasterFiles/mixed30x30")
?writeRaster
