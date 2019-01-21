#!/usr/bin/env Rscript

#### Packages ####

library(RUnit)

#### Constants ####

testOutDirC <- "output"
argVc <- commandArgs(trailingOnly = FALSE)
scriptPathC <- sub("--file=", "", argVc[grep("--file=", argVc)])


#### Functions  ####


## Call wrapper
wrapperCallF <- function(paramLs) {
  
  ## Set program path
  wrapperPathC <- file.path(dirname(scriptPathC), "..", "mineMS2_wrapper.R")
  
  ## Set arguments
  argLs <- NULL
  for (parC in names(paramLs))
    argLs <- c(argLs, parC, paramLs[[parC]])
  
  ## Call
  wrapperCallC <- paste(c(wrapperPathC, argLs), collapse = " ")
  
  if(.Platform$OS.type == "windows")
    wrapperCallC <- paste("Rscript", wrapperCallC)
  
  wrapperCodeN <- system(wrapperCallC)
  
  if (wrapperCodeN != 0)
    stop("Error when running mineMS2_wrapper.R.")
  
  ## Get output
  outLs <- list()
  
  outLs[["infVc"]] <- readLines(paramLs[["information_txt"]])
  
  return(outLs)
}

## Setting default parameters
defaultArgF <- function(testInDirC) {
  
  defaultArgLs <- list()
  
  defaultArgLs[["annotation_graphml"]] <- file.path(dirname(scriptPathC), testOutDirC, "annotation.graphml")
  defaultArgLs[["figure_pdf"]] <- file.path(dirname(scriptPathC), testOutDirC, "figure.pdf")
  defaultArgLs[["information_txt"]] <- file.path(dirname(scriptPathC), testOutDirC, "information.txt")
  
  defaultArgLs
  
}

#### Main ####

## Create output folder
file.exists(testOutDirC) || dir.create(testOutDirC)

## Run tests
test.suite <- defineTestSuite('tests', dirname(scriptPathC), testFileRegexp = paste0('^.*_tests\\.R$'),
                              testFuncRegexp = '^.*$')
isValidTestSuite(test.suite)
test.results <- runTestSuite(test.suite)
print(test.results)
