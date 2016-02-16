createChart <- function(query,db,param){
	con <- dbConnect(MySQL(),user="webuser",password="webuserpass",dbname=db,host="localhost")
    print(query)
    result <- dbGetQuery(con, query)
	dbDisconnect(con)
	print("Resultado tamaño: ")
	print(length(result[,1]))
	result[,3] <- as.numeric(as.POSIXct(result[,3], "%Y-%m-%d %H:%M:%S"))
	result.df = data.frame(x = result[,3], y = result[,1], z = result[,2])
	result.loess = loess(z ~ x*y, data = result.df, degree = 1, span=0.75)
	result.fit = expand.grid(list(x = seq(min(result.df$x), max(result.df$x), 1440), y = seq(min(result.df$y),max(result.df$y),0.1)))
	z = predict(result.loess, newdata = result.fit)
	result.fit$Height = as.numeric(z)
    
    #Modificacion de los colores (numero, color)
    lowestValue <- min(result.fit$Height)
    secondHighestValue <- unique(sort(result.fit$Height, decreasing=TRUE))[2]

    numberOfColorBins <- 25
    col.seq <- seq(lowestValue, secondHighestValue, length.out=numberOfColorBins)
    brks <- c(0, col.seq, Inf)
    cuts <- cut(result.fit$Height, breaks=brks)
    colors <- colorRampPalette(c("green", "red"))(length(levels(cuts))-1)
    colors <- c(colors, "black")

    cls <- rep(colors, times=table(cuts))

    colorRampPalette(c("white", "red"))
    levelplot(Height ~ x*y, data = result.fit, xlab = "Fecha", ylab = "Profundidad:", main = param, col.regions = terrain.colors(100), ylim = c(max(result.df$y),min(result.df$y)), xlim = c(as.POSIXct(min(result.df$x), origin="1970-01-01"), as.POSIXct(max(result.df$x), origin="1970-01-01")))
}
library("lattice")
library("RMySQL")
png(filename="./lstChrt.png", width = 700)
args = commandArgs()
print(args[length(args)])
createChart(args[length(args)-2],args[length(args)-1],args[length(args)])
dev.off()

