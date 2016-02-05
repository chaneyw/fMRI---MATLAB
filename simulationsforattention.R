x <- rnorm(1000)
z <- rnorm(1000)
y <- x*.2 + sqrt(1-.2^2)*z

z1 <- 10*x + 10*y + rnorm(1000,0,20)
z2 <- 10*x + 10*y + rnorm(1000,0,20)
z3 <- 10*x + 10*y + rnorm(1000,0,100)
z4 <- 10*x + 10*y + rnorm(1000,0,100)
linmod1 <- lm(z1~x)
linmod2 <- lm(z2~x)
linmod3 <- lm(z3~x)
linmod4 <- lm(z4~x)
pred1 <- predict(linmod1)
pred2 <- predict(linmod2)
pred3 <- predict(linmod3)
pred4 <- predict(linmod4)
resid1 <- z1 - pred1
resid2 <- z2 - pred2
resid3 <- z3 - pred3
resid4 <- z4 - pred4
cor(resid1,resid2)
cor(resid3,resid4)


list1 <- list()
list2 <- list()
for (i in 1:1000){
  x <- rnorm(1000)
  z <- rnorm(1000)
  y <- x*.2 + sqrt(1-.2^2)*z
  
  noise1 <- rnorm(1000)
  temp <- rnorm(1000)
  noise2 <- .2*noise1 + sqrt(1-.2^2)*temp
  
  noise3 <- rnorm(1000)
  temp <- rnorm(1000)
  noise4 <- .2*noise3 + sqrt(1-.2^2)*temp
  
  z1 <- 20*x + 20*y + noise1*sqrt(20)
  z2 <- 20*x + 20*y + noise2*sqrt(20)
  z3 <- 10*x + 10*y + noise3*sqrt(50)
  z4 <- 10*x + 10*y + noise4*sqrt(50)
  linmod1 <- lm(z1~x)
  linmod2 <- lm(z2~x)
  linmod3 <- lm(z3~x)
  linmod4 <- lm(z4~x)
  pred1 <- predict(linmod1)
  pred2 <- predict(linmod2)
  pred3 <- predict(linmod3)
  pred4 <- predict(linmod4)
  resid1 <- z1 - pred1
  resid2 <- z2 - pred2
  resid3 <- z3 - pred3
  resid4 <- z4 - pred4
  list1[i]<-cor(resid1,resid2)
  list2[i]<-cor(resid3,resid4)
}

mean(as.numeric(list1))-mean(as.numeric(list2))

p1 <- hist(as.numeric(list1))
p2 <- hist(as.numeric(list2))
plot( p1, col=rgb(0,0,1,1/4),xlim=c(0,1))
plot( p2, col=rgb(1,0,0,1/4),xlim=c(0,1), add=T)

#more code, this creates autocorrelated time series this is just testing things, seem to have created correlated time series with autocorrelation
sim.ar<-arima.sim(list(ar=c(0.2)),n=1000)
test <- acf(sim.ar,plot=FALSE)

x <- arima.sim(list(ar=c(0.2)),n=1000)
z <- arima.sim(list(ar=c(0.2)),n=1000)
y <- y <- x*.2 + sqrt(1-.2^2)*z
cor(x,y)
test <- acf(y,plot=FALSE)
test

#this is the simulation from above where the error terms have autocorrelation
list1 <- list()
list2 <- list()
for (i in 1:1000){
  x <- rnorm(1000)
  z <- rnorm(1000)
  y <- x*.2 + sqrt(1-.2^2)*z
  
  noise1 <- arima.sim(list(ar=c(0.2)),n=1000)
  temp <- arima.sim(list(ar=c(0.2)),n=1000)
  noise2 <- .2*noise1 + sqrt(1-.2^2)*temp
  
  noise3 <- arima.sim(list(ar=c(0.2)),n=1000)
  temp <- arima.sim(list(ar=c(0.2)),n=1000)
  noise4 <- .2*noise3 + sqrt(1-.2^2)*temp
  
  z1 <- 20*x + 20*y + noise1*sqrt(20)
  z2 <- 20*x + 20*y + noise2*sqrt(20)
  z3 <- 10*x + 10*y + noise3*sqrt(50)
  z4 <- 10*x + 10*y + noise4*sqrt(50)
  linmod1 <- lm(z1~x)
  linmod2 <- lm(z2~x)
  linmod3 <- lm(z3~x)
  linmod4 <- lm(z4~x)
  pred1 <- predict(linmod1)
  pred2 <- predict(linmod2)
  pred3 <- predict(linmod3)
  pred4 <- predict(linmod4)
  resid1 <- z1 - pred1
  resid2 <- z2 - pred2
  resid3 <- z3 - pred3
  resid4 <- z4 - pred4
  list1[i]<-cor(resid1,resid2)
  list2[i]<-cor(resid3,resid4)
}

mean(as.numeric(list1))-mean(as.numeric(list2))

#bootstrap to see if my method work -- close enough
autocorrelations <- rep(0,1000)
for (i in 1:1000){
  x <- arima.sim(list(ar=c(0.2)),n=1000)
  z <- arima.sim(list(ar=c(0.2)),n=1000)
  y <- y <- x*.2 + sqrt(1-.2^2)*z
  test <- acf(y,plot=FALSE)
  autocorrelations[i]<-test[[1]][2]
}

mean(autocorrelations)

#testing whether increased correlation of error terms leads to increased correlation of residuals

list1 <- list()
list2 <- list()
for (i in 1:1000){
  x <- rnorm(1000)
  z <- rnorm(1000)
  y <- x*.2 + sqrt(1-.2^2)*z
  
  noise1 <- rnorm(1000)
  temp <- rnorm(1000)
  noise2 <- .2*noise1 + sqrt(1-.2^2)*temp
  
  noise3 <- rnorm(1000)
  temp <- rnorm(1000)
  noise4 <- .2*noise3 + sqrt(1-.2^2)*temp
  
  #z1 <- 20*x + 20*y + noise1*sqrt(5)
  #z2 <- 20*x + 20*y + noise2*sqrt(5)
  #z3 <- 20*x + 20*y + noise3*sqrt(5)
  #z4 <- 20*x + 20*y + noise4*sqrt(5)
  
  z1 <- 20*x + noise1*sqrt(5)
  z2 <- 20*x + noise2*sqrt(5)
  z3 <- 100*x + noise3*sqrt(25)
  z4 <- 100*x + noise4*sqrt(25)
  
  linmod1 <- lm(z1~x)
  linmod2 <- lm(z2~x)
  linmod3 <- lm(z3~x)
  linmod4 <- lm(z4~x)
  pred1 <- predict(linmod1)
  pred2 <- predict(linmod2)
  pred3 <- predict(linmod3)
  pred4 <- predict(linmod4)
  resid1 <- z1 - pred1
  resid2 <- z2 - pred2
  resid3 <- z3 - pred3
  resid4 <- z4 - pred4
  list1[i]<-cor(resid1,resid2)
  list2[i]<-cor(resid3,resid4)
}

mean(as.numeric(list1))-mean(as.numeric(list2))