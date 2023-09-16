download_tmin <- function(path) {
  worldclim_tile('tmin', lon=-118, lat=36.5, 
                 path=path)$tile_15_wc2.1_30s_tmin_1 + 273.15
}


stack_raster_data <- function(file) {
  datapath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"
  
  fns <- fread(file)
  
  filepaths <- file.path(datapath, fns$filenames)
  
  rlist <- lapply(filepaths, rast)
  
  tmin_id <- grep('Tmin', fns$var_names)
  
  rlist[[tmin_id]] <- download_tmin(datapath)
  
  rlist_utm11 <- lapply(rlist, function(r) project(r, crs("epsg:26911")) )
  
  rlist_identical <- lapply(rlist_utm11, resample, rlist_utm11[[1]])
  
  r <- rast(rlist_identical)
  
  names(r) <-  fns$var_names

  r$Shrub <- r$Aspen + r$Mixed + r$Shrub
  
  r$Aspen <- r$Mixed <- NULL
  
  return(r)
  
}


sample_random_points <- function(file, layer, n) {
  
  snv_transects <- vect(file, layer = layer)
  
  # select n random points
  # set seed to assure that the examples will always
  # have the same random sample.
  set.seed(1963)
  
  snv_rand_pts <- spatSample(snv_transects, n, method = "random")
  #figure out how to filter for above 2500m later
  
  snv_rand_pts$PA <- 0 #presence/available is 0 for available
  
  snv_rand_pts$Species <- 'Random'
  
  snv_rand_pts <- snv_rand_pts[,c('Species', 'PA')]
  
  return(snv_rand_pts)
}
