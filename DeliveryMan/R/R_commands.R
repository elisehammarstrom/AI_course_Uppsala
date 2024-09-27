source("DM.R")
result <- runDeliveryMan(carReady = deliveryManAlgorithm, dim = 10, turns = 2000, doPlot = TRUE, pause = 0.1, del = 5, verbose = TRUE)

testDM(deliveryManAlgorithm, verbose=1, n=500)


result <- testDM(deliveryManAlgorithm, verbose=2, n=50)

source("DM.R")