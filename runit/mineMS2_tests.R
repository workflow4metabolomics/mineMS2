test_input <- function() {

    testDirC <- "input"
    argLs <- list(thresholdVn = "")

    argLs <- c(defaultArgF(testDirC), argLs)
    outLs <- wrapperCallF(argLs)
    
    checkEqualsNumeric(outLs[["datMN"]]["C100a", "M86.0965"], 1365657.4687182, tolerance = 1e-7)
 
}