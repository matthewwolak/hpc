rm(list = ls())
			# base name of the models
modNamePeriods <- paste0("<< replace model name here: should correspond with parMaxMCMC-R.sh and have PERIODS between words/phrases >>")
modName <- paste0(gsub(pattern = ".", replacement = "_", modNamePeriods, fixed = TRUE), "_")
maxn <- 20		# number of jobs in single array
nsamp <- 2000		# total sample size desired for analyses of dataset
  nsamp <- ceiling(nsamp/maxn) * maxn #correction in case any rounding was done
BURN <- 5000		# burnin specified for each model
THIN <- 4000		# thinning interval specified for each model
nSol <- 4		# No. of location effects to save (first nSol saved)
nVCV <- 10		# No. of (co)variance parameters to save (first nVCV saved)
nCP <- 1		# No. of cutpoints (if threshold/ordinal) - 1 OTHERWISE
maxLiab <- 25		# ~7 if probit link / ~20 if logit link (Hadfield Course Notes, p.134)
###############################################################################
# Determine if on cluster or own computer
if(grepl("<< Cluster username (should be distinct from personal computer account name >>", getwd())){
  setwd("<< PATH to cluster folder >>")
} else setwd("<< PATH to local computer folder >>")
library(MCMCglmm)


outlist <- list(Sol = mcmc(matrix(NA, nrow = nsamp, ncol = nSol), start = BURN+1, end = tail(seq(from=BURN+1, by=THIN, length=nsamp),1), thin = THIN),
	CP = mcmc(matrix(NA, nrow = nsamp, ncol = nCP), start= BURN+1, end = tail(seq(from=BURN+1, by=THIN, length=nsamp),1), thin = THIN),
	VCV = mcmc(matrix(NA, nrow = nsamp, ncol = nVCV), start = BURN+1, end = tail(seq(from=BURN+1, by=THIN, length=nsamp),1), thin = THIN))

mclistSol <- vector("list", length = maxn)
mclistCP <- vector("list", length = maxn)
mclistVCV <- vector("list", length = maxn)

checks <- matrix(NA, nrow = maxn, ncol = 1, dimnames = list(NULL, c("max(liab)")))
st <- 1; en <- nsamp/maxn

tmpAll <- get(load(file = paste0("./mcModels/", modName, "1_nit", (BURN + THIN*ceiling(nsamp/maxn))/1000, "k.RData")))
itnames <- c("Sol", "Lambda", "VCV", "CP", "Liab", "Deviance")
  itnames <- itnames[sapply(itnames, FUN = function(x){!is.null(tmpAll[[x]])})]

tmpAll[itnames] <- lapply(itnames, FUN = function(x){mcmc(matrix(NA, nrow = nsamp, ncol = if(is.null(ncol(tmpAll[[x]]))) length(tmpAll[[x]]) else ncol(tmpAll[[x]])), start = BURN+1, end = tail(seq(from=BURN+1, by=THIN, length=nsamp),1), thin = THIN)})


for(t in 1:maxn){
  tmpModel <- get(tmpModName <- load(file = paste0("./mcModels/", modName, t, "_nit", (BURN + THIN*ceiling(nsamp/maxn))/1000, "k.RData")))
  
  # First check liability values are not out of the appropriate range
  ## absolute value <20 for logit link (Hadfield coursenotes p.134)
  if(!is.null(tmpModel$Liab)) checks[t, 1] <- round(range(tmpModel$Liab)[which.max(abs(range(tmpModel$Liab)))], 3)

  # Now add samples to output list
  outlist$Sol[st:en, ] <- tmpModel$Sol[, 1:nSol]
  if(!is.null(tmpModel$CP)) outlist$CP[st:en, ] <- tmpModel$CP[, 1:nCP]
  outlist$VCV[st:en, ] <- tmpModel$VCV[, 1:nVCV]

  mclistSol[[t]] <- tmpModel$Sol[, 1:nSol]
  if(!is.null(tmpModel$CP)) mclistCP[[t]] <- tmpModel$CP[, 1:nCP]
  mclistVCV[[t]] <- tmpModel$VCV[, 1:nVCV]  # FIXME fixed residual [, 1:nVCV]

  lapply(itnames, FUN = function(x){tmpAll[[x]][st:en, ] <<- tmpModel[[x]]})
  st <- en+1; en <- en + nsamp/maxn
 
}
dimnames(outlist$Sol) <- list(NULL, dimnames(tmpModel$Sol)[[2]][1:nSol])
if(!is.null(tmpModel$CP)) dimnames(outlist$CP) <- list(NULL, dimnames(tmpModel$CP)[[2]][1:nCP])
dimnames(outlist$VCV) <- list(NULL, dimnames(tmpModel$VCV)[[2]][1:nVCV])
mclistSol <- mcmc.list(mclistSol)
if(!is.null(tmpModel$CP)) mclistCP <- mcmc.list(mclistCP)
mclistVCV <- mcmc.list(mclistVCV)

for(x in itnames){
  if(!is.null(dimnames(tmpModel[[x]]))){
    dimnames(tmpAll[[x]]) <- dimnames(tmpModel[[x]])
  }
}

modAllName <- strsplit(tmpModName, split = t)[[1]]
assign(modAllName, tmpAll)






##############################################
(gelmanSol <- gelman.diag(mclistSol)) #<-- value of 1 is desired (substantially >1 (~1.1) lack of convergence)
if(!is.null(tmpModel$CP)) (gelmanCP <- gelman.diag(mclistCP)) else gelmanCP <- list(psrf = matrix(1.0, nrow = 1, ncol = 2))
(gelmanVCV <- gelman.diag(mclistVCV, multivariate = FALSE)) #<-- value of 1 is desired (substantially >1 (~1.1) lack of convergence)

# average autocorrelation across all chains
(autocorrSol <- abs(autocorr.diag(mclistSol)[2, ]))
if(!is.null(tmpModel$CP)){
  (autocorrCP <- abs(autocorr.diag(mclistCP)[2, ]))
} else{
    autocorrCP <- 0.01
  }
(autocorrVCV <- abs(autocorr.diag(mclistVCV)[2, ]))
(gelmanCheck <- c(any(gelmanSol$psrf[, 2] >= 1.1),
	any(gelmanCP$psrf[, 2] >= 1.1),
	any(gelmanVCV$psrf[, 2] >= 1.1)))
(autocorrCheck <- c(any(autocorrSol >= 0.1),
	any(autocorrCP >= 0.1),
	any(autocorrVCV >= 0.1)))
checks
max(abs(checks))

stopifnot(all(abs(checks) < maxLiab),
	sum(gelmanCheck, na.rm = TRUE) == 0,
	sum(autocorrCheck, na.rm = TRUE) == 0)




if(all(abs(checks) < maxLiab) & all(!gelmanCheck) & all(!autocorrCheck)){
  cat("\n\tSAVED\n\tSAVED\n\tSAVED\n\tSAVED\n\n\n")

  save(list = modAllName,
	file=paste0("./mcModels/",modName,"nit",(BURN+nsamp*THIN)/1000, "k.RData"),
	compress = "xz", compression_level = 9)
  tmptmp <- (BURN+THIN*ceiling(nsamp/maxn))/1000
  system(paste0("rm ./mcModels/",modName,"*","_nit",tmptmp,"k.RData"))


}




#q("no")


