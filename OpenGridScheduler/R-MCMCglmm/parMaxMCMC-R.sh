#!/usr/bin/env Rscript
library(stats)
library(utils)
library(methods)
library(base)

args <- commandArgs(TRUE)
  t <- as.integer(args[1])
  totalT <- as.integer(args[2])


#FIXME
nsamp <- 2000
BURN <- 5000; THIN <- 4000; (NITT <- BURN + THIN*nsamp)




tnsamp <- ceiling(nsamp/totalT)
(tNITT <- BURN + tnsamp*THIN)


# Determine if on cluster or own computer
if(grepl("<< Cluster username (should be distinct from personal computer account name >>", getwd())){
  setwd("<< PATH to cluster folder >>")
} else setwd("<< PATH to local computer folder >>")
library(MCMCglmm)
library(nadiv)
set.seed(100 + t)


#FIXME
# R-specific pre-processing operations unique to an analysis
load(file = "<< Usually data >>")






##################################################
##################################################




##############################################################
#FIXME
# Priors
bivPEpriorNukp1 <- list(R = list(V = diag(2), nu = 2),
	G = list(G1 = list(V = diag(2)*0.02, nu = 3, alpha.mu = c(0,0), alpha.V = diag(2)*1000),
		G2 = list(V = diag(2)*0.02, nu = 3, alpha.mu = c(0,0), alpha.V = diag(2)*1000)))








# Should be over-dispersed (find citation?)
#FIXME
#XXX Make sure matches actual data in model
nfx <- nrow(AdLRS93to12)


#startN <- list(liab = rnorm(nfx, 0, 12),    #XXX *2 if hupoisson
#	R = list(R1 = rIW(diag(1), 15)), #diag(1)),##XXX add `, fix = 2)),` for hupoisson/zipoisson
#	G = list(G1 = rIW(diag(1), 15),
#		G2 = rIW(diag(1), 15),
#		G3 = rIW(diag(1), 15)))
#############################################
startN <- list(liab = rnorm(nfx, 0, 12),    
	R = list(R1 = rIW(diag(2), 15)),
	G = list(G1 = rIW(diag(2), 15),
		G2 = rIW(diag(2), 15)))


#FIXME
# Model name, use periods between words/phrases
modName <- "<< something describing the model >>"





filename <- gsub(pattern = "[:.:]", replacement = "_", x = modName)
modName <- paste0(modName, t)



#FIXME
system.time(tMod <- MCMCglmm(genLRS ~ sex * f,
	random = ~ us(sex):id + us(sex):natalyr,
	rcov = ~ idh(sex):units,
	ginverse = list(id = Ainv),
	data = AdLRS93to12,
	prior = bivPEpriorNukp1,
	family = "poisson",
	slice = TRUE,
	pl = TRUE, pr = TRUE, saveX = TRUE, saveZ = TRUE,
	nitt = tNITT, thin = THIN, burnin = BURN))


############################################################
assign(modName, tMod)
save(list = c(modName),
  file = paste0("./mcModels/", filename, "_", t, "_nit", tNITT/1000, "k.RData"))

cat("saved successfully\n")


q("no")

