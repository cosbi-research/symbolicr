
<!-- README.md is generated from README.Rmd. Please edit that file -->

# symbolicR

<!-- badges: start -->
<!-- badges: end -->

Find non-linear formulas that fits your input data. You can
systematically explore and memoize the possible formulas and it’s
cross-validation performance, in an incremental fashon. Two
interoperable search functions are available:

-   `random.search` performs a random exploration,
-   `genetic.search` employs a genetic optimization algorithm

## Installation

You can install the development version of symbolicr like so:

``` r
devtools::install_gitlab('COSBI/symbolicr', host='source.cosbi.eu', auth_token='glpat-....')
```

If you don’t have an auth token, login to source.cosbi.eu and generate
one by following [this
guide](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token).

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(symbolicr)

x1<-runif(100, min=2, max=67)
x2<-runif(100, min=0.01, max=0.1)

y <- log10(x1^2*x2)

X <- data.frame(x1=x1, x2=x2)
```
