#############################################
####Determination of the number of cluster###
#############################################

require("stats")
#If you go over to Michael Grogan's site, you will see he has a great method for figuring out how many clusters to choose. 
#http://www.michaeljgrogan.com/k-means-clustering-example-stock-returns-dividends/
#https://analytics4all.org/2016/12/11/r-k-means-clustering-deciding-how-many-clusters/
# Elbow method
wss<- rep(0,25)
for (i in 1:25) wss[i]<-sum(kmeans(all_z_scale, centers=i)$withinss)
#withinss = Vector of within-cluster sum of squares, one component per cluster.
plot(1:25, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")
#Visually choose the elbow of the curve as the number of optimal cluster.