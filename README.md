
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

y <- log10(x1^2*x2) + rnorm(100, 0, 1)

X <- data.frame(x1=x1, x2=x2)

results <- genetic.search(
  X, y, 
  n.squares=2, 
  max.formula.len = 1, 
  N=2,
  K=10,
  best.vars.l = list(
   c('x1')
  ),
  transformations = list(
    # NB: function applied to standardized X values!
    #     they can be negative
   "log"=function(x, stats){ log(0.1 + abs(stats$min) + x) },
   "exp"=function(x, stats){ exp(x) }
  ),
  keepBest=T,
  cv.norm=F
)
#> [1] "Iteration: 1 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 2 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 3 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 4 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 5 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 6 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 7 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 8 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 9 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 10 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 11 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 12 Mean/Max fitness:-9.60e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 13 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 14 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 15 Mean/Max fitness:-9.60e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 16 Mean/Max fitness:-9.60e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 17 Mean/Max fitness:-9.60e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 18 Mean/Max fitness:-9.80e+07 / 2.05e-03 Best: x1"
#> [1] "Iteration: 19 Mean/Max fitness:-9.60e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 20 Mean/Max fitness:-9.80e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 21 Mean/Max fitness:-9.80e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 22 Mean/Max fitness:-9.80e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 23 Mean/Max fitness:-9.80e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 24 Mean/Max fitness:-9.80e+07 / 3.07e-03 Best: x1"
#> [1] "Iteration: 25 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 26 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 27 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 28 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 29 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 30 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 31 Mean/Max fitness:-8.63e+35 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 32 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 33 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 34 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 35 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 36 Mean/Max fitness:-9.00e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 37 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 38 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 39 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 40 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 41 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 42 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 43 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 44 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 45 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 46 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 47 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 48 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 49 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 50 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 51 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 52 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 53 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 54 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 55 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 56 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 57 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 58 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 59 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 60 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 61 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 62 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 63 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 64 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 65 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 66 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 67 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 68 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 69 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 70 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 71 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 72 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 73 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 74 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 75 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 76 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 77 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 78 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 79 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 80 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 81 Mean/Max fitness:-9.00e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 82 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 83 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 84 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 85 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 86 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 87 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 88 Mean/Max fitness:-8.80e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 89 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 90 Mean/Max fitness:-9.00e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 91 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 92 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 93 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 94 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 95 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 96 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 97 Mean/Max fitness:-9.20e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 98 Mean/Max fitness:-9.40e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 99 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
#> [1] "Iteration: 100 Mean/Max fitness:-9.60e+07 / 8.02e-03 Best: log.mul.x1.x2"
```

The non-linear formula found is really close! We can now get the best
formula

``` r
results$best
#> [1] "log.mul.x1.x2"
```

And all the formula the genetic algorithm found to be best at each one
of the 100 evolution iterations

``` r
results$best.iter
#> [[1]]
#> [1] "x1"
#> 
#> [[2]]
#> [1] "x1"
#> 
#> [[3]]
#> [1] "x1"
#> 
#> [[4]]
#> [1] "x1"
#> 
#> [[5]]
#> [1] "x1"
#> 
#> [[6]]
#> [1] "x1"
#> 
#> [[7]]
#> [1] "x1"
#> 
#> [[8]]
#> [1] "x1"
#> 
#> [[9]]
#> [1] "x1"
#> 
#> [[10]]
#> [1] "x1"
#> 
#> [[11]]
#> [1] "x1"
#> 
#> [[12]]
#> [1] "x1"
#> 
#> [[13]]
#> [1] "x1"
#> 
#> [[14]]
#> [1] "x1"
#> 
#> [[15]]
#> [1] "x1"
#> 
#> [[16]]
#> [1] "x1"
#> 
#> [[17]]
#> [1] "x1"
#> 
#> [[18]]
#> [1] "x1"
#> 
#> [[19]]
#> [1] "x1"
#> 
#> [[20]]
#> [1] "x1"
#> 
#> [[21]]
#> [1] "x1"
#> 
#> [[22]]
#> [1] "x1"
#> 
#> [[23]]
#> [1] "x1"
#> 
#> [[24]]
#> [1] "x1"
#> 
#> [[25]]
#> [1] "log.mul.x1.x2"
#> 
#> [[26]]
#> [1] "log.mul.x1.x2"
#> 
#> [[27]]
#> [1] "log.mul.x1.x2"
#> 
#> [[28]]
#> [1] "log.mul.x1.x2"
#> 
#> [[29]]
#> [1] "log.mul.x1.x2"
#> 
#> [[30]]
#> [1] "log.mul.x1.x2"
#> 
#> [[31]]
#> [1] "log.mul.x1.x2"
#> 
#> [[32]]
#> [1] "log.mul.x1.x2"
#> 
#> [[33]]
#> [1] "log.mul.x1.x2"
#> 
#> [[34]]
#> [1] "log.mul.x1.x2"
#> 
#> [[35]]
#> [1] "log.mul.x1.x2"
#> 
#> [[36]]
#> [1] "log.mul.x1.x2"
#> 
#> [[37]]
#> [1] "log.mul.x1.x2"
#> 
#> [[38]]
#> [1] "log.mul.x1.x2"
#> 
#> [[39]]
#> [1] "log.mul.x1.x2"
#> 
#> [[40]]
#> [1] "log.mul.x1.x2"
#> 
#> [[41]]
#> [1] "log.mul.x1.x2"
#> 
#> [[42]]
#> [1] "log.mul.x1.x2"
#> 
#> [[43]]
#> [1] "log.mul.x1.x2"
#> 
#> [[44]]
#> [1] "log.mul.x1.x2"
#> 
#> [[45]]
#> [1] "log.mul.x1.x2"
#> 
#> [[46]]
#> [1] "log.mul.x1.x2"
#> 
#> [[47]]
#> [1] "log.mul.x1.x2"
#> 
#> [[48]]
#> [1] "log.mul.x1.x2"
#> 
#> [[49]]
#> [1] "log.mul.x1.x2"
#> 
#> [[50]]
#> [1] "log.mul.x1.x2"
#> 
#> [[51]]
#> [1] "log.mul.x1.x2"
#> 
#> [[52]]
#> [1] "log.mul.x1.x2"
#> 
#> [[53]]
#> [1] "log.mul.x1.x2"
#> 
#> [[54]]
#> [1] "log.mul.x1.x2"
#> 
#> [[55]]
#> [1] "log.mul.x1.x2"
#> 
#> [[56]]
#> [1] "log.mul.x1.x2"
#> 
#> [[57]]
#> [1] "log.mul.x1.x2"
#> 
#> [[58]]
#> [1] "log.mul.x1.x2"
#> 
#> [[59]]
#> [1] "log.mul.x1.x2"
#> 
#> [[60]]
#> [1] "log.mul.x1.x2"
#> 
#> [[61]]
#> [1] "log.mul.x1.x2"
#> 
#> [[62]]
#> [1] "log.mul.x1.x2"
#> 
#> [[63]]
#> [1] "log.mul.x1.x2"
#> 
#> [[64]]
#> [1] "log.mul.x1.x2"
#> 
#> [[65]]
#> [1] "log.mul.x1.x2"
#> 
#> [[66]]
#> [1] "log.mul.x1.x2"
#> 
#> [[67]]
#> [1] "log.mul.x1.x2"
#> 
#> [[68]]
#> [1] "log.mul.x1.x2"
#> 
#> [[69]]
#> [1] "log.mul.x1.x2"
#> 
#> [[70]]
#> [1] "log.mul.x1.x2"
#> 
#> [[71]]
#> [1] "log.mul.x1.x2"
#> 
#> [[72]]
#> [1] "log.mul.x1.x2"
#> 
#> [[73]]
#> [1] "log.mul.x1.x2"
#> 
#> [[74]]
#> [1] "log.mul.x1.x2"
#> 
#> [[75]]
#> [1] "log.mul.x1.x2"
#> 
#> [[76]]
#> [1] "log.mul.x1.x2"
#> 
#> [[77]]
#> [1] "log.mul.x1.x2"
#> 
#> [[78]]
#> [1] "log.mul.x1.x2"
#> 
#> [[79]]
#> [1] "log.mul.x1.x2"
#> 
#> [[80]]
#> [1] "log.mul.x1.x2"
#> 
#> [[81]]
#> [1] "log.mul.x1.x2"
#> 
#> [[82]]
#> [1] "log.mul.x1.x2"
#> 
#> [[83]]
#> [1] "log.mul.x1.x2"
#> 
#> [[84]]
#> [1] "log.mul.x1.x2"
#> 
#> [[85]]
#> [1] "log.mul.x1.x2"
#> 
#> [[86]]
#> [1] "log.mul.x1.x2"
#> 
#> [[87]]
#> [1] "log.mul.x1.x2"
#> 
#> [[88]]
#> [1] "log.mul.x1.x2"
#> 
#> [[89]]
#> [1] "log.mul.x1.x2"
#> 
#> [[90]]
#> [1] "log.mul.x1.x2"
#> 
#> [[91]]
#> [1] "log.mul.x1.x2"
#> 
#> [[92]]
#> [1] "log.mul.x1.x2"
#> 
#> [[93]]
#> [1] "log.mul.x1.x2"
#> 
#> [[94]]
#> [1] "log.mul.x1.x2"
#> 
#> [[95]]
#> [1] "log.mul.x1.x2"
#> 
#> [[96]]
#> [1] "log.mul.x1.x2"
#> 
#> [[97]]
#> [1] "log.mul.x1.x2"
#> 
#> [[98]]
#> [1] "log.mul.x1.x2"
#> 
#> [[99]]
#> [1] "log.mul.x1.x2"
#> 
#> [[100]]
#> [1] "log.mul.x1.x2"
```
