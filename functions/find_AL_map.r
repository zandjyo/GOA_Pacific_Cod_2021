

find_AL<-function(Adata,Ldata,year){
  require(FSA)
  require(NCStats)
  Adata$AGE1<-Adata$AGE
  Adata$AGE1[Adata$AGE>20] <- 20
  rb.age1<-subset(Adata,Adata$YEAR==year&Adata$SEX==1)
  rb.age2<-subset(Adata,Adata$YEAR==year&Adata$SEX==2)
  rb.len1<-subset(Ldata,Ldata$YEAR==year&Ldata$SEX==1)
  rb.len2<-subset(Ldata,Ldata$YEAR==year&Ldata$SEX==2)

  rb.age1<-data.frame(age=rb.age1$AGE1,tl=rb.age1$LENGTH)
  rb.age2<-data.frame(age=rb.age2$AGE1,tl=rb.age2$LENGTH)
  
  rb.len1<-aggregate(list(FREQ=rb.len1$FREQUENCY),by=list(LENGTH=rb.len1$LENGTH),FUN=sum)
  rb.len2<-aggregate(list(FREQ=rb.len2$FREQUENCY),by=list(LENGTH=rb.len2$LENGTH),FUN=sum)


  expand.length<-function(data){
     x<-rep(data$LENGTH[1],data$FREQ[1])
  for( i  in 2:nrow(data)){
      x1<-rep(data$LENGTH[i],data$FREQ[i])
      x<-c(x,x1)
      }
      y<-data.frame(age=NA,tl=x)
      y
  }

  rb.len1<-expand.length(rb.len1)
  rb.len2<-expand.length(rb.len2)

  rb.age1=rbind(rb.age1,expand.grid(age=1,tl=c(min(rb.len1$tl),(min(rb.age1$tl)-1))))
  rb.age2=rbind(rb.age2,expand.grid(age=1,tl=c(min(rb.len2$tl),(min(rb.age2$tl)-1))))



  rb.age1.1<-lencat(~tl,rb.age1,startcat=10,w=10)
  rb.age2.1<-lencat(~tl,rb.age2,startcat=10,w=10)


  rb.raw1 <- table(rb.age1.1$LCat,rb.age1.1$age)
  rb.key1 <- prop.table(rb.raw1,margin=1)
  rb.raw2 <- table(rb.age2.1$LCat,rb.age2.1$age)
  rb.key2 <- prop.table(rb.raw2,margin=1)

  
  
  rb.len1.1 <- ageKey(rb.key1,formula=age~LENGTH,data=subset(Ldata,Ldata$SEX==1&Ldata$YEAR==year),type="SR")
 # rb.len1.1 <- ageKey(rb.key1,formula=age~length,data=Ldata,type="SR")
 # rb.len1.1 <- ageKey(rb.key1,formulat=~tl,ca="age",dl=rb.len1,type="SR")
  rb.len2.1 <- ageKey(rb.key2,formula=age~LENGTH,data=subset(Ldata,Ldata$SEX==2&Ldata$YEAR==year),type="SR")
 # rb.len2.1 <- ageKey(rb.key2,formula=age~tl,data=rb.len2,type="SR")
 # rb.len2.1 <- ageKey(rb.key2,cl="tl",ca="age",dl=rb.len2,type="SR")
  
  AL<-rbind(rb.len1.1,rb.len2.1)
  AL
}