#################################
#####Urine patches detection#####
#################################
## Adaptable R script for urine patch detection
## Read the README.md file

# Required packages (updates 2017)
install.packages(c("raster","igraph","SDMTools")
require("raster")# version 2.6-7, 11/2017 maintainer Robert J. Hijmans, http://www.rspatial.org/
require("igraph") # clump function
require("SDMTools") # PatchStat() and ConnLabel

##################### extra functions
# Function 'fill.na' fills the holes inside the detected patches
fill.na<-function(x,h=5) {
  if(is.na(x)[h]) {
    return(round(mean(x,na.rm=TRUE),0))
  } else{
    return(round(x[h],0))
  }
}
#Function 'erode_pix' deletes the isolated pixels groups
erode_pix <- function(j,x) {
  maskpatch<-clump(x, directions=8, gaps=FALSE) 
  #'clump' was used to detect connected pixel into clump (id), NA or 0 = background
  p<-PatchStat(maskpatch)
  # get frequency table
  f<-freq(maskpatch)
  f<-as.data.frame(f)
  # which rows of the data.frame are only represented by clumps under 15pixels?
  str(which(f$count <= j))
  str(f$value[which(f$count <= j)])
  excludeID <- f$value[which(f$count <= j)]
  # make a new raster to be saved
  formaskSieve <- maskpatch
  # assign NA to all clumps whose IDs were identified in excludeID
  formaskSieve[maskpatch %in% excludeID] <- NA
  # plot(formaskSieve)
  formaskSieve
}
#Function 'cover_calcul' calculates urine patches' cover in each image
cover_calcul <- function(j,x) { # j=total surface of the field in m2, x=layer to consider after kmeans and isollation of a patch
  df<-summary(x)   # number of Na;s
  tot_pix<-nrow(x)*ncol(x) # number of pixels in the layes
  tot_cover_pix<-tot_pix-df[6] # number of pixel detected as part of urine patches
  resolution<-j/tot_pix # image resolution
  tot_cover_surf<-tot_cover_pix*resolution # coverage of urine patches in m2
  tot_cover_perc<-(tot_cover_surf*100)/j # percentage of area detected as urine patches
  results<-data.frame(tot_pix,tot_cover_pix,resolution,tot_cover_surf,tot_cover_perc)
  colnames(results)<-c("tot_pix","tot_cover_pix","resolution","tot_cover_surf","tot_cover_perc")
  results
}
#####################


## Read images
images.path <- "~/Downloads/Urine-patches-detection-master" # add your image to the folder or use the Test_image.tif provided.
all.images <- list.files(images.path, recursive=TRUE, full.names=TRUE, pattern = ".tif$")
# 'all.images' lists the different images present in the folder (images.patch) that will be analysed:
#	Each image is a 15 x 15 m square of grassland
#	Each image contents a Red, Green, Blue, NIR+Red channel, NIR and DSM (elevation meters from sea level)

## Kmeans segmentation
for(i in 1:length(all.images)){
  z<-brick(all.images[i])
  names(z)<-c("red","green","blue","NIR+red","NIR","DSM")
  # Calculation of NDVI layer
  NDVI<-((z$NIR-z$red)/(z$NIR+z$red))
  z_multi<-addLayer(z,NDVI)
  names(z_multi)[7] <-  "NDVI"
  
  # In this example of the script, only the NDVI is considered/processed. 
  # Choose the layer you wish to use here.
  all_z<-(z_multi$NDVI)
  # Center and/or scale raster data
  all_z_scale<-scale(values((all_z)))
  # 'set.seed' set the start point of the clustering to make this process reproducible
  set.seed(2) 
  
  # Run Cluster number function to get the optimal cluster number, here the cluster optimal number was 4
  km<-kmeans(all_z_scale, center=4,iter.max=500,nstart=1,algorithm = "Lloyd")
  kmr<-setValues(all_z, km$cluster)
  # Visual selection of the cluster corresponding to the patches using the function 
  #'calc' {raster}. Essential step to be done for each image. Here value selected is 3.
  patch<-calc(kmr, function(x){x[x!=3]<- NA;return(x)}) 
 
  ## Refinement
  # Applied 'erode_pix' to remove isolated pixels detected between urine patches
  # Chose 200 pixels  which correspond to approximately 300cm2 if resolution 1.56cm/pixel
  maskpatch<-erode_pix(200, patch)  
  # Applied 'fill.na' to remove gaps inside the urine patches detected
  maskpatch_fill<- focal(maskpatch,w=matrix(1,3,3),fun=fill.na,pad=TRUE,na.rm=FALSE)

  ## Visualisation of the results
  par(mfrow=c(1,4))
  plotRGB(z,r=1, g=2, b=3)
  plot(kmr, legend=FALSE)
  plot(patch, col="red", legend=FALSE)
  plot(maskpatch_fill, col="red", legend=FALSE) 
  
  par(mfrow=c(1,1))
  plotRGB(z,r=1, g=2, b=3)
  plot(maskpatch_fill, col="red", legend=FALSE, add=T) 

  ## Calculation of the resulting covers areas and compilation in a csv file
  df<-cover_calcul(225,maskpatch_fill)
  namefile<-paste("coverage_data_300cm",i,".csv") #specific name for each input (image file)
  write.csv(df, namefile)
}
