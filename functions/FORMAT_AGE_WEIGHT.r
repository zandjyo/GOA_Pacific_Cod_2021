# function for SBSS - generating SS DAT files
# ZTA, 2013-09-23
# See SS_User_Manual_3.24q.pdf, PDF page 52, section 9.3.12 Empirical Weight-at-age

FORMAT_AGE_WEIGHT <- function(data=AGE_WEIGHT,seas=1,gender=3,growpattern=1,birthseas=1,flt=-1)
{
    years <- sort(unique(data$YEAR))
    bins  <- sort(unique(data$Age))

    nbins <- length(bins) + 1   # extra column for age-0
    nyrs  <- length(years)

    const.cols <- 6
    data.col.start <- const.cols + 1    # start at age-0 column

    # one line for each year and sex;
    # this assumes that there are data for each sex for each year
    x     <- matrix(ncol=(const.cols + nbins),nrow=4*nyrs)

    x[,2] <- seas
#     x[,3] <- gender
    x[,4] <- growpattern
    x[,5] <- birthseas
    x[,6] <- flt

    x[,7] <- 0.0    # age-0

    for(i in 1:nyrs)
    {
        # output the calculated mean weight-at-age values for FEMALES
        x[i,1] <- years[i]
        x[i,3] <- 1
        x[i,(data.col.start+1):(nbins+const.cols)] <- data$Females[data$YEAR==years[i]]

        # output the calculated mean weight-at-age values for MALES
        j <- nyrs + i
        x[j,1] <- years[i]
        x[j,3] <- 2
        x[j,(data.col.start+1):(nbins+const.cols)] <- data$Males[data$YEAR==years[i]]

        # output the number of samples used for the mean for FEMALES
        k <- nyrs + j
        x[k,1] <- -years[i]
        x[k,3] <- 1
        x[k,(data.col.start+1):(nbins+const.cols)] <- data$Female_Sample[data$YEAR==years[i]]

        # output the number of samples used for the mean for MALES
        m <- nyrs + k
        x[m,1] <- -years[i]
        x[m,3] <- 2
        x[m,(data.col.start+1):(nbins+const.cols)] <- data$Male_Sample[data$YEAR==years[i]]

    }

    x
}
