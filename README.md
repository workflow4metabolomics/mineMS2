mineMS2: Annotation of spectral libraries with exact fragmentation patterns
===========================================================================

A Galaxy module from the [Workflow4metabolomics](http://workflow4metabolomics.org) infrastructure.  

Status: [![Build Status](https://travis-ci.org/workflow4metabolomics/mineMS2.svg?branch=master)](https://travis-ci.org/workflow4metabolomics/mineMS2).

### Description

**Version:** 0.0.0  
**Date:** 2019-01-19  
**Author:** Alexis Delabriere and Etienne A. Thevenot (CEA, LIST, MetaboHUB, W4M Development Core Team)   
**Email:** [alexis.delabriere(at)hotmail.fr](mailto:alexis.delabriere@hotmail.fr) and [etienne.thevenot(at)cea.fr](mailto:etienne.thevenot@cea.fr)  
**Citation:** Delabriere A., Hautbergue T., ..., Junot C., Fenaille F. and Thevenot E.A. (submitted). *mineMS2*: Annotation of spectral libraries with exact fragmentation patterns.  
**Licence:** CeCILL 
<!-- **Reference history:** [W4M00001a_sacurine-subset-statistics](http://galaxy.workflow4metabolomics.org/history/list_published), [W4M00001b_sacurine_complete](http://galaxy.workflow4metabolomics.org/history/list_published)     -->
**Funding:** CEA

### Installation

* Configuration file: `mineMS2_config.xml` 

<!-- * Image files:
  + `static/images/multivariate_workflowPositionImage.png`
  + `static/images/multivariate_workingExampleImage.png` -->
  
* Wrapper file: `mineMS2_wrapper.R` 
* R packages  
  + **batch** from CRAN  
  
    ```r
    install.packages("batch", dep=TRUE)  
    ```

  + **mineMS2** from Github  
  
    ```r
    install.packages("devtools")  
    devtools::install_github("https://github.com/adelabriere/mineMS2")      
   ```

  + **igraph** from CRAN  
  
    ```r
    install.packages("igraph", dep=TRUE)  
    ```

<!--
### Tests

The code in the wrapper can be tested by running the `runit/mineMS2_runtests.R` R file

You will need to install **RUnit** package in order to make it run:
```r
install.packages('RUnit', dependencies = TRUE)
```

### Working example

See the **W4M00001a_sacurine-subset-statistics**, **W4M00001b_sacurine-subset-complete**, **W4M00002_mtbls2**, **W4M00003_diaplasma** shared histories in the **Shared Data/Published Histories** menu (https://galaxy.workflow4metabolomics.org/history/list_published)
-->

### News  

###### CHANGES IN VERSION 0.0.0  

STATUS  

 * The development of this tool is in progress.  