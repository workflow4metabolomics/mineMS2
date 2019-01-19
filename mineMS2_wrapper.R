#!/usr/bin/env Rscript

library(batch) ## parseCommandArgs

# Constants
argv <- commandArgs(trailingOnly = FALSE)
script.path <- sub("--file=","",argv[grep("--file=",argv)])
prog.name <- basename(script.path)

# Print help
if (length(grep('-h', argv)) >0) {
  cat("Usage:", prog.name,
      # "dataMatrix_in myDataMatrix.tsv",
      # "sampleMetadata_in mySampleData.tsv",
      # "variableMetadata_in myVariableMetadata.tsv",
      # "respC ...",
      # "predI ...",
      # "orthoI ...",
      # "testL ...",
      # "typeC ...",
      # "parAsColC ...",
      # "parCexN ...",
      # "parPc1I ...",
      # "parPc2I ...",
      # "parMahalC ...",
      # "parLabVc ...",
      # "algoC ...",
      # "crossvalI ...",
      # "log10L ...",
      # "permI ...",
      # "scaleC ...",
      # "sampleMetadata_out mySampleMetadata_out.tsv",
      # "variableMetadata_out myVariableMetadata_out.tsv",
      # "figure figure.pdf",
      # "information information.txt",
      "\n")
  quit(status = 0)
}


#### MAIN

argVc <- unlist(parseCommandArgs(evaluate=FALSE))

#### Initializing ####

## options

strAsFacL <- options()$stringsAsFactors
options(stringsAsFactors = FALSE)

## libraries

suppressMessages(library(mineMS2))
suppressMessages(library(igraph))

## constants

modNamC <- "mineMS2" ## module name

topEnvC <- environment()
flgC <- "\n"

## functions

flgF <- function(tesC,
                 envC = topEnvC,
                 txtC = NA) { ## management of warning and error messages
  
  tesL <- eval(parse(text = tesC), envir = envC)
  
  if(!tesL) {
    
    sink()
    stpTxtC <- ifelse(is.na(txtC),
                      paste0(tesC, " is FALSE"),
                      txtC)
    
    stop(stpTxtC,
         call. = FALSE)
    
  }
  
} ## flgF


## log file

sink(argVc["information"])

cat("\nStart of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep="")


## arguments

path_mgf <- argVc["spectra_mgf"]

path_network <- argVc["spectra_graphml"]


#### Computation and plot ####

# sink()

# supp_infos <- read.table(path_supp_info,header=TRUE,sep=";")

### Sepctra are read and thresholded
m2l <- mineMS2::ms2Lib(path_mgf)
              # suppInfos = supp_infos, intThreshold = 3000)

### An ID is added to each spectra
infos <- mineMS2::getInfo(m2l,"S")

# ids <- paste(paste("MZ",infos[,"mz"],sep=""),paste("RT",infos[,"rt"],sep=""),sep="_")
ids <- paste(paste("MZ",infos[,"mz.precursor"],sep=""),sep="_")

m2l <- mineMS2::setIds(m2l,ids)

### DAGs are created
m2l <- mineMS2::discretizeMassLosses(m2l,dmz = 0.008,ppm=8,heteroAtoms=FALSE,maxFrags=15)

### Patterns are detected
m2l <- mineMS2::mineClosedSubgraphs(m2l,sizeMin=1,count=2)


### gnps_network_reading

net_gnps <- read_graph(path_network, "graphml")


#### Print ####



# sink(argVc["information"], append = TRUE)

cat("\n", modC, "\n", sep = "")

cat("\n", desMC["samples", ],
    " samples x ",
    desMC["X_variables", ],
    " variables",
    ifelse(modC != "PCA",
           " and 1 response",
           ""),
    "\n", sep = "")

cat("\n", ropLs@suppLs[["scaleC"]], " scaling of dataMatrix",
    ifelse(modC == "PCA",
           "",
           paste0(" and ",
                  ifelse(mode(ropLs@suppLs[["yMCN"]]) == "character" && ropLs@suppLs[["scaleC"]] != "standard",
                         "standard scaling of ",
                         ""),
                  "response\n")), sep = "")

if(substr(desMC["missing_values", ], 1, 1) != "0")
  cat("\n", desMC["missing_values", ], " NAs\n", sep = "")

if(substr(desMC["near_zero_excluded_X_variables", ], 1, 1) != "0")
  cat("\n", desMC["near_zero_excluded_X_variables", ],
      " excluded variables during model building (because of near zero variance)\n", sep = "")

cat("\n")

optDigN <- options()[["digits"]]
options(digits = 3)
print(ropLs@modelDF)
options(digits = optDigN)


##------------------------------
## Ending
##------------------------------


## Saving
##-------


rspModC <- gsub("-", "", modC)
if(rspModC != "PCA")
  rspModC <- paste0(make.names(argVc['respC']), "_", rspModC)

if(sumDF[, "pre"] + sumDF[, "ort"] < 2) {
  
  tCompMN <- scoreMN
  pCompMN <- loadingMN
  
} else {
  
  if(sumDF[, "ort"] > 0) {
    if(parCompVi[2] > sumDF[, "ort"] + 1)
      stop("Selected orthogonal component for plotting (ordinate) exceeds the total number of orthogonal components of the model", call. = FALSE)
    tCompMN <- cbind(scoreMN[, 1], orthoScoreMN[, parCompVi[2] - 1])
    pCompMN <- cbind(loadingMN[, 1], orthoLoadingMN[, parCompVi[2] - 1])
    colnames(pCompMN) <- colnames(tCompMN) <- c("h1", paste("o", parCompVi[2] - 1, sep = ""))
  } else {
    if(max(parCompVi) > sumDF[, "pre"])
      stop("Selected component for plotting as ordinate exceeds the total number of predictive components of the model", call. = FALSE)
    tCompMN <- scoreMN[, parCompVi, drop = FALSE]
    pCompMN <- loadingMN[, parCompVi, drop = FALSE]
  }
  
}

## x-scores and prediction

colnames(tCompMN) <- paste0(rspModC, "_XSCOR-", colnames(tCompMN))
tCompDF <- as.data.frame(tCompMN)[rownames(samDF), , drop = FALSE]

if(modC != "PCA") {
  
  if(!is.null(tesVl)) {
    tCompFulMN <- matrix(NA,
                         nrow = nrow(samDF),
                         ncol = ncol(tCompMN),
                         dimnames = list(rownames(samDF), colnames(tCompMN)))
    mode(tCompFulMN) <- "numeric"
    tCompFulMN[rownames(tCompMN), ] <- tCompMN
    tCompMN <- tCompFulMN
    
    fitMCN <- fitted(ropLs)
    fitFulMCN <- matrix(NA,
                        nrow = nrow(samDF),
                        ncol = 1,
                        dimnames = list(rownames(samDF), NULL))
    mode(fitFulMCN) <- mode(fitMCN)
    fitFulMCN[rownames(fitMCN), ] <- fitMCN
    yPreMCN <- predict(ropLs, newdata = as.data.frame(xTesMN))
    fitFulMCN[rownames(yPreMCN), ] <- yPreMCN
    fitMCN <- fitFulMCN
    
  } else
    fitMCN <- fitted(ropLs)
  
  colnames(fitMCN) <- paste0(rspModC,
                             "_predictions")
  fitDF <- as.data.frame(fitMCN)[rownames(samDF), , drop = FALSE]
  
  tCompDF <- cbind.data.frame(tCompDF, fitDF)
}

samDF <- cbind.data.frame(samDF, tCompDF)

## x-loadings and VIP

colnames(pCompMN) <- paste0(rspModC, "_XLOAD-", colnames(pCompMN))
if(!is.null(vipVn)) {
  pCompMN <- cbind(pCompMN, vipVn)
  colnames(pCompMN)[ncol(pCompMN)] <- paste0(rspModC,
                                             "_VIP",
                                             ifelse(!is.null(orthoVipVn),
                                                    "_pred",
                                                    ""))
  if(!is.null(orthoVipVn)) {
    pCompMN <- cbind(pCompMN, orthoVipVn)
    colnames(pCompMN)[ncol(pCompMN)] <- paste0(rspModC,
                                               "_VIP_ortho")
  }
}
if(!is.null(coeMN)) {
  pCompMN <- cbind(pCompMN, coeMN)
  if(ncol(coeMN) == 1)
    colnames(pCompMN)[ncol(pCompMN)] <- paste0(rspModC, "_COEFF")
  else
    colnames(pCompMN)[(ncol(pCompMN) - ncol(coeMN) + 1):ncol(pCompMN)] <- paste0(rspModC, "_", colnames(coeMN), "-COEFF")
}
pCompDF <- as.data.frame(pCompMN)[rownames(varDF), , drop = FALSE]
varDF <- cbind.data.frame(varDF, pCompDF)

## sampleMetadata

samDF <- cbind.data.frame(sampleMetadata = rownames(samDF),
                          samDF)
write.table(samDF,
            file = argVc["sampleMetadata_out"],
            quote = FALSE,
            row.names = FALSE,
            sep = "\t")

## variableMetadata

varDF <- cbind.data.frame(variableMetadata = rownames(varDF),
                          varDF)
write.table(varDF,
            file = argVc["variableMetadata_out"],
            quote = FALSE,
            row.names = FALSE,
            sep = "\t")

# Output ropLs
if (!is.null(argVc['ropls_out']) && !is.na(argVc['ropls_out']))
  save(ropLs, file = argVc['ropls_out'])

## Closing
##--------

cat("\nEnd of '", modNamC, "' Galaxy module call: ",
    as.character(Sys.time()), "\n", sep = "")

cat("\n\n\n============================================================================")
cat("\nAdditional information about the call:\n")
cat("\n1) Parameters:\n")
print(cbind(value = argVc))

cat("\n2) Session Info:\n")
sessioninfo <- sessionInfo()
cat(sessioninfo$R.version$version.string,"\n")
cat("Main packages:\n")
for (pkg in names(sessioninfo$otherPkgs)) { cat(paste(pkg,packageVersion(pkg)),"\t") }; cat("\n")
cat("Other loaded packages:\n")
for (pkg in names(sessioninfo$loadedOnly)) { cat(paste(pkg,packageVersion(pkg)),"\t") }; cat("\n")

cat("============================================================================\n")

sink()

options(stringsAsFactors = strAsFacL)

rm(list = ls())
