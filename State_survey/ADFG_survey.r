
## file to run and plot ADFG GOA pcod survey random effects model.


library(data.table)
library(ggplot2)

dglm = dget("delta_glm_1-7-2.get")
data<-read.csv("1988to2021pcodcatch.csv")
data<-data.table(data)
data<-data[district%in%c(1,2,6)]
data<-data[!is.na(avg_depth_fm)&!is.na(start_longitude)]

## set up strata for analysis
data$depth<-1
data$depth[data$avg_depth_fm>30]<-2
data$depth[data$avg_depth_fm>70]<-3

data$density<-data$total_weight_kg/data$area_km2

mydata<-data.frame(Density=data$total_weight_kg/data$area_km2,year=data$year,district=data$district,depth=data$depth)

codout = dglm(mydata,dist="gamma",write=T,J=T)  ## run gamma distribution model
codout2 = dglm(mydata,dist="lognormal",write=T,J=T) ## run lognormal model

## create and populate index tables
index<-data.table(codout$deltaGLM.index)
index$year<-1988:2021


index2<-data.table(codout2$deltaGLM.index)
index2$year<-1988:2021
 
## plot indices
 a<-ggplot(index,aes(x=factor(year),y=index))
 a<-a+geom_point()+geom_line()+ylim(0,4.5)
 a<-a+geom_errorbar(aes(ymin=index-jack.se,ymax=index+jack.se))
 a<-a+theme_bw(base_size=20)+ggtitle("ADFG trawl survey")+ylab("ADFG trawl survey index")+xlab("Year")+theme(axis.text.x = element_text(hjust=1, angle = 90))
 print(a)


 index2$ID<-1:nrow(index2)
 b<-ggplot(index2,aes(x=factor(year),y=index))
 b<-b+ylim(0,4.5)+geom_errorbar(aes(ymin=index-jack.se,ymax=index+jack.se))+geom_path(aes(group=""),color="gray50")+geom_point(color="red",size=2.5)
 b<-b+theme_bw(base_size=20)+ggtitle("ADFG trawl survey Pacific cod delta-glm density index")+ylab(expression(paste("Density index (kg/k",m^2,")",sep="")))+xlab("Year")+theme(axis.text.x = element_text(hjust=1, angle = 90))
 print(b)

## plot length comp distribution from ADFG survey

length<-read.csv("CRAB2000-2021-pcod_lfn_by_dist.csv")
length<-data.table(length)
length$year<-as.numeric(substring(length$survey_name,5,8))
length$subtotal<-rowSums(length[,c(3,4,6)])

d<-ggplot(length,aes(x=factor(year),y=length,size=subtotal))
d<-d+geom_point(shape=1)
d<-d+theme_bw(base_size=20)
d<-d+ylab("Length(cm)")+xlab("Year")+ylim(0,130)
d<-d+guides(size=guide_legend(title="Number"))
print(d)

## violin plot of length comps.
g <- ggplot(data=length, aes(x=factor(year), y=length, weight=tot_fish,color=factor(year),fill=factor(year))) + geom_violin(trim=F) + geom_boxplot(width=0.1,color='black') + theme_bw()
print(g)


p<- ggplot(length, aes(length, factor(year), fill=factor(year),height = tot_fish)) + 
   theme_ridges(font_size = 20) +
   geom_density_ridges(stat='identity')
p<-p+labs(x="Length (cm)",y="Year",fill='Year',title="ADFG trawl survey abundance of Pacific cod by length" )+ theme(legend.position = "none")


col.pal = colorRampPalette(c("blue","cyan","green","yellow","red"))


data$pres<-0
data$pres[data$total_weight_kg>0]<-1

data3<-data[pres==0]

## plot maps of ADFG survey
bering<-get_map(location=c(lon=-158,lat=56),zoom=6,maptype="toner", color="bw")
k<-ggmap(bering)
k <- k + geom_point(data=data,aes(x=start_longitude,y=start_latitude,color=log(density)), size=0.1)
k<-k+ylab(expression(paste("Latitude ",degree,"N")))+xlab(paste("Longitude"))

k<-k+scale_colour_gradient(name=expression(paste("Log density (kg/k",m^2,")",sep="")),low = "yellow", high = "red", na.value = "light blue" )
#k<- k+scale_colour_manual(name="Presence/absence",labels=c("Cod not present","Cod present"),values=c("blue","red"))
k<-k+ggtitle("ADFG trawl survey 1988-2021")
k<-k+facet_wrap(~year, ncol=12)
k

    

bering<-get_map(location=c(lon=-158,lat=56),zoom=6,maptype="toner", color="bw")
k<-ggmap(bering)
k <- k + geom_point(data=data,aes(x=start_longitude,y=start_latitude),color="red", size=0.25)
k<-k+ylab(expression(paste("Latitude ",degree,"N")))+xlab(paste("Longitude"))

#k<-k+scale_colour_gradient(name=expression(paste("Log density (kg/k",m^2,")",sep="")),low = "yellow", high = "red", na.value = "light blue" )
#k<- k+scale_colour_manual(name="Presence/absence",labels=c("Cod not present","Cod present"),values=c("blue","red"))
k<-k+ggtitle("ADFG trawl survey 1988-2021")
k<-k+facet_wrap(~year, ncol=8)
k
 
