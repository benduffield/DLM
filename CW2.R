# Load the data
library(dlm)
load('mocdata.RData')

# Now take quarterly means (the dlm code does not work for the whole dataset - too many points)

rapid$Quarter<-floor(rapid$MM/4)+1
rapid$qyyyy <- paste(rapid$YY,rapid$Quarter, sep='-')
rapid$yyyymm = paste(rapid$MM, rapid$YY, sep = "-")
rapidmean <- tapply(rapid$moc,rapid$yyyymm,mean)

# Now convert it to a time series object. This is the data you should work with

rapidmeanlim.ts <- ts(as.vector(rapidmean),start=c(2017,4),end = c(2021,4),frequency = 4)
rapidmean.ts <- ts(as.vector(rapidmean),start=c(2017,2),frequency = 4)
plot(rapidmean.ts)
abline(v = c(2018,2019,2020,2021,2022), lty = 3)

#----------------------------------------------
#MAKE MODEL TEMPLATE
#----------------------------------------------

build_function = function(x){
  dlmMOC = dlmModPoly(3) + dlmModSeas(7)
  V(dlmMOC) = exp(x[1])
  diag(W(dlmMOC))[3:9] = exp(x[1:7])
  return(dlmMOC)
}

#----------------------------------------------
#MLE TO ESTIMATE PARAMS
#----------------------------------------------

fit = dlmMLE(rapidmeantest.ts, parm = c(rep(0,10)), build = build_function)
fit$conv
dlmMOC = build_function(fit$par)
drop(V(dlmMOC))
fit$par

#----------------------------------------------
#SMOOTHING STATE ESTIMATES
#----------------------------------------------

MOCSmooth <- dlmSmooth(rapidmeanlim.ts, mod = dlmMOC)
x <- cbind(rapidmean.ts, dropFirst(MOCSmooth$s[,c(1,3,7)]))
colnames(x) <- c("MOC", "Trend1", "Trend2", "Trend 3")
plot(x,type = "o", cex=3, main = "MOC data")

#----------------------------------------------
#FORECASTING
#----------------------------------------------

MOCfilter <- dlmFilter(rapidmeanlim.ts,mod=dlmMOC)
MOCforecast <- dlmForecast(MOCfilter, nAhead=20)

sqrtR <- sapply(MOCforecast$R, function(x) sqrt(x[1,1]))

pl <- MOCforecast$a[,1] + qnorm(0.05, sd = sqrtR)
pu <- MOCforecast$a[,1] + qnorm(0.95, sd = sqrtR)

xf <- ts.union(rapidmean.ts, 
              window(MOCSmooth$s[,1], start=c(2017,2)),
              MOCforecast$a[,1], pl, pu,
              MOCforecast$f[,1]) 

plot(xf, plot.type = "single", type = 'o', pch = c(1, 0, 0, 3, 3, 1),
     col = c("darkgrey", "darkgrey", "brown", "forestgreen", "forestgreen", "black"),
     ylab = "MOC")
abline(v = c(2018,2019,2020,2021,2022,2023), lty = 3)

#----------------------------------------------
#DIAGNOSTICS
#----------------------------------------------

residuals <- residuals(MOCfilter, sd = F)
hist(residuals)
acf(residuals)
qqnorm(residuals)
abline(0,1)

