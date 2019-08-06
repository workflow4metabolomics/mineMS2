test_input <- function() {

    testDirC <- "input"
    argLs <- list(spectra_mgf = "ex_mgf.mgf",
                  network_graphml = "ex_gnps_network.graphml",
                  thresholdVn = "")

    argLs <- c(defaultArgF(testDirC), argLs)
    outLs <- wrapperCallF(argLs)

    checkIdentical(outLs[["annVc"]][35],
                   "      <data key=\"v_precursor mass\">377.16</data>")
}
