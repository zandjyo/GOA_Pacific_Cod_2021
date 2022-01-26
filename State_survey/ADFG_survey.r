
dglm = dget("delta_glm_1-7-2.get")
data<-read.csv("1988to2021pcodcatch.csv")
data<-data.table(data)
data<-data[district%in%c(1,2,6)]
data<-data[!is.na(avg_depth_fm)&!is.na(start_longitude)]

data$depth<-1
data$depth[data$avg_depth_fm>30]<-2
data$depth[data$avg_depth_fm>70]<-3

data$density<-data$total_weight_kg/data$area_km2


mydata<-data.frame(Density=data$total_weight_kg/data$area_km2,year=data$year,district=data$district,depth=data$depth)
codout = dglm(mydata,dist="gamma",write=T,J=T)
codout2 = dglm(mydata,dist="lognormal",write=T,J=T)



index<-data.table(codout$deltaGLM.index)
index$year<-1988:2021


index2<-data.table(codout2$deltaGLM.index)
index2$year<-1988:2021
 

 d<-ggplot(index,aes(x=factor(year),y=index))
 d<-d+geom_point()+geom_line()+ylim(0,4.5)
 d<-d+geom_errorbar(aes(ymin=index-jack.se,ymax=index+jack.se))
 d<-d+theme_bw(base_size=20)+ggtitle("ADFG trawl survey")+ylab("ADFG trawl survey index")+xlab("Year")+theme(axis.text.x = element_text(hjust=1, angle = 90))
 print(d)


index2$ID<-1:nrow(index2)
 d<-ggplot(index2,aes(x=factor(year),y=index))
 d<-d+ylim(0,4.5)+geom_errorbar(aes(ymin=index-jack.se,ymax=index+jack.se))+geom_path(aes(group=""),color="gray50")+geom_point(color="red",size=2.5)
 d<-d+theme_bw(base_size=20)+ggtitle("ADFG trawl survey Pacific cod delta-glm density index")+ylab(expression(paste("Density index (kg/k",m^2,")",sep="")))+xlab("Year")+theme(axis.text.x = element_text(hjust=1, angle = 90))
 print(d)


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

p <- ggplot(data=length, aes(x=factor(year), y=length, weight=tot_fish,color=factor(year),fill=factor(year))) + geom_violin(trim=F) + geom_boxplot(width=0.1,color='black') + theme_bw()
p


p<- ggplot(length, aes(length, factor(year), fill=factor(year),height = tot_fish)) + 
   theme_ridges(font_size = 20) +
   geom_density_ridges(stat='identity')
p<-p+labs(x="Length (cm)",y="Year",fill='Year',title="ADFG trawl survey abundance of Pacific cod by length" )+ theme(legend.position = "none")


col.pal = colorRampPalette(c("blue","cyan","green","yellow","red"))


data$pres<-0
data$pres[data$total_weight_kg>0]<-1

data2<-data#[year>2011&year<2014]
data3<-data2[pres==0]

bering<-get_map(location=c(lon=-158,lat=56),zoom=6,maptype="toner", color="bw")
k<-ggmap(bering)
k <- k + geom_point(data=data2,aes(x=start_longitude,y=start_latitude,color=log(density)), size=0.1)
k<-k+ylab(expression(paste("Latitude ",degree,"N")))+xlab(paste("Longitude"))

k<-k+scale_colour_gradient(name=expression(paste("Log density (kg/k",m^2,")",sep="")),low = "yellow", high = "red", na.value = "light blue" )
#k<- k+scale_colour_manual(name="Presence/absence",labels=c("Cod not present","Cod present"),values=c("blue","red"))
k<-k+ggtitle("ADFG trawl survey 1988-2017")
k<-k+facet_wrap(~year, ncol=12)
k

    


bering<-get_map(location=c(lon=-158,lat=56),zoom=6,maptype="toner", color="bw")
k<-ggmap(bering)
k <- k + geom_point(data=data2,aes(x=start_longitude,y=start_latitude),color="red", size=0.25)
k<-k+ylab(expression(paste("Latitude ",degree,"N")))+xlab(paste("Longitude"))

#k<-k+scale_colour_gradient(name=expression(paste("Log density (kg/k",m^2,")",sep="")),low = "yellow", high = "red", na.value = "light blue" )
#k<- k+scale_colour_manual(name="Presence/absence",labels=c("Cod not present","Cod present"),values=c("blue","red"))
k<-k+ggtitle("ADFG trawl survey 1988-2017")
k<-k+facet_wrap(~year, ncol=8)
k
  



      theme1=function (base_size = 10, base_family = "serif") 
{
  half_line <- base_size/2
  theme(line = element_line(colour = "black", size = 0.5, linetype = 1, lineend = "butt"), 
        rect = element_rect(fill = "white", colour = "black", size = 0.5, linetype = 1), 
        text = element_text(family = base_family , face = "plain", colour = "black", size = base_size, lineheight = 0.9, hjust = 0.5, vjust = 0.5, angle = 0, margin = margin(), debug = FALSE), 
        axis.line = element_blank(), 
        axis.line.x = NULL, 
        axis.line.y = NULL, 
        axis.text = element_text(size = rel(0.5), colour = "grey30"), 
        axis.text.x = element_text(margin = margin(t = 0.8 * half_line/2), vjust = 1), 
        axis.text.x.top = element_text(margin = margin(b = 0.8 * half_line/2), vjust = 0), 
        axis.text.y = element_text(margin = margin(r = 0.8 * half_line/2), hjust = 1), 
        axis.text.y.right = element_text(margin = margin(l = 0.8 * half_line/2), hjust = 0), 
        axis.ticks.length = unit(half_line/2, "pt"), 
        axis.title = element_text(size=rel(0.75)),
        axis.title.x = element_text(margin = margin(t = half_line), vjust = 1), 
        axis.title.x.top = element_text(margin = margin(b = half_line),vjust = 0), 
        axis.title.y = element_text(angle = 90, margin = margin(r = half_line), vjust = 1), 
        axis.title.y.right = element_text(angle = -90, margin = margin(l = half_line), vjust = 0), 
        axis.ticks = element_blank(), 
        
        legend.background = element_blank(), 
        legend.key = element_blank(),
        legend.spacing = unit(0.2, "cm"), 
        legend.spacing.x = NULL, 
        legend.spacing.y = NULL, 
        legend.margin = margin(0.1, 0.1, 0.1, 0.1, "cm"), 
        legend.key.size = unit(0.75, "lines"), 
        legend.key.height = unit(0.75, "lines"), 
        legend.key.width = NULL, 
        legend.text = element_text(size = rel(0.5)), 
        legend.text.align = NULL, 
        legend.title = element_text(hjust = 0.2,size=rel(0.75)), 
        legend.title.align = NULL, 
        legend.position = "right", 
        legend.direction = NULL, 
        legend.justification = "center", 
        legend.box = NULL, 
        legend.box.margin = margin(0, 0, 0, 0, "cm"), 
        legend.box.background = element_blank(), 
        legend.box.spacing = unit(0.2, "cm"), 
        
        panel.background = element_blank(), 
        panel.border = element_blank(), 
        panel.grid.major = element_line(colour = "grey95",size=0.1), 
        panel.grid.minor = element_line(colour = "grey95", size = 0.01), 
        panel.spacing = unit(0,"null"), 
        panel.spacing.x = NULL, 
        panel.spacing.y = NULL, 
        panel.ontop = FALSE, 
        
        strip.background = element_blank(), 
        strip.text = element_text(colour = "grey10", size = rel(0.75)), 
        strip.text.x = element_text(margin = margin(t = half_line, b = half_line)), 
        strip.text.y = element_text(angle = -90, margin = margin(l = half_line, r = half_line)), 
        strip.placement = "inside", 
        strip.placement.x = NULL, 
        strip.placement.y = NULL, 
        strip.switch.pad.grid = unit(0.03, "cm"), 
        strip.switch.pad.wrap = unit(0.08, "cm"), 
        
        plot.title = element_text(size = rel(0.9), hjust = 0, vjust = 1, margin = margin(b = half_line * 0.75)), 
        plot.subtitle = element_text(size = rel(0.5), hjust = 0, vjust = 1, margin = margin(b = half_line * 0.5)), 
        plot.caption = element_text(size = 12, hjust = 0, vjust = 1, margin=unit(c(0,0,0,0),"inches")), 
        plot.margin = unit(c(0, 0, 0.2,0.1),"inches"),
        plot.background = element_blank(), 
        complete = TRUE)
}



DYNB1<-function(i=1){
	require(ggpubr)
	DYNB<-data.table(Mods[[i]][101][[1]]) 
	DYNB<-DYNB[Yr>1976 & Yr<2018]
	DYNB$Prop<-DYNB$SPB/DYNB$SPB_nofishing
	x<-melt(DYNB,id=c("Yr","Era"))
	d<-ggplot(x[variable!="Prop"],aes(x=Yr,y=value/2,color=variable))
	d<-d+geom_line(size=1.5)
	d<-d+ylim(c(0,max(x$value/2)))
	d<-d+theme1(base_size=20)
	d<-d+ylab("Female spawning biomass (t)")+xlab("Year")+guides(color=guide_legend(title=""))
	d<-d+ggtitle(mods[i])

	b<-ggplot(x[variable=="Prop"],aes(x=Yr,y=value))
	b<-b+geom_line(size=1.5,color="black")
	b<-b+ylim(c(0,1))
	b<-b+theme1(base_size=20)
	b<-b+ylab("SSB/SSB no fishing")+xlab("Year")

 	ggarrange(d, b,ncol=1,nrow=2)
 }



 mean((as.numeric(x[Fleet==4&Yr==1996][,15:85])* exp(4.66905e-01)))