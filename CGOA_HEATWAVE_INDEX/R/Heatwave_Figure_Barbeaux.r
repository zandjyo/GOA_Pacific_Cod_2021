#  Created: 06/02/2020
#  Author: Steve.Barbeaux@noaa.gov
#--------------------------------------------------------------------------------
## set default directory

dir="C:/WORKING_FOLDER/climate_data/data2"

#  Load R libraries
library(ncdf4)
library(curl)
library(lubridate)
library(PCICt)
library(data.table)
library(sp)
library(rgdal)
library(heatwaveR)
library(dplyr)
library(png)
library(ggpubr)
library(extrafont)
library(raster)
library(zoo)
library(scales)
library(tidyverse)
library(tidync)

##NOAA colors
# Blues (the fourth one is just white)
OceansBlue1='#0093D0'
OceansBlue2='#0055A4'
OceansBlue3='#00467F'
OceansBlue4='#FFFFFF'

#  Oranges (the fourth one is a grey)
CrustaceanOrange1='#FF8300'
CrustaceanOrange2='#D65F00'
CrustaceanOrange3='#BC4700'
CrustaceanOrange4='#7B7B7B'
#  Teals (the fourth one is a grey)
WavesTeal1='#1ECAD3'
WavesTeal2='#008998'
WavesTeal3='#007078'
WavesTeal4='#E8E8E8'
#  Greens (the fourth one is a grey)
SeagrassGreen1='#93D500'
SeagrassGreen2='#4C9C2E'
SeagrassGreen3='#007934'
SeagrassGreen4='#D0D0D0'
#  Purples (the fourth one is a grey)
UrchinPurple1='#7F7FFF'
UrchinPurple2='#625BC4'
UrchinPurple3='#575195'
UrchinPurple4='#9A9A9A'

#----------------------------------------------------------------------------------------------------------
#  This chunk should not need to be run again. It downloads data from 9/1/1981 to 5/16/2020 and might not work anymore as 
#----------------------------------------------------------------------------------------------------------

#  Download the data for a fixed spatial and temporal period.
#  (note this is a lot of data and will take a few minutes to download if you do the whole thing)

# download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(1971-01-01T12:00:00Z):1:(1990-12-31T12:00:00Z)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
#               method = "libcurl", mode="wb",destfile = "x1.nc")

# download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(1991-01-01T12:00:00Z):1:(2000-12-31T12:00:00Z)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
#               method = "libcurl", mode="wb",destfile = "x2.nc")

# download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(2001-01-01T12:00:00Z):1:(2010-12-31T12:00:00Z)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
#               method = "libcurl", mode="wb",destfile = "x3.nc")

# download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(2011-01-01T12:00:00Z):1:(2019-12-31T12:00:00Z)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
#               method = "libcurl", mode="wb",destfile = "x4.nc")

# download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(2020-01-01T12:00:00Z):1:(2020-05-24T12:00:00Z)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
#               method = "libcurl", mode="wb",destfile = "x5.nc")

# setwd("C:/WORKING_FOLDER/climate_data/data2")

# ## in the central Gulf of Alaska between 160°W and 145°W longitude 52N and 62N latitude.
# img=readPNG("FISHERIES Wide 360px.png")
# rast <- grid::rasterGrob(img, interpolate = T)

# files=list.files(pattern=".nc")
# buffer<-readOGR(dsn=path.expand(dir),layer="CENTRALGOA_CLIP")


#  meanSST<-vector("list",length=length(files))
#  for(i in 1:length(files)){
#  	pre1.brick = brick(files[i])
#  	pre1.brick = rotate(pre1.brick)
#  	shp = spTransform(buffer, crs(pre1.brick))
#  	pre1.mask = mask(pre1.brick, shp)
#  	pre1.df = as.data.frame(pre1.mask, xy=TRUE)
#  	pre1.df = pre1.df[complete.cases(pre1.df),]
#  	SST=colSums(pre1.df[,3:ncol(pre1.df)])/nrow(pre1.df)
	
#  	dates<-tidync(files[i]) %>% 
#  	     hyper_tibble() %>% 
#    	     mutate(date=as_datetime(time))
	
#  	meanSST[[i]]<-data.frame(day=unique(dates$date),SST=SST)
#  }

#  meanSST<-data.table(do.call(rbind,meanSST))
#  meanSST<-meanSST[order(day),]

#  meanSST$day1<-as.Date(meanSST$day)
#  save.image('Heatwave_figure.RData')
#
#####################################################################################################


setwd(dir)
load('Heatwave_figure.RData')

file=list.files(pattern=".nc")
file.remove(file)




download.file(url = paste0("https://coastwatch.pfeg.noaa.gov/erddap/griddap/ncdcOisst21NrtAgg.nc?sst[(2020-05-25T12:00:00Z):1:(last)][(0.0):1:(0.0)][(52):1:(62)][(200):1:(215)]"),
              method = "libcurl", mode="wb",destfile = "test_OISST.nc")

file=list.files(pattern=".nc")

## pull the .nc file, clip it using the shape file to the 300m isobath in central GOA, and calculate the daily mean
pre1.brick = brick(file) %>% rotate()
shp = spTransform(buffer, crs(pre1.brick))
pre1.mask = mask(pre1.brick, shp)


pre1.df = as.data.frame(pre1.mask, xy=TRUE)
pre1.df = pre1.df[complete.cases(pre1.df),]
SST=colSums(pre1.df[,3:ncol(pre1.df)])/nrow(pre1.df)
	
dates<-tidync(file) %>% hyper_tibble() %>% mutate(date=as_datetime(time))  ## create list of dates

meanSST2<-data.frame(day=unique(dates$date),SST=SST)
meanSST2<-data.table(meanSST2)
meanSST2<-meanSST2[order(day),]
meanSST2$day1<-as.Date(meanSST2$day)
meanSST<-rbind(meanSST,meanSST2)

hobday=ts2clm(meanSST, x =day1, y = SST, climatologyPeriod=c("1982-01-01", "2012-12-31"),pctile=90)
event=data.table(detect_event(hobday, x = day1, y = SST, coldSpells=FALSE,minDuration = 5,joinAcrossGaps = TRUE,maxGap=2)$event)
event$date_start<-as.Date(event$date_start,format="%Y-%d-%m")
event$date_end<-as.Date(event$date_end,format="%Y-%d-%m")
event$day1<-event$date_start
event$day2<-event$date_end
event[is.na(event$day2)] <- as.Date(Sys.Date(),format="%Y-%d-%m")
event$day_end<-event$date_end-event$day1

## need to subtract SST from Seas and SST from threshhold to do these graphs...
hobday$SST_seas<-hobday$SST-hobday$seas
hobday$SST_thresh<-hobday$SST-hobday$thresh
hobday$day_end<-0

hobday<-data.table(hobday)


img=readPNG(paste0(dir,"/FISHERIES Wide 360px.png"))
rast <- grid::rasterGrob(img, interpolate = T)

if(nrow(event[day2>=max(hobday$day1)-90])>0){

    events<-event[day2>=max(hobday$day1)-90]
    events[day1<max(hobday$day1)-90]$day1 <- max(hobday$day1)-90
    events$day_end<-events$day2-events$day1

	d<-ggplot(data=events,aes(xmin=day1,xmax=day1+day_end,ymin=-3.25,ymax=3.25))
	d<-d+geom_rect(fill = CrustaceanOrange1 , alpha=0.5)
	d<-d+geom_line(data=hobday[day1>=max(hobday$day1)-90],aes(y=SST_seas,x=day1),color="gray35")
}

if(nrow(event[day2>=Sys.Date()-90])==0){
	d<-ggplot()+geom_line(data=hobday[day1>=max(hobday$day1)-90],aes(y=SST_seas,x=day1),color="gray35")
}

d<-d+geom_hline(data=hobday[day1>=max(hobday$day1)-90],aes(yintercept=0),color=OceansBlue1,size=1.25 ,alpha=0.5)+ylim(-3.25,3.25)
d<-d+xlab("Date")+theme_bw(16)
d<-d+scale_x_date(date_breaks = "1 week", date_labels = "%h %d")
d<-d+theme_bw()+theme(axis.text.x = element_text(hjust=1, angle = 90))+
    theme(legend.position=c(0.15,0.95),text=element_text(family='sans'),
        legend.title=element_blank(),
        legend.text=element_text(size=13),
        legend.background = element_blank(),
        axis.text.y = element_text(size=11),
        axis.text.x = element_text(size=11),
        axis.title = element_text(size=13),
        plot.title = element_text(size=15,vjust=-10,hjust=0.5),
        strip.text = element_text(size=13),
        strip.background = element_rect(fill = OceansBlue1),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(size=0.25))+
	theme(axis.title.y=element_blank(),
        axis.text.y=element_blank())
d<-d+labs(subtitle="Previous 90 days")+theme(plot.subtitle=element_text(vjust=-8,hjust=0.5,size=15))
 

d2<-ggplot(data=event,aes(x=day1,xmin=day1,xmax=day1+day_end+5,ymin=-3.25,ymax=3.25))
d2<-d2+geom_rect(fill = CrustaceanOrange1 ,colour = NA, alpha=0.5)
d2<-d2+geom_line(data=hobday[year(day1)>=1981],aes(y=SST_seas,x=day1),size=0.1,color="gray35")+
 	ggtitle(expression(paste("Central Gulf of Alaska (145",degree," W - 160",degree," W longitude)",sep="")))
d2<-d2+geom_line(data=hobday[year(day1)>=1981],aes(y=rollmean(SST_seas, 360, na.pad=TRUE)),color=WavesTeal1,size=1.25)
d2<-d2+geom_hline(data=hobday[year(day1)>=1981],aes(yintercept=0),color=OceansBlue1,size=1.25,alpha=0.5)+ylim(-3.25,3.25)
d2<-d2+ylab(expression(paste(degree,"C from the mean for day of year")))+xlab("Date")+theme_bw(16)
d2<-d2+scale_x_date(breaks = function(x) seq.Date(from = as_date("1982-01-01",format="%Y-%m-%d",tz="PST"), to = as_date("2020-12-01",format="%Y-%m-%d",tz="PST"), by = "2 years"),labels = date_format("%Y"))
d2<-d2+theme_bw()+theme(text=element_text(family='sans'),
  	    legend.position=c(0.15,0.95),
        legend.title=element_blank(),
        legend.text=element_text(size=13),
        legend.background = element_blank(),
        axis.text.y = element_text(size=11),
        axis.text.x = element_text(size=11,hjust=1, angle = 90),
        axis.title = element_text(size=13),
        plot.title = element_text(size=15,vjust=-10,hjust=0),
        strip.text = element_text(size=13),
        strip.background = element_rect(fill = OceansBlue1),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(size=0.25))
d2<-d2+annotation_custom(rast, ymin=1.75, ymax = 3.5,xmax=as.Date("1996-1-1"),xmin=as.Date("1980-6-1"))
d2<-d2+labs(subtitle="1981 - Present")+theme(plot.subtitle=element_text(vjust=-8,hjust=0.6,size=15))
  

d3=ggplot()+theme_void()+theme(text=element_text(family='sans',face='bold',size=8,color=OceansBlue2),plot.subtitle=element_text(vjust=0,hjust=0))+
labs(subtitle = "          Developed by Steven J. Barbeaux, Alaska Fisheries Science Center, E-mail: Steve.Barbeaux@noaa.gov\n          Sea surface temperatures from NOAA High-resolution Blended Analysis Data\n          Central GOA 145 W-160 W longitude <300 M depth and baseline 1982-2012")
d4=ggplot()+theme_void()

png("Heatwave_OISST.png",width=7.5,height=6,units="in",res=300)
ggarrange(d2, d,d3,d4,heights=c(8,1),widths=c(3,1),align = c("h"),
          common.legend = TRUE, legend = "bottom")
dev.off()



## Heatwave Index Calcs (long drawnout defining of periods within the events to calculate indices by year and seasonal cutoffs pertinent to cod...)

events1<-event[,c(5,6,8,9)]
events1$YS<-year(events1$date_start)
events1$YE<-year(events1$date_end)
events1$ME<-month(events1$date_end)
events1$MS<-month(events1$date_start)

events1.1<-events1[YS==YE & MS%in% 1:3 & ME %in% 1:3]



events1.2<-events1[YS==YE & MS%in% 4:9 & ME %in% 4:9]

events1.3<-events1[YS==YE & MS%in% 10:12 & ME %in% 10:12]


eventsYYMM4<-events1[YS==YE & MS%in% 1:3 & ME %in% 4:9]
    eventsYYMM4.1<-data.table(duration=0, date_start=eventsYYMM4$date_start, 
                  date_end=as.Date(paste0(eventsYYMM4$YS,"-03-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM4$intensity_mean,   
                  YS = eventsYYMM4$YS,  
                  YE = eventsYYMM4$YE,
                  ME = 3,
                  MS = eventsYYMM4$MS)
    eventsYYMM4.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM4$YS,"-04-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM4$date_end, 
                  intensity_mean=eventsYYMM4$intensity_mean,   
                  YS = eventsYYMM4$YS,  
                  YE = eventsYYMM4$YE,
                  ME = eventsYYMM4$ME,
                  MS = 4)
    eventsYYMM4<-rbind(eventsYYMM4.1,eventsYYMM4.2)  


eventsYYMM5<-events1[YS==YE & MS %in% 4:9 & ME %in% 10:12]
    eventsYYMM5.1<-data.table(duration=0, date_start=eventsYYMM5$date_start, 
                  date_end=as.Date(paste0(eventsYYMM5$YS,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM5$intensity_mean,   
                  YS = eventsYYMM5$YS,  
                  YE = eventsYYMM5$YS,
                  ME = 9,
                  MS = eventsYYMM5$MS)
    eventsYYMM5.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM5$YS,"-10-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM5$date_end, 
                  intensity_mean=eventsYYMM5$intensity_mean,   
                  YS = eventsYYMM5$YE,  
                  YE = eventsYYMM5$YE,
                  ME = eventsYYMM5$ME,
                  MS = 10)
    eventsYYMM5<-rbind(eventsYYMM5.1,eventsYYMM5.2) 
 

eventsYYMM6<-events1[YE==YS+1 & MS %in% 10:12 & ME %in% 1:3]
    eventsYYMM6.1<-data.table(duration=0, date_start=eventsYYMM6$date_start, 
                  date_end=as.Date(paste0(eventsYYMM6$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM6$intensity_mean,   
                  YS = eventsYYMM6$YS,  
                  YE = eventsYYMM6$YS,
                  ME = 12,
                  MS = eventsYYMM6$MS)
    eventsYYMM6.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM6$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM6$date_end, 
                  intensity_mean=eventsYYMM6$intensity_mean,   
                  YS = eventsYYMM6$YE,  
                  YE = eventsYYMM6$YE,
                  ME = eventsYYMM6$ME,
                  MS = 1)

    eventsYYMM6<-rbind(eventsYYMM6.1,eventsYYMM6.2)

eventsYYMM7<-events1[YE==YS+1 & MS %in% 4:9 & ME %in% 1:3]
if(nrow(eventsYYMM7)>0){
    eventsYYMM7.1<-data.table(duration=0, date_start=eventsYYMM7$date_start, 
                  date_end=as.Date(paste0(eventsYYMM7$YS,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM7$intensity_mean,   
                  YS = eventsYYMM7$YS,  
                  YE = eventsYYMM7$YS,
                  ME = 9,
                  MS = eventsYYMM7$MS)
    eventsYYMM7.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM7$YS,"-10-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM7$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM7$intensity_mean,   
                  YS = eventsYYMM7$YS,  
                  YE = eventsYYMM7$YS,
                  ME = 12,
                  MS = 10)
    eventsYYMM7.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM7$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM7$date_end, 
                  intensity_mean=eventsYYMM7$intensity_mean,   
                  YS = eventsYYMM7$YE,  
                  YE = eventsYYMM7$YE,
                  ME = eventsYYMM7$ME,
                  MS = 1)
    eventsYYMM7<-rbind(eventsYYMM7.1,eventsYYMM7.2,eventsYYMM7.3)
}



eventsYYMM8<-events1[YE==YS+1 & MS %in% 1:3 & ME %in% 1:3]
if(nrow(eventsYYMM8)>0){
    eventsYYMM8.1<-data.table(duration=0, date_start=eventsYYMM8$date_start, 
                  date_end=as.Date(paste0(eventsYYMM8$YS,"-03-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM8$intensity_mean,   
                  YS = eventsYYMM8$YS,  
                  YE = eventsYYMM8$YS,
                  ME = 3,
                  MS = eventsYYMM8$MS)
    eventsYYMM8.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM8$YS,"-04-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM8$YS,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM8$intensity_mean,   
                  YS = eventsYYMM8$YS,  
                  YE = eventsYYMM8$YS,
                  ME = 9,
                  MS = 4)
    eventsYYMM8.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM8$YS,"-10-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM8$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM8$intensity_mean,   
                  YS = eventsYYMM8$YS,  
                  YE = eventsYYMM8$YS,
                  ME = 12,
                  MS = 10)
    eventsYYMM8.4<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM8$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM8$date_end, 
                  intensity_mean=eventsYYMM8$intensity_mean,   
                  YS = eventsYYMM8$YE,  
                  YE = eventsYYMM8$YE,
                  ME = eventsYYMM8$ME,
                  MS = 1)
    eventsYYMM8<-rbind(eventsYYMM8.1,eventsYYMM8.2,eventsYYMM8.3,eventsYYMM8.4)
    }



eventsYYMM12<-events1[YE==YS+1 & MS %in% 10:13 & ME %in% 4:9]
if(nrow(eventsYYMM12)>0){
    
    eventsYYMM12.1<-data.table(duration=0, date_start=eventsYYMM12$date_start, 
                  date_end=as.Date(paste0(eventsYYMM12$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM12$intensity_mean,   
                  YS = eventsYYMM12$YS,  
                  YE = eventsYYMM12$YS,
                  ME = 12,
                  MS = eventsYYMM12$MS)

    eventsYYMM12.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM12$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM12$YE,"-03-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM12$intensity_mean,   
                  YS = eventsYYMM12$YE,  
                  YE = eventsYYMM12$YE,
                  ME = 3,
                  MS = 1)
    
    eventsYYMM12.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM12$YE,"-04-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM12$date_end, 
                  intensity_mean=eventsYYMM12$intensity_mean,   
                  YS = eventsYYMM12$YE,  
                  YE = eventsYYMM12$YE,
                  ME = eventsYYMM12$ME,
                  MS = 4)
    eventsYYMM12<-rbind(eventsYYMM12.1,eventsYYMM12.2,eventsYYMM12.3)
    }





eventsYYMM9<-events1[YE==YS+1 & MS %in% 4:9 & ME %in% 4:9]
if(nrow(eventsYYMM9)>0){
    eventsYYMM9.1<-data.table(duration=0, date_start=eventsYYMM9$date_start, 
                  date_end=as.Date(paste0(eventsYYMM9$YS,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM9$intensity_mean,   
                  YS = eventsYYMM9$YS,  
                  YE = eventsYYMM9$YS,
                  ME = 9,
                  MS = eventsYYMM9$MS)
    eventsYYMM9.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM9$YS,"-10-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM9$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM9$intensity_mean,   
                  YS = eventsYYMM9$YS,  
                  YE = eventsYYMM9$YS,
                  ME = 12,
                  MS = 10)
    eventsYYMM9.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM9$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM9$YE,"-03-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM9$intensity_mean,   
                  YS = eventsYYMM9$YE,  
                  YE = eventsYYMM9$YE,
                  ME = 3,
                  MS = 1)
    eventsYYMM9.4<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM9$YE,"-04-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM9$date_end, 
                  intensity_mean=eventsYYMM9$intensity_mean,   
                  YS = eventsYYMM9$YE,  
                  YE = eventsYYMM9$YE,
                  ME = eventsYYMM9$ME,
                  MS = 4)

    eventsYYMM9<-rbind(eventsYYMM9.1,eventsYYMM9.2,eventsYYMM9.3,eventsYYMM9.4)
    }


eventsYYMM10<-events1[YE==YS+1 & MS %in% 4:9 & ME %in% 10:12]
if(nrow(eventsYYMM10)>0){
    eventsYYMM10.1<-data.table(duration=0, date_start=eventsYYMM10$date_start, 
                  date_end=as.Date(paste0(eventsYYMM10$YS,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM10$intensity_mean,   
                  YS = eventsYYMM10$YS,  
                  YE = eventsYYMM10$YS,
                  ME = 10,
                  MS = eventsYYMM10$MS)
    eventsYYMM10.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM10$YS,"-10-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM10$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM10$intensity_mean,   
                  YS = eventsYYMM10$YS,  
                  YE = eventsYYMM10$YS,
                  ME = 12,
                  MS = 10)
    eventsYYMM10.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM10$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM10$YE,"-03-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM10$intensity_mean,   
                  YS = eventsYYMM10$YE,  
                  YE = eventsYYMM10$YE,
                  ME = 3,
                  MS = 1)
    eventsYYMM10.4<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM10$YE,"-04-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM10$YE,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM10$intensity_mean,   
                  YS = eventsYYMM10$YE,  
                  YE = eventsYYMM10$YE,
                  ME = 9,
                  MS = 4)
    eventsYYMM10.5<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM10$YE,"-10-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM10$date_end, 
                  intensity_mean=eventsYYMM10$intensity_mean,   
                  YS = eventsYYMM10$YE,  
                  YE = eventsYYMM10$YE,
                  ME = eventsYYMM10$ME,
                  MS = 10)

    eventsYYMM10<-rbind(eventsYYMM10.1,eventsYYMM10.2,eventsYYMM10.3,eventsYYMM10.4)
    }

eventsYYMM11<-events1[YE==YS+2 & MS %in% 10:12 & ME %in% 1:3]
    eventsYYMM11.1<-data.table(duration=0, date_start=eventsYYMM11$date_start, 
                  date_end=as.Date(paste0(eventsYYMM11$YS,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM11$intensity_mean,   
                  YS = eventsYYMM11$YS,  
                  YE = eventsYYMM11$YS,
                  ME = 12,
                  MS = eventsYYMM11$MS)
    eventsYYMM11.2<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM11$YS+1,"-01-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM11$YS+1,"-03-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM11$intensity_mean,   
                  YS = eventsYYMM11$YS+1,  
                  YE = eventsYYMM11$YS+1,
                  ME = 3,
                  MS = 1)
    eventsYYMM11.3<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM11$YS+1,"-04-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM11$YS+1,"-09-30"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM11$intensity_mean,   
                  YS = eventsYYMM11$YS+1,  
                  YE = eventsYYMM11$YS+1,
                  ME = 9,
                  MS = 4)
    eventsYYMM11.4<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM11$YS+1,"-10-01"),format="%Y-%m-%d"), 
                  date_end=as.Date(paste0(eventsYYMM11$YS+1,"-12-31"),format="%Y-%m-%d"), 
                  intensity_mean=eventsYYMM11$intensity_mean,   
                  YS = eventsYYMM11$YS+1,  
                  YE = eventsYYMM11$YS+1,
                  ME = 12,
                  MS = 10)
    eventsYYMM11.5<-data.table(duration=0, date_start=as.Date(paste0(eventsYYMM11$YE,"-01-01"),format="%Y-%m-%d"), 
                  date_end=eventsYYMM11$date_end, 
                  intensity_mean=eventsYYMM11$intensity_mean,   
                  YS = eventsYYMM11$YE,  
                  YE = eventsYYMM11$YE,
                  ME = eventsYYMM11$ME,
                  MS = 1)
eventsYYMM11<-rbind(eventsYYMM11.1,eventsYYMM11.2,eventsYYMM11.3,eventsYYMM11.4,eventsYYMM11.5)

events2<-rbind(eventsYYMM4,eventsYYMM5,eventsYYMM6,eventsYYMM7,eventsYYMM8,eventsYYMM9,eventsYYMM10,eventsYYMM11,eventsYYMM12)


events2$SEASON="Winter"
events2[MS%in%c(4:9)]$SEASON="Summer"
events2$duration=as.numeric(1+(events2$date_end-events2$date_start))
events2$Intensity_Total=events2$duration*events2$intensity_mean
events2$Intensity_Winter=0
events2$Intensity_Summer=0
events2[SEASON=='Winter']$Intensity_Winter=events2[SEASON=='Winter']$Intensity_Total
events2[SEASON=='Summer']$Intensity_Summer=events2[SEASON=='Summer']$Intensity_Total

events3<-events1[YS==YE]

events3<-data.table(duration=0, date_start=events3$date_start, 
                  date_end=events3$date_end, 
                  intensity_mean=events3$intensity_mean,   
                  YS = events3$YS,  
                  YE = events3$YE,
                  ME = events3$ME,
                  MS = events3$MS)


events3$SEASON="Winter"
events3$Intensity_Total=0
events3$Intensity_Summer=0
events3$Intensity_Winter=0
events3$duration=as.numeric(1+(events3$date_end-events3$date_start))
events3$Intensity_Total=events3$duration*events3$intensity_mean


eventsYYMM1<-events3[MS %in% 1:3 & ME%in% 1:3]
eventsYYMM1$Intensity_Winter=eventsYYMM1$Intensity_Total

eventsYYMM2<-events3[MS %in% 10:12 & ME %in% 10:12]
eventsYYMM2$Intensity_Winter=eventsYYMM2$Intensity_Total

eventsYYMM3<-events3[MS %in% 4:9 & ME %in% 4:9]
eventsYYMM3$SEASON="Summer"
eventsYYMM3$Intensity_Summer=eventsYYMM3$Intensity_Total

events3<-rbind(eventsYYMM1,eventsYYMM2,eventsYYMM3)


events4<-rbind(events2,events3)

##Leap_year_correction
events4[year(date_start)==2016&duration==90]$duration=91
events4[year(date_start)==2016&duration==90]$Intensity_Total=91*1.7284
events4[year(date_start)==2016&duration==90]$Intensity_Winter=91*1.7284

events4$Intensity_CodRec<-0
events4[ME%in%c(2:3)]$Intensity_CodRec<-events4[ME%in%c(2:3)]$Intensity_Total

MHWI<-events4[,list(Annual=sum(Intensity_Total),Summer=sum(Intensity_Summer),Winter=sum(Intensity_Winter),Spawning=sum(Intensity_CodRec)),by="YS"]
names(MHWI)[1]<-"Year"
x<-data.table(Year=c(1982:2021))
MHWI=merge(MHWI,x,all.y=T)
MHWI[is.na(Winter)]$Winter<-0
MHWI[is.na(Summer)]$Summer<-0
MHWI[is.na(Annual)]$Annual<-0
MHWI[is.na(Spawning)]$Spawning<-0
write.csv(MHWI,"MHWI.csv",row.names=F)

Event_1<-melt(MHWI,c('Year'))
names(Event_1)<-c("Year","Season","Intensity")

## Lolipop graph of indices

d<-ggplot(data=Event_1[!Season%in%c("Summer")],aes(x=Year,y=Intensity,color=Season,size=Season))+scale_color_manual(values=c("salmon","blue","dark green"))
d<-d+geom_point()+scale_size_manual(values=c(4,2.5,1.75))
d<-d+geom_segment(data=Event_1[Season=="Annual"],aes(yend = 0, xend = Year),color="orange",size=1.5)
d<-d+geom_segment(data=Event_1[Season=="Winter"],aes(yend = 0, xend = Year),color="black",size=0.25)
d<-d+geom_point(data=Event_1[Season=="Total"],size=4,color="salmon")
d<-d+geom_point(data=Event_1[Season=="Winter"],size=2.5,color="blue")
d<-d+geom_point(data=Event_1[Season=="Spawning"],size=1.75,color="dark green")
d<-d+ylab(expression(paste(degree,"C days",sep="")))+xlab("Year")+theme_bw(base_size=20)
windows()
print(d)


#d<-ggplot(data=Event_1[!Season%in%c("Summer","Spawning")],aes(x=Year,y=Intensity,color=Season,size=Season))+scale_color_manual(values=c("salmon","blue"))
#d<-d+geom_point()+scale_size_manual(values=c(4,2.5))
#d<-d+geom_segment(data=Event_1[Season=="Annual"],aes(yend = 0, xend = Year),color="orange",size=1.5)
#d<-d+geom_segment(data=Event_1[Season=="Winter"],aes(yend = 0, xend = Year),color="black",size=0.25)
#d<-d+geom_point(data=Event_1[Season=="Annual"],size=4,color="salmon")
#d<-d+geom_point(data=Event_1[Season=="Winter"],size=2.5,color="blue")
#d<-d+geom_point(data=Event_1[Season=="Spawning"],size=1.75,color="dark green")
#d<-d+ylab(expression(paste(degree,"C days",sep="")))+xlab("Year")+theme_bw(base_size=20)
#d

## Auxilary graphs on daily temp by year for different seasons
hobday$YEAR=year(hobday$day1)
hobday$MONTH=month(hobday$day1)

x<-hobday[MONTH%in% c(1:5)&YEAR%in%c(1982:2012)][,list(MEANSST=mean(SST)),by="doy"]
dsp<-ggplot(hobday[MONTH%in%c(1:5)],aes(x=doy,y=SST,group=YEAR))+geom_line(color='gray80',size=0.5)+theme_bw(base_size=18)+geom_line(data=x,aes(x=doy,y=MEANSST,group=NA),color="gray50",size=1.25,linetype=2)
dsp<-dsp+geom_hline(yintercept=5,color="black",linetype=3)+geom_line(data=hobday[MONTH%in%c(1:5)&YEAR==2021],size=1.25)+geom_line(data=hobday[MONTH%in%c(1:5)&YEAR>2014],aes(color=factor(YEAR)),size=1)
dsp<-dsp+labs(y=expression('Sea surface temperature ('~degree*C~")"),x="Day of the year",color='Year', title="January through May 1981-2021")
#dsp<-dsp+geom_line(data=hobday[MONTH%in%c(1:4)&YEAR==2003],color="gray50",size=1)
windows()

xsu<-hobday[MONTH%in% c(6:9)&YEAR%in%c(1982:2012)][,list(MEANSST=mean(SST)),by="doy"]
dsu<-ggplot(hobday[MONTH%in%c(6:9)],aes(x=doy,y=SST,group=YEAR))+geom_line(color='gray80',size=0.5)+theme_bw(base_size=18)+geom_line(data=xsu,aes(x=doy,y=MEANSST,group=NA),color="gray50",size=1.25,linetype=2)
dsu<-dsu+geom_hline(yintercept=5,color="black",linetype=2)+geom_line(data=hobday[MONTH%in%c(6:9)&YEAR==2021],size=1.25)+geom_line(data=hobday[MONTH%in%c(6:9)&YEAR>2014],aes(color=factor(YEAR)),size=1)
dsu<-dsu+labs(y=expression('Sea surface temperature ('~degree*C~")"),x="Day of the year",color='Year', title="June through September 1981-2020")


xfa<-hobday[MONTH%in% c(10:12)&YEAR%in%c(1982:2012)][,list(MEANSST=mean(SST)),by="doy"]
dfa<-ggplot(hobday[MONTH%in%c(10:12)],aes(x=doy,y=SST,group=YEAR))+geom_line(color='gray80',size=0.5)+theme_bw(base_size=18)+geom_line(data=xfa,aes(x=doy,y=MEANSST,group=NA),color="gray50",size=1.25,linetype=2)
dfa<-dfa+geom_hline(yintercept=5,color="black",linetype=2)+geom_line(data=hobday[MONTH%in%c(10:12)&YEAR==2021],size=1.25)+geom_line(data=hobday[MONTH%in%c(10:12)&YEAR>2014],aes(color=factor(YEAR)),size=1)
dfa<-dfa+labs(y=expression('Sea surface temperature ('~degree*C~")"),x="Day of the year",color='Year', title="October through December 1981-2020")

ggarrange(dsp,dsu,dfa,heights=c(1,1),widths=c(1,1),align = c("h"),
          common.legend = TRUE, legend = "bottom")