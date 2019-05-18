
## Building project `yuml2data`

developing R libraries/packages: ref: refcard - R packages `<url:file:///~/gdrive/mynotes/content/code/cr/cr.md#r=g_10535>`

building and installing `yuml2data` library

opt01: in RStudio:

1. Rstudio > Build and Reload ^+R

opt02: building on R console (for debugging)

``` bash
cd ~/projects/yuml2data/
Rs
``` 

``` r
library(devtools)
devtools::load_all()
library(magrittr)
devtools::build()
devtools::install()
``` 

opt03: building on terminal

``` bash
cd ~/projects/yuml2data
make
``` 

