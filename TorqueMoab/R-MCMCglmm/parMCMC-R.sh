#!/usr/bin/env Rscript

# Clean R session is started, the following packages are necessary
library(stats)
library(utils)
library(methods)
library(base)


# Command-line arguments
args <- commandArgs(TRUE)
  t <- as.integer(args[1])
  totalT <- as.integer(args[2])


#FIXME Adjust the MCMC parameters for the TOTAL chain length
nsamp <- 1000
BURN <- 3000; THIN <- 10; (NITT <- BURN + THIN*nsamp)



# Below calculates the number of iterations for the t-th chain (out of T chains)
tnsamp <- ceiling(nsamp/totalT)
(tNITT <- BURN + tnsamp*THIN)
library(MCMCglmm)

# Make each chain start with different random number generator seed
set.seed(100 + t)


#FIXME R-specific pre-processing operations unique to an analysis/dataset
## e.g., load(file = "<< Usually data >>")
data(PlodiaPO)





##################################################
##################################################




##############################################################
#FIXME
# Priors of other than default
PEpriorIW <- list(R = list(V = diag(1), nu = 1),
	G = list(G1 = list(V = diag(1), nu = 1, alpha.mu = rep(0, 1), alpha.V = diag(1)*1000)))







# Should be over-dispersed (find citation?)
#FIXME
#XXX Make sure matches actual data in model
nfx <- nrow(PlodiaPO)

#XXX Make sure matches prior
startN <- list(liab = rnorm(nfx, 0, 12),   # Need to specify the liabilities  
	R = list(R1 = rIW(diag(1), 15)),
	G = list(G1 = rIW(diag(1), 15)))




#FIXME
# Model name, use periods between words/phrases
## e.g., modName <- "<< something describing the model >>"
modName <- "model1"



# the file name is the model name, but uses underscores instead of periods
filename <- gsub(pattern = "[:.:]", replacement = "_", x = modName)
modName <- paste0(modName, t)



#FIXME
system.time(tMod <- MCMCglmm(PO ~ 1,
	random = ~ FSfamily,
	data = PlodiaPO,
	prior = PEpriorIW,
	pl = TRUE, pr = TRUE, saveX = TRUE, saveZ = TRUE,
	nitt = tNITT, thin = THIN, burnin = BURN,
	verbose = FALSE))
     

############################################################
assign(modName, tMod)
save(list = c(modName),
  file = paste0("./mcModels/", filename, "_", t, "_nit", tNITT/1000, "k.RData"))

cat("saved successfully\n")


q("no")

