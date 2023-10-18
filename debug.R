library(terra)
library(geodata)
library(data.table)
library(targets)

tar_make(callr_function = NULL)

shared_drive = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI"
raster_file = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/raster_file_names.csv"
transect_file = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/SNV_Transects_Buffered_500m.geojson"
species_file = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/species_names.csv"

species = fread(species_file)
system.time(raster_data = stack_raster_data(raster_file, shared_drive))
random_points = sample_random_points(transect_file, 5e4)
presence_points = combine_presence_locations(shared_drive, species$Acronym)
pa_data = extract_values(presence_points, random_points, raster_data)