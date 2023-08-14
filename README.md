
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

## Genetic search

This is a minimum viable example on how to use genetic search to find
the non-linear relationship:

``` r
library(symbolicr)

x1<-runif(100, min=2, max=67)
x2<-runif(100, min=0.01, max=0.1)

y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)

X <- data.frame(x1=x1, x2=x2)

results <- genetic.search(
  X, y, 
  n.squares=2, 
  max.formula.len = 1, 
  N=2,
  K=10,
  best.vars.l = list(
   c('log.x1')
  ),
  transformations = list(
   "log"=function(x, stats){ log(x) },
   "exp"=function(x, stats){ exp(x) }
  ),
  keepBest=T,
  cv.norm=F
)
#> [1] "Iteration: 1 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 2 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 3 Mean/Max fitness:-9.40e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 4 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 5 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 6 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 7 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 8 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 9 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 10 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 11 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 12 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 13 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 14 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 15 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 16 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 17 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 18 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 19 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 20 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 21 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 22 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 23 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 24 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 25 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 26 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 27 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 28 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 29 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 30 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 31 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 32 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 33 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 34 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 35 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 36 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 37 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 38 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 39 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 40 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 41 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 42 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 43 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 44 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 45 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 46 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 47 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 48 Mean/Max fitness:-9.60e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 49 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 50 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 51 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 52 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 53 Mean/Max fitness:-9.80e+07 / 1.64e+00 Best: log.x1"
#> [1] "Iteration: 54 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 55 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 56 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 57 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 58 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 59 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 60 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 61 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 62 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 63 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 64 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 65 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 66 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 67 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 68 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 69 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 70 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 71 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 72 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 73 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 74 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 75 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 76 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 77 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 78 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 79 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 80 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 81 Mean/Max fitness:-9.20e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 82 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 83 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 84 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 85 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 86 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 87 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 88 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 89 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 90 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 91 Mean/Max fitness:-9.20e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 92 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 93 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 94 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 95 Mean/Max fitness:-9.00e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 96 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 97 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 98 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 99 Mean/Max fitness:-9.60e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
#> [1] "Iteration: 100 Mean/Max fitness:-9.40e+07 / 6.23e+00 Best: log.mul.x1.mul.x1.x2"
```

We found the correct non-linear formula starting from an initial guess!
We can now get the best formula

``` r
results$best
#> [1] "log.mul.x1.mul.x1.x2"
```

And all the formula the genetic algorithm found to be best at each one
of the 100 evolution iterations

``` r
results$best.iter
#> [[1]]
#> [1] "log.x1"
#> 
#> [[2]]
#> [1] "log.x1"
#> 
#> [[3]]
#> [1] "log.x1"
#> 
#> [[4]]
#> [1] "log.x1"
#> 
#> [[5]]
#> [1] "log.x1"
#> 
#> [[6]]
#> [1] "log.x1"
#> 
#> [[7]]
#> [1] "log.x1"
#> 
#> [[8]]
#> [1] "log.x1"
#> 
#> [[9]]
#> [1] "log.x1"
#> 
#> [[10]]
#> [1] "log.x1"
#> 
#> [[11]]
#> [1] "log.x1"
#> 
#> [[12]]
#> [1] "log.x1"
#> 
#> [[13]]
#> [1] "log.x1"
#> 
#> [[14]]
#> [1] "log.x1"
#> 
#> [[15]]
#> [1] "log.x1"
#> 
#> [[16]]
#> [1] "log.x1"
#> 
#> [[17]]
#> [1] "log.x1"
#> 
#> [[18]]
#> [1] "log.x1"
#> 
#> [[19]]
#> [1] "log.x1"
#> 
#> [[20]]
#> [1] "log.x1"
#> 
#> [[21]]
#> [1] "log.x1"
#> 
#> [[22]]
#> [1] "log.x1"
#> 
#> [[23]]
#> [1] "log.x1"
#> 
#> [[24]]
#> [1] "log.x1"
#> 
#> [[25]]
#> [1] "log.x1"
#> 
#> [[26]]
#> [1] "log.x1"
#> 
#> [[27]]
#> [1] "log.x1"
#> 
#> [[28]]
#> [1] "log.x1"
#> 
#> [[29]]
#> [1] "log.x1"
#> 
#> [[30]]
#> [1] "log.x1"
#> 
#> [[31]]
#> [1] "log.x1"
#> 
#> [[32]]
#> [1] "log.x1"
#> 
#> [[33]]
#> [1] "log.x1"
#> 
#> [[34]]
#> [1] "log.x1"
#> 
#> [[35]]
#> [1] "log.x1"
#> 
#> [[36]]
#> [1] "log.x1"
#> 
#> [[37]]
#> [1] "log.x1"
#> 
#> [[38]]
#> [1] "log.x1"
#> 
#> [[39]]
#> [1] "log.x1"
#> 
#> [[40]]
#> [1] "log.x1"
#> 
#> [[41]]
#> [1] "log.x1"
#> 
#> [[42]]
#> [1] "log.x1"
#> 
#> [[43]]
#> [1] "log.x1"
#> 
#> [[44]]
#> [1] "log.x1"
#> 
#> [[45]]
#> [1] "log.x1"
#> 
#> [[46]]
#> [1] "log.x1"
#> 
#> [[47]]
#> [1] "log.x1"
#> 
#> [[48]]
#> [1] "log.x1"
#> 
#> [[49]]
#> [1] "log.x1"
#> 
#> [[50]]
#> [1] "log.x1"
#> 
#> [[51]]
#> [1] "log.x1"
#> 
#> [[52]]
#> [1] "log.x1"
#> 
#> [[53]]
#> [1] "log.x1"
#> 
#> [[54]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[55]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[56]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[57]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[58]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[59]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[60]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[61]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[62]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[63]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[64]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[65]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[66]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[67]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[68]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[69]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[70]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[71]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[72]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[73]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[74]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[75]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[76]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[77]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[78]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[79]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[80]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[81]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[82]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[83]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[84]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[85]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[86]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[87]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[88]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[89]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[90]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[91]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[92]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[93]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[94]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[95]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[96]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[97]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[98]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[99]]
#> [1] "log.mul.x1.mul.x1.x2"
#> 
#> [[100]]
#> [1] "log.mul.x1.mul.x1.x2"
```

Note that `cv.norm=FALSE` means data is used as-is. Before running this
example we checked for the non-negativeness of `x1^2*x2`. If you would
like to normalize data to avoid scaling issues just use `cv.norm=TRUE`
but in this case, to avoid computing the log of a negative value, we use
this updated transformation function

``` r
# NB: function applied to standardized X values!
   #     they can be negative
log.std <- function(x, stats){ log(0.1 + abs(stats$min) + x) }
```

The `stats` object contains - min: the minimum of the column values -
absmin: the minimum of the absolute values of the columns - absmax: the
maximum of the absolute values of the columns - projzero: -mean/sd of
the columns, that is the position of the zero in the original,
non-normalized space.

Type `?dataset.min.maxs` in your R console for further informations.

## Random search

This is a minimum viable example on how to use random search to test
multiple non-linear relationships, and get a summary of the performances
in a data.frame:

``` r
library(symbolicr)

x1<-runif(100, min=2, max=67)
x2<-runif(100, min=0.01, max=0.1)

y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)

X <- data.frame(x1=x1, x2=x2)

random.results <- random.search(
  X, y, 
  n.squares=2, 
  formula.len = 1, 
  N=2,
  K=10,
  transformations = list(
   "log"=function(x, stats){ log(x) },
   "exp"=function(x, stats){ exp(x) }
  ),
  cv.norm=F
)
#> [1] "Regression on mul.x2.mul.x1.x2"
#> [1] "Regression on log.mul.x1.mul.x1.x2"
#> [1] "Regression on exp.x1"
#> [1] "Regression on exp.mul.x2.x2"
#> [1] "Regression on log.x1"
#> [1] "Regression on log.mul.x1.mul.x2.x2"
#> [1] "Regression on mul.x1.mul.x2.x2"
#> [1] "Regression on log.mul.x2.mul.x1.x1"
#> [1] "Regression on log.mul.x1.mul.x1.x1"
#> [1] "Regression on log.mul.x1.x1"
#> [1] "Regression on x2"
#> [1] "Regression on mul.x2.mul.x2.x2"
#> [1] "Regression on log.mul.x2.mul.x1.x2"
#> [1] "Regression on exp.mul.x2.mul.x1.x1"
#> [1] "Regression on exp.mul.x2.mul.x2.x2"
#> [1] "Regression on log.mul.x2.mul.x2.x2"
#> [1] "Regression on mul.x1.mul.x1.x1"
#> [1] "Regression on mul.x1.x1"
#> [1] "Regression on exp.mul.x1.x2"
#> [1] "Regression on mul.x2.x2"
#> [1] "Regression on exp.x2"
#> [1] "Regression on exp.mul.x2.mul.x1.x2"
#> [1] "Regression on x1"
#> [1] "Regression on exp.mul.x1.mul.x1.x1"
#> [1] "Regression on log.mul.x2.x2"
#> [1] "Regression on log.x2"
#> [1] "Regression on exp.mul.x1.x1"
#> [1] "Regression on exp.mul.x1.mul.x1.x2"
#> [1] "Regression on mul.x1.x2"
#> [1] "Regression on mul.x1.mul.x1.x2"
#> [1] "Regression on log.mul.x1.x2"
#> [1] "Regression on mul.x2.mul.x1.x1"
#> [1] "Regression on exp.mul.x1.mul.x2.x2"
```

You can then inspect results in the resulting data.frame:

``` r
random.results[order(random.results$base.r.squared, decreasing = T), ][seq(5), ]
#>         base.pe  base.cor base.r.squared base.max.pe  base.iqr.pe
#> 8  0.0005013278 0.9999988      0.9999975  0.01333620 0.0006604573
#> 2  0.0005184434 0.9999987      0.9999975  0.01471447 0.0006729637
#> 31 0.0821789339 0.9522895      0.9068445  2.23304677 0.1286055325
#> 5  0.1161443350 0.9330603      0.8705787  2.03827667 0.1104651939
#> 10 0.1135896970 0.9328216      0.8701419  2.06786746 0.1137251566
#>    base.max.cooksd base.max.cooksd.name                 vars n.squares
#> 8       0.15270689                   83 log.mul.x2.mul.x1.x1         2
#> 2       0.17739167                   83 log.mul.x1.mul.x1.x2         2
#> 31      0.20333684                   69        log.mul.x1.x2         2
#> 5       0.08675262                   78               log.x1         2
#> 10      0.08673111                   78        log.mul.x1.x1         2
#>    formula.len
#> 8            1
#> 2            1
#> 31           1
#> 5            1
#> 10           1
```

## Combinatorial Search

Search over all non-duplicated combinations of terms taken from an
user-supplied list of formulas.

``` r
library(symbolicr)

x1<-runif(100, min=2, max=67)
x2<-runif(100, min=0.01, max=0.1)

y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)

X <- data.frame(x1=x1, x2=x2)

comb.search(
  X, y, 
  formulas.l=list(c('x1','x2'), c('log.x1')), 
  formula.len = 2, 
  N=2,
  K=10,
  transformations = list(
   "log"=function(x, stats){ log(x) },
   "exp"=function(x, stats){ exp(x) }
  ),
  cv.norm=F
)
#> [1] "Regression on log.x1,x1"
#> [1] "Regression on log.x1,x2"
#> [1] "Regression on x1,x2"
#>      base.pe  base.cor base.r.squared base.max.pe base.iqr.pe base.max.cooksd
#> 1 0.12085506 0.9331828      0.8708161    5.809301  0.19876029      0.08074369
#> 2 0.04013426 0.9946764      0.9893792    1.700739  0.03440265      0.10840776
#> 3 0.10921491 0.9301860      0.8652096    7.720164  0.12722777      0.29758252
#>   base.max.cooksd.name      vars n.squares formula.len
#> 1                 6,79 log.x1,x1         1           2
#> 2                   29 log.x1,x2         1           2
#> 3                  100     x1,x2         1           2
```
