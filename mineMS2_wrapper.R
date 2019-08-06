#!/usr/bin/env -S Rscript --vanilla

library(batch) ## parseCommandArgs

# Constants
argv <- commandArgs(trailingOnly = FALSE)
script.path <- sub("--file=","",argv[grep("--file=",argv)])
prog.name <- basename(script.path)

# Print help
if (length(grep('-h', argv)) >0) {
  cat("Usage:", prog.name,
      "spectra_mgf myspectra.mgf",
      "network_graphml mynetwork.graphml",
      "thresholdVn ...",
      
      "annotation_graphml annotation.graphml",
      "figure_pdf figure.pdf",
      "information_txt information.txt",
      "\n")
  quit(status = 0)
}


argVc <- unlist(parseCommandArgs(evaluate=FALSE))

#### Initializing ####

## libraries

suppressMessages(library(mineMS2))
suppressMessages(library(igraph))

## constants

modNamC <- "mineMS2" ## module name

## log file

sink(argVc["information_txt"])

cat("\nStart of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep="")


## arguments

path_mgf <- argVc["spectra_mgf"]

path_network <- argVc["network_graphml"]


#### Computation and plot ####
print('-------------------------------- mineMS2::ms2Lib')

# supp_infos <- read.table(path_supp_info,header=TRUE,sep=";")

## Sepctra are read and thresholded
m2l <- mineMS2::ms2Lib(path_mgf)
                       # suppInfos = supp_infos,
                       # intThreshold = 3000)

print('-------------------------------- mineMS2::getInfo')
## An ID is added to each spectra
infos <- mineMS2::getInfo(m2l, "S")

ids <- paste(paste0("MZ", infos[,"mz.precursor"]), sep = "_")
# ids <- paste(paste0("MZ",infos[,"mz"]),paste0("RT",infos[,"rt"]),sep="_")

print('-------------------------------- mineMS2::setIds')
m2l <- mineMS2::setIds(m2l, ids)

## DAGs are created
print('-------------------------------- mineMS2::discretizeMassLosses')
m2l <- mineMS2::discretizeMassLosses(m2l,
                                     dmz = 0.008,
                                     ppm = 8,
                                     heteroAtoms = FALSE,
                                     maxFrags = 15)

## Patterns are detected
print('-------------------------------- mineMS2::mineClosedSubgraphs')
m2l <- mineMS2::mineClosedSubgraphs(m2l,
                                    sizeMin = 1,
                                    count = 2)

## Importing the GNPS network
print('-------------------------------- igraph::read_graph')
net_gnps <- igraph::read_graph(path_network, "graphml")

## Discard self-edges (i.e. single loops) added by GNPS to single nodes
net_gnps <- igraph::simplify(net_gnps,
                             remove.multiple = FALSE,
                             edge.attr.comb = "ignore")

## Extraction of the connected components and the cliques
print('-------------------------------- 100')
components <- mineMS2::findGNPSComponents(net_gnps,
                                          minSize = 3,
                                          pairThreshold = 0.9)

## Patterns that maximizes recall are extracted for each component
print('-------------------------------- 110')
patterns <- mineMS2::findPatternsExplainingComponents(m2l,
                                                      components,
                                                      metric=c("recall",
                                                               "precision",
                                                               "size"))

## Network annotation
print('-------------------------------- 120')
annotated_net <- mineMS2::annotateNetwork(components,
                                          net_gnps,
                                          patterns)

#### Plotting ####
print('-------------------------------- 121')
pdf(argVc["figure_pdf"])
print('-------------------------------- 122')
print(m2l)
print('-------------------------------- 122.1')
mineMS2::plotPatterns(m2l, full = TRUE)
print('-------------------------------- 123')
dev.off()

print('-------------------------------- 130')
#### Saving ####

## Exporting annotated network
igraph::write_graph(graph = annotated_net,
                    format = "graphml",
                    file = argVc["annotation_graphml"])

print('-------------------------------- 140')
#### Closing ####

cat("\nEnd of '", modNamC, "' Galaxy module call: ",
    as.character(Sys.time()), "\n", sep = "")

print('-------------------------------- 150')
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

rm(list = ls())
