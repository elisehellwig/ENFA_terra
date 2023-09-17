# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("terra", "geodata", "data.table", "ade4", "adehabitatHS", "magrittr", 
               "ggplot2", "ggordiplots") # packages that your targets need to run
  
  #format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  #   controller = crew::crew_controller_local(workers = 2)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package. The following
  # example is a controller for Sun Grid Engine (SGE).
  # 
  #   controller = crew.cluster::crew_controller_sge(
  #     workers = 50,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.0".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# tar_make_clustermq() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
options(clustermq.scheduler = "multicore")

# tar_make_future() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  
  tar_target(
    name = shared_drive,
    command = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI"
  ),
  
  tar_target(
    name = raster_file,
    command = "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/raster_file_names.csv",
    format = "file" # efficient storage for large data frames
  ),
  
  tar_target(
    name = transect_file, 
    command =  "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/SNV_Transects_Buffered_500m.geojson",
    format = "file"
  ),
  
  tar_target(
    name = species_file, 
    command =  "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/species_names.csv",
    format = "file"
  ),
  
  tar_target(
    name = labels_file, 
    command =  "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data/vector_labels.csv",
    format = "file"
  ),
  
  tar_target(
    name = species,
    command = fread(species_file)
  ),
  
  tar_target(
    name = vec_labels,
    command = fread(labels_file)
  ),
  
  tar_target(
    name = raster_data,
    command = stack_raster_data(raster_file, shared_drive)
  ),

  tar_target(
    name = random_points,
    command = sample_random_points(transect_file, "SNVtrans500mbuff", 5e4),
  ),
  
  tar_target(
    name = presence_points,
    command = combine_presence_locations(shared_drive, species$Acronym)
  ),
  
  tar_target(
    name = pa_data,
    command = extract_values(presence_points, random_points, raster_data)
  ),
  
  tar_target(
    name = enfa_model,
    command = run_enfa(species$Acronym, pa_data)
  ),
  
  tar_target(
    name = histogram_plot,
    command = plot_histogram(enfa_model, species$Species, 25)
  ),
  
  tar_target(
    name = hulls,
    command = extract_hulls(enfa_model, species$Species)
  ),
  
  tar_target(
    name = vectors,
    command = extract_vector(enfa_model, species, vec_labels)
  ),
  
  tar_target(
    name = marginality,
    command = calculate_marginality(enfa_model, species)
  ),
  
  
  tar_target(
    name = biplot,
    command = create_biplot(hulls, vectors, marginality, species$Species)
  )
  
)
