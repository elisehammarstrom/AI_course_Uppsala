#' dumbDM
#'
#' This control function just moves randomly, until all packages are picked up and delivered by accident!
#' @param roads See help documentation for the runDeliveryMan function
#' @param cars See help documentation for the runDeliveryMan function
#' @param packages See help documentation for the runDeliveryMan function
#' @return See help documentation for the runDeliveryMan function
#' @export
dumbDM=function(roads,car,packages){
  car$nextMove=sample(c(2,4,6,8),1)
  return (car)
}
#' basicDM
#'
#' This control function will pick up and deliver the packages in the order they
#' are given (FIFO). The packages are then delivered ignoring the trafic conditions
#' by first moving horizontally and then vertically.
#' 
#' As a first step, you should make sure you do better than this.
#' @param roads See help documentation for the runDeliveryMan function
#' @param cars See help documentation for the runDeliveryMan function
#' @param packages See help documentation for the runDeliveryMan function
#' @return See help documentation for the runDeliveryMan function
#' @export
basicDM=function(roads,car,packages) {
  nextMove=0
  toGo=0
  offset=0
  if (car$load==0) {
    toGo=which(packages[,5]==0)[1]
  } else {
    toGo=car$load
    offset=2
  }
  if (car$x<packages[toGo,1+offset]) {nextMove=6}
  else if (car$x>packages[toGo,1+offset]) {nextMove=4}
  else if (car$y<packages[toGo,2+offset]) {nextMove=8}
  else if (car$y>packages[toGo,2+offset]) {nextMove=2}
  else {nextMove=5}
  car$nextMove=nextMove
  car$mem=list()
  return (car)
}
#' manualDM
#'
#' If you have the urge to play the game manually (giving moves 2, 4, 5, 6, or 8 using the keyboard) you
#' can pass this control function to runDeliveryMan
#' @param roads See help documentation for the runDeliveryMan function
#' @param cars See help documentation for the runDeliveryMan function
#' @param packages See help documentation for the runDeliveryMan function
#' @return See help documentation for the runDeliveryMan function
#' @export
manualDM=function(roads,car,packages) {
  if (car$load>0) {
    print(paste("Current load:",car$load))
    print(paste("Destination: X",packages[car$load,3],"Y",packages[car$load,4]))
  }
  car$nextMove=readline("Enter next move. Valid moves are 2,4,6,8,0 (directions as on keypad) or q for quit.")
  if (car$nextMove=="q") {stop("Game terminated on user request.")}
  return (car)
}

#' testDM
#'
#' Use this to debug under multiple circumstances and to see how your function compares with the par function
#' The mean for the par function (with n=500) on this is 172.734, and the sd is approximately 39.065.
#'
#' Your final result will be based on how your function performs on a similar run of 500 games, though with
#' a different seed used to select them.
#'
#' This set of seeds is chosen so as to include a tricky game that has pick ups and deliveries on the same
#' spot. This will occur in the actual games you are evaluated on too.
#'
#' While this is dependent on the machine used, we expect your function to be able to run the 500 evaluation games on
#' the evaluation machine in under 4 minutes (250 seconds). If the evaluation machine is slower than expected,
#' this will be altered so that the required time is 25% slower than the par function.
#'
#' The par function takes approximately 96 seconds on my laptop (with n=500 and verbose=0).
#'
#' @param myFunction The function you have created to control the Delivery Man game.
#' @param verbose Set to 0 for no output, 1 for a summary of the results of the games played (mean,
#' standard deviation and time taken), and 2 for the above plus written output detailing seeds used and the
#' runDeliveryMan output of the result of each game.
#' @param returnVec Set to TRUE if you want the results of the games played returned as a vector.
#' @param n The number of games played. You will be evaluated on a set of 500 games, which is also the default here.
#' @param timeLimit The time limit. If this is breached, a NA is returned.
#' @return If returnVec is false, a scalar giving the mean of the results of the games played. If returnVec is TRUE
#' a vector giving the result of each game played. If the time limit is breached, a NA is returned.
#' @export
testDM=function(myFunction,verbose=0,returnVec=FALSE,n=500,seed=21,timeLimit=250){
  if (!is.na(seed))
    set.seed(seed)
  seeds=sample(1:25000,n)
  startTime=Sys.time()
  aStar=sapply(seeds,function(s){
    midTime=Sys.time()
    if (as.numeric(midTime)-as.numeric(startTime)>timeLimit) {
      cat("\nRun terminated due to slowness.")
      return (NA)
    }
    set.seed(s)
    if (verbose==2)
      cat("\nNew game, seed",s)
    runDeliveryMan(myFunction,doPlot=F,pause=0,verbose=verbose==2)
  })
  endTime=Sys.time()
  if (verbose>=1){
    cat("\nMean:",mean(aStar))
    cat("\nStd Dev:",sd(aStar))
    cat("\nTime taken:",as.numeric(endTime)-as.numeric(startTime),"seconds.")
  }
  if (returnVec)
    return(aStar)
  else
    return (mean(aStar))
}

#' Run Delivery Man
#'
#' Runs the delivery man game. In this game, deliveries are randomly placed on a city grid. You
#' must pick up and deliver the deliveries as fast as possible under changing traffic conditions.
#' Your score is the time it takes for you to complete this task. To play manually pass manualDM
#' as the carReady function and enter the number pad direction numbers to make moves.
#' @param carReady Your function that takes three arguments: (1) a list of two matrices giving the
#' traffice conditions. The first matrix is named 'hroads' and gives a matrix of traffice conditions
#' on the horizontal roads. The second matrix is named 'vroads' and gives a matrix of traffic
#' conditional on the vertical roads. <1,1> is the bottom left, and <dim,dim> is the top right.
#'(2) a list providing information about your car. This
#' list includes the x and y coordinates of the car with names 'x' and 'y', the package the car
#' is carrying, with name 'load' (this is 0 if no package is being carried), a list called
#' 'mem' that you can use to store information you want to remember from turn to turn, and
#' a field called nextMove where you will write what you want the car to do. Moves are
#' specified as on the number-pad (2 down, 4 left, 6 right, 8 up, 5 stay still). (3) A
#' matrix containing information about the packages. This contains five columns and a row for each
#' package. The first two columns give x and y coordinates about where the package should be picked
#' up from. The next two columns give x and y coordinates about where the package should be
#' delivered to. The final column specifies the package status (0 is not picked up, 1 is picked up but not
#' delivered, 2 is delivered).
#' Your function should return the car object with the nextMove specified.
#' @param dim The dimension of the board. You will be scored on a board of dimension 10. Note that
#' this means you will have to remove duplicated nodes from your frontier to keep your AStar
#' computationally reasonable! There is a time limit for how long an average game can be run in, and
#' if your program takes too long, you will penalized or even fail.
#' @param turns The number of turns the game should go for if deliveries are not made. Ignore this
#' except for noting that the default is 2000 so if you have not made deliveries after 2000 turns
#' you fail.
#' @param doPlot Specifies if you want the game state to be plotted each turn.
#' @param pause The pause period between moves. Ignore this.
#' @param del The number of deliveries. You will be scored on a board with 5 deliveries.
#' @return A string describing the outcome of the game.
#' @export
runDeliveryMan <- function (carReady=manualDM,dim=10,turns=2000,
                            doPlot=T,pause=0.1,del=5,verbose=T) {
  roads=makeRoadMatrices(dim)
  car=list(x=1,y=1,wait=0,load=0,nextMove=NA,mem=list())
  packages=matrix(sample(1:dim,replace=T,5*del),ncol=5)
  packages[,5]=rep(0,del)
  for (i in 1:turns) {
    roads=updateRoads(roads$hroads,roads$vroads)
    if (doPlot) {
      makeDotGrid(dim,i)
      plotRoads(roads$hroads,roads$vroads)
      points(car$x,car$y,pch=16,col="blue",cex=3)
      plotPackages(packages)
    }
    if (car$wait==0) {
      if (car$load==0) {
        on=packageOn(car$x,car$y,packages)
        if (on!=0) {
          packages[on,5]=1
          car$load=on
        }
      } else if (packages[car$load,3]==car$x && packages[car$load,4]==car$y) {
        packages[car$load,5]=2
        car$load=0
        if (sum(packages[,5])==2*nrow(packages)) {
          if (verbose)
            cat("\nCongratulations! You suceeded in",i,"turns!")
          return (i)
        }
      }
      car=carReady(roads,car,packages)
      car=processNextMove(car,roads,dim)
    } else {
      car$wait=car$wait-1
    }
    if (pause>0) Sys.sleep(pause)
  }
  cat("\nYou failed to complete the task. Try again.")
  return (NA)
}
#' @keywords internal
packageOn<-function(x,y,packages){
  notpickedup=which(packages[,5]==0)
  onX=which(packages[,1]==x)
  onY=which(packages[,2]==y)
  available=intersect(notpickedup,intersect(onX,onY))
  if (length(available)!=0) {
    return (available[1])
  }
  return (0)
}
#' @keywords internal
processNextMove<-function(car,roads,dim) {
  nextMove=car$nextMove
  if (nextMove==8) {
    if (car$y!=dim) {
      car$wait=roads$vroads[car$x,car$y]
      car$y=car$y+1
    } else {
      warning(paste("Cannot move up from y-position",car$y))
    }
  } else if (nextMove==2) {
    if (car$y!=1) {
      car$y=car$y-1
      car$wait=roads$vroads[car$x,car$y]
    } else {
      warning(paste("Cannot move down from y-position",car$y))
    }
  }  else if (nextMove==4) {
    if (car$x!=1) {
      car$x=car$x-1
      car$wait=roads$hroads[car$x,car$y]
    } else {
      warning(paste("Cannot move left from x-position",car$x))
    }
  }  else if (nextMove==6) {
    if (car$x!=dim) {
      car$wait=roads$hroads[car$x,car$y]
      car$x=car$x+1
    } else {
      warning(paste("Cannot move right from x-position",car$x))
    }
  } else if (nextMove!=5) {
    warning("Invalid move. No move made. Use 5 for deliberate no move.")
  }
  car$nextMove=NA
  return (car)
}

#' @keywords internal
plotPackages=function(packages) {
  notpickedup=which(packages[,5]==0)
  notdelivered=which(packages[,5]!=2)
  points(packages[notpickedup,1],packages[notpickedup,2],col="green",pch=18,cex=3)
  points(packages[notdelivered,3],packages[notdelivered,4],col="red",pch=18,cex=3)
}

#' @keywords internal
makeDotGrid<-function(n,i) {
  plot(rep(seq(1,n),each=n),rep(seq(1,n),n),xlab="X",ylab="Y",main=paste("Delivery Man. Turn ", i,".",sep=""))
}

#' @keywords internal
makeRoadMatrices<-function(n){
  hroads=matrix(rep(1,n*(n-1)),nrow=n-1)
  vroads=matrix(rep(1,(n-1)*n),nrow=n)
  list(hroads=hroads,vroads=vroads)
}

#' @keywords internal
plotRoads<- function (hroads,vroads) {
  for (row in 1:nrow(hroads)) {
    for (col in 1:ncol(hroads)) {
      lines(c(row,row+1),c(col,col),col=hroads[row,col])
    }
  }
  for (row in 1:nrow(vroads)) {
    for (col in 1:ncol(vroads)) {
      lines(c(row,row),c(col,col+1),col=vroads[row,col])
    }
  }
}
#' @keywords internal
updateRoads<-function(hroads,vroads) {
  r1=runif(length(hroads))
  r2=runif(length(hroads))
  for (i in 1:length(hroads)) {
    h=hroads[i]
    if (h==1) {
      if (r1[i]<.05) {
        hroads[i]=2
      }
    }
    else {
      if (r1[i]<.05) {
        hroads[i]=h-1
      } else if (r1[i]<.1) {
        hroads[i]=h+1
      }
    }
    v=vroads[i]
    if (v==1) {
      if (r2[i]<.05) {
        vroads[i]=2
      }
    }
    else {
      if (r2[i]<.05) {
        vroads[i]=v-1
      } else if (r2[i]<.1) {
        vroads[i]=v+1
      }
    }
  }
  list (hroads=hroads,vroads=vroads)
}

# ---------------------- OUR CODE --------
# TAKE TRAFFIC INTO ACCOUNT HERE as well
findNearestPackage <- function(car, packages) {
  closest_package <- NULL
  min_distance <- Inf
  
  for (i in 1:nrow(packages)) {
    # If package isn't delivered, calculate distance
    if (packages[i, 5] == 0) {
      distance <- calculateManhattanDistance(car$x, car$y, packages[i, 1], packages[i, 2])
      if (distance < min_distance) {
        min_distance <- distance
        closest_package <- packages[i, c(1, 2)]
      }
    }
  }
  return(closest_package)
}

calculateManhattanDistance <- function(loc1_x, loc1_y, loc2_x, loc2_y) {
  return(abs(loc1_x - loc2_x) + abs(loc1_y - loc2_y))
}

getNeighborsAndTraffic <- function(node, roads) {
  neighbors <- list()
  
  # Only get valid neighbors within the grid
  if (node$x >= 2) {
    neighbors <- append(neighbors, list(list(x=node$x-1, y=node$y, direction=4, g=0, h=0, f=0, traffic_cost=roads$hroads[node$x - 1, node$y]))) # Left
  }
  if (node$x <= 9 ) {
    neighbors <- append(neighbors, list(list(x=node$x+1, y=node$y, direction=6, g=0, h=0, f=0, traffic_cost = roads$hroads[node$x, node$y])))  # Right
  }
  if (node$y >= 2) {
    neighbors <- append(neighbors, list(list(x=node$x, y=node$y-1, direction=2, g=0, h=0, f=0, traffic_cost = roads$vroads[node$x, node$y - 1])))  # Down
  }
  if (node$y <= 9) {
    neighbors <- append(neighbors, list(list(x=node$x, y=node$y+1, direction=8, g=0, h=0, f=0, traffic_cost =roads$vroads[node$x, node$y])))  # Up
  }
  
  return(neighbors)
}

# sortNodeListOnFvalues <- function(myList) {
#   f_values <- list()
#   f_values <- sapply(myList, function(node) node$f)
#   sorted_indices <- order(f_values)
#   list_sorted <- myList[sorted_indices]
#   return(list_sorted)
# }


# if multiple lowst f values exist, sort again based on lowest distance
sortNodeListOnFvalues <- function(myList) {
  # Extract f and g values from each node in the list
  f_values <- sapply(myList, function(node) node$f)
  h_values <- sapply(myList, function(node) node$h)
  
  # Sort by f values first, and by g values as a secondary criterion
  sorted_indices <- order(f_values, h_values)
  
  # Sort the list using the computed sorted indices
  list_sorted <- myList[sorted_indices]
  
  return(list_sorted)
}


# NOTES
# backtrack to find multiple paths/plans
# BasicDM doesn't oscillate? 

#' Elise Algo2
eliseAlgorithm <- function(roads, car, packages) {
  # if car is not carrying a package, get which package is closest
  print(paste("Location of car:", paste(car$x, car$y, collapse = ", ")))
  print("Packages:")
  print(packages)
  
  if (car$load == 0) {
    goal <- findNearestPackage(car, packages)
    print(paste("Goal (nearest package):", paste(goal, collapse = ", ")))
    next_move <- runAStar(car$x, car$y, goal, roads)
  } else {
    # if(car$x == goal[1] && car$y == goal[2]){
    #   next_move <- 5 # stay still if goal is reached
    #   print("Car is at pickup/delivery location, standing still...")
    # } else {
    #   # goal <- packages[car$load, c(3, 4)]
    #   # print(paste("Goal (delivery location):", paste(goal, collapse = ", ")))
    #   # next_move <- runAStar(car$x, car$y, goal, roads)
    # }
    goal <- packages[car$load, c(3, 4)]
    print(paste("Goal (delivery location):", paste(goal, collapse = ", ")))
    next_move <- runAStar(car$x, car$y, goal, roads)
  }
  print(paste("Moving direction:", paste(next_move), collapse = ", "))
  car$nextMove = next_move
  return(car)
}

runAStar <- function(start_x, start_y, goal, roads) {
  open_list <- list() # priority queue, doesn't reset until A* is finished
  closed_list <- list() # best path list, doesn't reset until A* is finished
  start_node <- list(x=start_x, y=start_y, g=0, h=calculateManhattanDistance(start_x, start_y, goal[1], goal[2]), f=0, directon=5)
  start_node$f <- start_node$g + start_node$h

  open_list <- append(open_list, list(start_node))
  #print(paste("open_list at start:", paste(list(open_list)), collapse = ", "))

  # finds best path from current node to goal
  # while loop ends when the goal node is at the top of the list
  while (!( (open_list[[1]]$x == goal[1]) && (open_list[[1]]$y == goal[2]) )) {
    print("in while")

    open_list <- sortNodeListOnFvalues(open_list)
    #print(paste("open_list after sorting 1:", paste(list(open_list)), collapse = ", "))

    best_node <- open_list[[1]] # best node is the node with the least f-value, this is our best next step
    print(paste("best_node:", pastea(list(best_node)), collapse = ", "))
    open_list <- list() #make open list clean for our current node
    closed_list <- append(closed_list, list(best_node))

    neighbors <- getNeighborsAndTraffic(best_node, roads)
    for (i in seq_along(neighbors)) {
      neighbor <- neighbors[[i]]

      if (any(sapply(closed_list, function(n) n$x == neighbor$x && n$y == neighbor$y))) {
        next
      }

      #neighbor$g <- best_node$g + neighbor$traffic_cost
      neighbor$g <- neighbor$traffic_cost
      neighbor$h <- calculateManhattanDistance(neighbor$x, neighbor$y, goal[1], goal[2])
      neighbor$f <- neighbor$g + neighbor$h
      neighbor$first_move <- c(best_node$x, best_node$y)

      neighbors[[i]] <- neighbor
      #print(paste("neighbor:", paste(list(neighbor)), collapse = ", "))
      open_list <- append(open_list, list(neighbors[[i]]))
    }

    print(paste("neighbors:", paste(list(neighbors)), collapse = ", "))
    print(paste("open list INNAN sort:", paste(list(open_list)), collapse = ", "))

    open_list <- sortNodeListOnFvalues(open_list) #sorting remaining nodes
    print(paste("open_list after sorting 2:", paste(list(open_list)), collapse = ", "))

    #input=readline("Enter keypress to process next step. Press q for quit.")
    #if (input=="q") {stop("Game terminated on user request.")}

  }

  # when goal is reached, add best node to closed list 
  print("While ends, goal is reached")
  
  print(paste("open_list after goal is reached - 3:", paste(list(open_list)), collapse = ", "))
  closed_list <- append(closed_list, list(open_list[[1]]))

  # add backtracking

  #print(paste("closed_list:", paste(list(closed_list)), collapse = ", "))
  next_move <- closed_list[[2]]$direction # Takes the next step on the optimal path
  return(next_move)
}
