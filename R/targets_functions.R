source("R/enfa_functions.R")

download_tmin <- function(path) {
  worldclim_tile('tmin', lon=-118, lat=36.5, 
                 path=path)$tile_15_wc2.1_30s_tmin_1 + 273.15
}


stack_raster_data <- function(file, path) {
  datapath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"
  
  fns <- fread(file)
  
  filepaths <- file.path(path, fns$filenames)
  
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


sample_random_points <- function(file, n) {
  
  snv_transects <- vect(file)
  
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


combine_presence_locations <- function(loc, acronyms) {
  
  fns <- sapply(acronyms, function(name) {
    paste0(loc, "/Locations/Transects/", name, "/", name, "CoordsSNV.shp")
  })
  
  rodent_pts_ls <- lapply(1:length(acronyms), function(i) {
    sv <- vect(fns[i])
    sv$Species <- acronyms[i]
    sv$PA <- 1
    sv
  })
  
  return(vect(rodent_pts_ls))
  
  
}

extract_values <- function(pres, avail, env_data) {
  
  all_pts <- rbind(pres[,c('Species', 'PA')], avail)

  all_pts$ID <- 1:nrow(all_pts)
  
  pa_env <- terra::extract(env_data, all_pts, ID=TRUE)
  
  pa_sv <- merge(all_pts, pa_env, by='ID')
  
  pa0 <- data.frame(pa_sv)
  

  #return(pa_sv)

  return(pa0[which(pa0$Elevation>2500), ])
  
}

run_enfa <- function(acronyms, data) {
  lapply(acronyms, run_enfa_species, df=data)
}


plot_histogram <- function(mods, species_names, bin_num) {
  
  scores <- lapply(1:length(species_names), function(i) {
    HistData(mods[[i]], species_names[i])
  }) %>% rbindlist()
  
  scores$Species <- factor(scores$Species, levels=species_names)
  
  fills = c('Available'='white', 'Used'='grey10')
  
  p <- ggplot(data=scores) + #set data source
    #plot Available data with black outlines and no fill
    geom_histogram(data=scores[AU=='Available'], 
                   aes(x=value, y=after_stat(density)), color='black', fill=NA, 
                   bins=bin_num) +
    #plot both Available and Used data with fill but no outlines
    geom_histogram(aes(x=value, y=after_stat(density), group=AU, color=AU, fill=AU), 
                   position='identity', alpha=0.3, color=NA, bins=bin_num) +
    scale_fill_manual(values=fills, name='Niche Space') + #add legend
    
    #create separate graphs by species and type (marginality vs specialization)
    #and allow y axis to vary between plots, specify number of columns = 2 
    facet_wrap(Species~facetvar, ncol=2, scales='free') + 
    
    labs(x='ENFA Scores', y='Density') + #set axes labels
    theme_bw(22) + #set font to size '22'
    theme(panel.grid.major = element_blank(), #remove major grid lines
          panel.grid.minor = element_blank(), #remove minor grid lines
          strip.text.x = element_text(size = 18)) #set plot titles to be a bit larger
  
  png('Plots/NicheSpaceHistogram.png', width = 2000, height=2000, res=150)
  p
  dev.off()
}


extract_hulls <- function(mods, species_names) {
  hulls <- lapply(1:length(mods), function(i) {
    ExtractHull_species(mods[[i]], species_names[i])
  }) %>% rbindlist()
  
  hulls$Species <- factor(hulls$Species, levels=species_names)
  
  return(hulls)
}

extract_vectors <- function(mods, sp_df, v_label) {
  
  key <- unique(v_label[,.(Variable, ID)])
  
  vects <- lapply(1:length(mods), function(i) {
    ExtractVectors_species(mods[[i]], v_label, sp_df$Acronym[i],
                          sp_df$Species[i])
  }) %>% rbindlist()
  
  vects$Species <- factor(vects$Species, levels=sp_df$Species)
  
  
  return(vects)
  
}


calculate_marginality <- function(mods, species_names) {
  marginality <- lapply(1:length(mods), function(i) {
    data.table(Species=species_names[i], x=mag(mods[[i]]$mar), y=0)
  }) %>% rbindlist()
  
  #dummy column so marginality points are all the same color
  marginality[, Fill:='Marginality']
  
  marginality$Species <- factor(marginality$Species, levels=species_names)
  
  
 return(marginality)
   
}

create_biplot <- function(hulls, vects, marginality, species_names) {

  #sets colors for distinguishing avaliable vs used niche space
  niche_colors <- c('Available'='#d95f02', 'Used'='#7570b3')

  #set color for marginality point
  margin_color <- c('Marginality'='#1b9e77')

  hulls$Species <- factor(hulls$Species, levels=species_names)
  vects$Species <- factor(vects$Species, levels=species_names)
  marginality$Species <- factor(marginality$Species, levels=species_names)
  
  
  bp <- ggplot(data=hulls) + #set first data source
    geom_hline(aes(yintercept=0), linetype='dashed', linewidth=0.2) + #add horizontal dashed line
    geom_vline(aes(xintercept=0), linetype='dashed', linewidth=0.2) + #add vertical dashed line
    
    #add niche space polygons (oka hulls)
    geom_polygon(data=hulls, aes(x=x, y=y, group=Group, color=Group), fill=NA) + 
    
    #add legend for niche space polygon colors
    scale_color_manual(values = niche_colors, name='Niche Space')+
    
    #add vector arrows of each variable in model
    geom_segment(data=vects, aes(x=0, y=0, xend=x, yend=y, group=Variable), 
                 lineend = 'butt', linejoin = 'mitre', linewidth=0.3,
                 arrow=arrow(length = unit(0.12, "cm"))) +
    
    #add labels to the vector arrows
    geom_text(data=vects, aes(x=text_x, y=text_y, label=ID), size=4) +
    
    #add marginality point to plot
    geom_point(data=marginality, aes(x=x, y=y, fill=Fill), size=3, pch = 21) +
    
    scale_fill_manual(values = margin_color, name="")+ #add legend for marginality point
    
    facet_wrap(~Species, nrow=3) + #breaking plots up by species
    
    labs(x='Marginality', y='Specialization') + #adding axis labels
    
    theme_bw(20) + # set 'font size' to 20
    theme(panel.grid.major = element_blank(), #remove major grid lines
          panel.grid.minor = element_blank(), #remove minor grid lines
          #axis.title=element_text(size=18)   #set axes titles at specific size 
          strip.text.x = element_text(size = 18)) #set plot subtitles at specific size
  
  
  png('Plots/NicheSpaceBiplot.png', width = 1500, height=2000, res=150)
  bp
  dev.off()
}
