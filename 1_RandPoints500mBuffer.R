setwd("/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI")

library(sf)
library(terra)

#==============================================================================
# Niche factor analysis based on spatial locations of XXX collected along 21
# transects in the Sierra Nevada from 2009 - 2012. In addition to XXX
# locations ("used points") 50,000 random points were generated as "available
# locations" from a 500m buffer around the Transections. 
# The available points then need to be filtered for elevations > 2500 m (about 8500
# feet). 
#==============================================================================

library(dismo)
#Read 500M Buffer Transect File into R
snv_transects <- st_read("SNV/SNVTransects", layer = "SNVtrans500mbuff")

# select 50000 random points
# set seed to assure that the examples will always
# have the same random sample.
set.seed(1963)
#RandPtsTransectBuffer <- randomPoints(A, 230)
#Note, randomPoints from dismo was giving error messages, so switched to spsample in the sp libarary (which came with raster).

RandPtsTransect500mBuffer <- spsample(B, 50000, type = "random")
plot(RandPtsTransect500mBuffer)

str(RandPtsTransect500mBuffer)
head(RandPtsTransect500mBuffer)

#####
class(RandPtsTransect500mBuffer)
#write OGR requires a SpatialPointsDataFrame, not just SpatialPoints objet
writeOGR(RandPtsTransect500mBuffer, "Analysis/RandomPoints", "RandDPtsTransect500mBuffer", driver = "ESRI Shapefile")
plot(RandPtsTransect500mBuffer)

RandPtsTransect500mBuffer
#SpatialPointsDataFrame(RandPtsTransect500mBuffer, df).  This isn't working because I'm not making the dataframe the correct size (was doing 5000, same as number of features in SpatialPoints)


#Here is the best way to convert a SpatialPoints object to a SpatialPointsDataFrame.
spobj <- RandPtsTransect500mBuffer #this is your SpatialPoints object
df <- data.frame(id=1:length(spobj)) #creating a very small data.frame 
spdf <- SpatialPointsDataFrame(spobj, data=df) #combining your data.frame and your SpatialPoints object
class(spdf) #check to see if the result really is a SpatialPointsDataFrame

#Here is how you would save that object as a shapefile
library(rgdal)
writeOGR(spdf, dsn='Analysis/RandomPoints', layer='RandPtsTransect500mBuffer',
         driver='ESRI Shapefile')

RandPtsTransect500mBuffer <- shapefile("Analysis/RandomPoints/RandPtsProj.shp")
class(RandPtsTransect500mBuffer)

 
#This works, but it saves it as a non-spatial object. Need to add spatial info. 
RandPtsDF <- as.data.frame(RandPtsTransect500mBuffer) 
coordinates(RandPtsDF) <- c(1,2)
projection(RandPtsDF) <- CRS('+proj=utm +zone=11 +datum=NAD83')

RandPtsDF
str(RandPtsDF)
names(RandPtsDF)
head(RandPtsDF)
RandPtsDF
