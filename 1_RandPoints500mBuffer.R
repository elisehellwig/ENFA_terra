setwd("/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI")

outpath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"

library(terra)

#==============================================================================
# Niche factor analysis based on spatial locations of XXX collected along 21
# transects in the Sierra Nevada from 2009 - 2012. In addition to XXX
# locations ("used points") 50,000 random points were generated as "available
# locations" from a 500m buffer around the Transections. 
# The available points then need to be filtered for elevations > 2500 m (about 8500
# feet). 
#==============================================================================

#Read 500M Buffer Transect File into R
snv_transects <- vect("SNV/SNVTransects", layer = "SNVtrans500mbuff")

# select 50,000 random points
# set seed to assure that the examples will always
# have the same random sample.
set.seed(1963)

snv_rand_pts <- spatSample(snv_transects, 5e4, method = "random")
#figure out how to filter for above 2500m later

snv_rand_pts$PA <- 0 #presence/available is 0 for available

snv_rand_pts$Species <- 'Random'

snv_rand_pts <- snv_rand_pts[,c('Species', 'PA')]

#save original transects as geojson (aka not a shapefile)
# writeVector(snv_transects, file.path(outpath, 'SNV_Transects_Buffered_500m.geojson'),
#             filetype='GeoJSON')

#save random points as a geojson
writeVector(snv_rand_pts, file.path(outpath, 'SVN_Random_Points.geojson'),
            filetype='GeoJSON', overwrite=TRUE)
