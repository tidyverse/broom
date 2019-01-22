# broom 0.5.1.9000
To be released as 0.7.0

## Changes to `augment()`

- If you pass a dataset to `augment()` via the `data` or `newdata` arguments, you are now guaranteed that the augmented dataset will have exactly the same number of rows as the original dataset. This differs from previous behavior primarily when there are missing values. Previously `augment()` would drop rows containing `NA`. This should no longer be the case.

- Similarly: augment no longer accepts an `na.action` argument (TODO: figure out why this wasn't in the function signature in the first place)

- lm augment loses a lot of arguments 

- augment tries gives an informative error when `data` isn't the original training data

- `augment.glmRob()` has been removed from broom. We regret that we were unable to provide any warning for this change. The `robust` package does not provide the functionality necessary to implement an augment method. We are looking into supporting the `robustbase` package in the future.

in the augment method for the chi sq test, .residuals column was renamed to .resid and .stdres column was renamed to .std.resid

## Other changes

- tidy.lsmobj gains a `conf.int` argument.
- tidy.survreg gains a `conf.int` argument which is set to FALSE by default. Note that previously this function always included confidence intervals in its output.
- Add `tidy.regsubsets()` for best subsets linear regression from the `leaps` package
- All `conf.int` arguments now default to `FALSE`.
- All `conf.level` arguments now default to `TRUE`.
- Moved core tests to the `modeltests` package
- Import `tidy()`, `glance()` and `augment()` generics from `modelgenerics`
- Added new vignette detailing use of `modelgenerics` and `modeltests` packages
- Added `data` argument to `augment()` generic (did this happen?)
- tidy.kmeans now defaults to using variable names in output columns
- Bug fix for tidy.ridgelm returning inconsistent columns (#532)
- Correct output for  `tidy.mlm(, quick=TRUE)`, add tests (#539 by @MatthieuStigler)
- `tidy_optim()` provides the standard error if the Hessian is present. (#529 by @billdenney)
- Added default arugment of newdata=NULL to augment.prcomp and augment.rqs (#543)
- Added default arugment of data=NULL to augment.factanal and augment.kmeans (#543)
- Added default arugments for type.predict and type.residuals to augment.betareg that correspond to default arguments for betareg (#543)
- Removed coercion warning for augment.factanal (#543)
- Added method `tidy.lm.beta()` to tidy `lm.beta` class models (#545 by @mattle24)
- Add feature for glance.biglm to return df.residual
- Patch bug in glance.lavaan (#577)

## Deprecations

- Data frame, rowwise data frame, vector and matrix tidiers have been removed
- `bootstrap()` has been removed

- `tidy.table()` and `tidy.ftable()` have been deprecated in favor of `tibble::as_tibble()`
- `tidy.summaryDefault()` has been deprecated in favor of `skimr::skim()`

### Mixed model deprecations

The following have all been deprecated in favor of `broom.mixed`:

- `tidy.brmsfit()`
- `tidy.merMod()`, `glance.merMod()`, `augment.merMod()`
- `tidyMCMC()`, `tidy.rjags()`, `tidy.stanfit()`
- `tidy.lme()`, `glance.lme()`, `augment.lme()`
- `tidy.stanreg()`, `glance.stanreg()`

## Other changes

- Bug fix for `tidy.polr()` for incorrectly using colnames. (#498)

# broom 0.5.0

Tidiers now return `tibble::tibble()`s. This release also includes several new tidiers, new vignettes and a large number of bugfixes. We've also begun to more rigorously define tidier specifications: we've laid part of the groundwork for stricter and more consistent tidying, but the new tidier specifications are not yet complete. These will appear in the next release.

Additionally, users should note that we are in the process of migrating tidying methods for mixed models and Bayesian models to `broom.mixed`. `broom.mixed` is not on CRAN yet, but all mixed model and Bayesian tidiers will be deprecated once `broom.mixed` is on CRAN. No further development of mixed model tidiers will take place in `broom`.

## Breaking changes

Almost all tidiers should now return `tibble`s rather than `data.frame`s. Deprecated tidying methods, Bayesian and mixed model tidiers still return `data.frame`s.

**Users** are mostly to experience issues when using `augment` in situations where tibbles are stricter than data frames. For example, specifying model covariates as a matrix object will now error:

```r
library(broom)
library(quantreg)

fit <- rq(stack.loss ~ stack.x, tau = .5)
broom::augment(fit)
#> Error: Column `stack.x` must be a 1d atomic vector or a list
```

This is because the default `data` argument `data = model.frame(fit)` cannot be coerced to `tibble`.

Another consequence of this is that `augment.survreg` and `augment.coxph` from the `survival` package now require that the user explicitly passes data to either the `data` or `newdata` arguments.

These restrictions will be relaxed in an upcoming release of `broom` pending support for matrix-columns in tibbles.

**Developers** are likely to experience issues:

- subsetting tibbles with `[`, which returns a tibble rather than a vector.
- setting rownames on tibbles, which is deprecated.
- using matrix and vector tidiers, now deprecated.
- handling the additional tibble classes `tbl_df` and `tbl` beyond the `data.frame` class
- linking to defunct documentation files -- broom recently moved all tidiers to a `roxygen2` template based documentation system.

## New vignettes

This version of `broom` includes several new vignettes:

- `vignette("available-methods", package = "broom")` contains a table detailing which tidying methods are available
- `vignette("adding-tidiers", package = "broom")` is an *in-progress* guide for contributors on how to add new tidiers to broom
- `vignette("glossary", package = "broom")` contains tables describing acceptable argument names and column names for the *in-progress* new specification.

Several old vignettes have also been updated:

- `vignette("bootstrapping", package = "broom")` now relies on the `rsample` package and a `tidyr::nest`-`purrr::map`-`tidyr::unnest` workflow. This is now the recommended workflow for working with multiple models, as opposed to the old `dplyr::rowwise`-`dplyr::do` based workflow.

## Deprecations

- Matrix and vector tidiers have been deprecated in  favor of `tibble::as_tibble` and `tibble::enframe`
- Dataframe tidiers and rowwise dataframe tidiers have been deprecated
- `bootstrap()` has been deprecated in favor of the [`rsample`](https://tidymodels.github.io/rsample/)
- `inflate` has been removed from `broom`

## Other changes

- The `alpha` argument has been removed from `quantreg` tidy methods
- The `separate.levels` argument has been removed from `tidy.TukeyHSD`. To obtain the effect of `separate.levels = TRUE`, users may `tidyr::separate` after tidying. This is consistent with the `multcomp` tidier behavior.
- The `fe.error` argument was removed from `tidy.felm`. When fixed effects are tidier, their standard errors are now always included.
- The `diag` argument in `tidy.dist` has been renamed `diagonal`
- Advice to help beginners make PRs (#397 by @karldw)
- `glance` support for `arima` objects fit with `method = "CSS"` (#396 by @josue-rodriguez)
- A bug fix to re-enable tidying `glmnet` objects with `family = multinomial` (#395 by @erleholgersen)
- A bug fix to allow tidying `quantreg` intercept only models (#378 by @erleholgersen)
- A bug fix for `aovlist` objects (#377 by @mvevans89)
- Support for `glmnetUtils` objects (#352 by @Hong-Revo)
- A bug fix to allow `tidy_emmeans` to handle column names with dashes (#351 by @bmannakee)
- `augment.felm` no longer returns `.fe_` and `.comp` columns
- Support saved formulas in `augment.felm` (#347 by @ShreyasSingh)
- `confint_tidy` now drops rows of all `NA` (#345 by @atyre2)
- A new tidier for `caret::confusionMatrix` objects (#344 by @mkuehn10)
- Tidiers for `Kendall::Kendall` objects (#343 by @cimentadaj)
- A new tidying method for `car::durbinWatsonTest` objects (#341 by @mkuehn10)
- `glance` throws an informative error for `quantreg:rq` models fit with multiple `tau` values (#338 by @bfgray3)
- `tidy.glmnet` gains the ability to retain zero-valued coefficients with a `return_zeros` argument that defaults to `FALSE` (#337 by @bfgray3)
- `tidy.manova` now retains a `Residuals` row (#334 by @jarvisc1)
- Tidiers for `ordinal::clm`, `ordinal::clmm`, `survey::svyolr` and `MASS::polr` ordinal model objects (#332 by @larmarange)
- Support for `anova` objects from `car::Anova` (#325 by @mariusbarth)
- Tidiers for `tseries::garch` models (#323 by @wilsonfreitas)
- Removed dependency on `psych` package (#313 by @nutterb)
- Improved error messages (#303 by @michaelweylandt)
- Compatibility with new `rstanarm` and `loo` packages (#298 by @jgabry)
- Support for tidying lists return by `irlba::irlba`
- A truly huge increase in unit tests (#267 by @dchiu911)
- Bug fix for `tidy.prcomp` when missing labels (#265 by @corybrunson)
- Added a `pkgdown` site at https://broom.tidyverse.org/ (#260 by @jayhesselberth)
- Added tidiers for `AER::ivreg` models (#247 by @hughjonesd)
- Added tidiers for the `lavaan` package (#233 by @puterleat)
- Added `conf.int` argument to `tidy.coxph` (#220 by @larmarange)
- Added `augment` method for chi-squared tests (#138 by @larmarange)
- changed default se.type for `tidy.rq` to match that of `quantreg::summary.rq()` (#404 by @ethchr)
- Added argument `quick` for  `tidy.plm` and `tidy.felm` (#502 and #509 by @MatthieuStigler)
- Many small improvements throughout


## Contributors

Many many thanks to all the following for their thoughtful comments on design, bug reports and PRs! The community of broom contributors has been kind, supportive and insightful and I look forward to working you all again!

[@atyre2](https://github.com/atyre2), [@batpigandme](https://github.com/batpigandme), [@bfgray3](https://github.com/bfgray3), [@bmannakee](https://github.com/bmannakee), [@briatte](https://github.com/briatte), [@cawoodjm](https://github.com/cawoodjm), [@cimentadaj](https://github.com/cimentadaj), [@dan87134](https://github.com/dan87134), [@dgrtwo](https://github.com/dgrtwo), [@dmenne](https://github.com/dmenne), [@ekatko1](https://github.com/ekatko1), [@ellessenne](https://github.com/ellessenne), [@erleholgersen](https://github.com/erleholgersen),
[@ethchr](https://github.com/ethchr),
[@Hong-Revo](https://github.com/Hong-Revo), [@huftis](https://github.com/huftis), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jacob-long](https://github.com/jacob-long), [@jarvisc1](https://github.com/jarvisc1), [@jenzopr](https://github.com/jenzopr), [@jgabry](https://github.com/jgabry), [@jimhester](https://github.com/jimhester), [@josue-rodriguez](https://github.com/josue-rodriguez), [@karldw](https://github.com/karldw), [@kfeilich](https://github.com/kfeilich), [@larmarange](https://github.com/larmarange), [@lboller](https://github.com/lboller), [@mariusbarth](https://github.com/mariusbarth), [@michaelweylandt](https://github.com/michaelweylandt), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mkuehn10](https://github.com/mkuehn10), [@mvevans89](https://github.com/mvevans89), [@nutterb](https://github.com/nutterb), [@ShreyasSingh](https://github.com/ShreyasSingh), [@stephlocke](https://github.com/stephlocke), [@strengejacke](https://github.com/strengejacke), [@topepo](https://github.com/topepo), [@willbowditch](https://github.com/willbowditch), [@WillemSleegers](https://github.com/WillemSleegers),  [@wilsonfreitas](https://github.com/wilsonfreitas), and
[@MatthieuStigler](https://github.com/MatthieuStigler)

# broom 0.4.4

* Fixed gam tidiers to work with "Gam" objects, due to an update in gam 1.15. This fixes failing CRAN tests
* Improved test coverage (thanks to #267 from Derek Chiu)

# broom 0.4.3

* Changed the deprecated `dplyr::failwith` to `purrr::possibly`
* `augment` and `glance` on NULLs now return an empty data frame
* Deprecated the `inflate()` function in favor of `tidyr::crossing`
* Fixed confidence intervals in the gmm tidier (thanks to #242 from David Hugh-Jones)
* Fixed a bug in bootstrap tidiers (thanks to #167 from Jeremy Biesanz)
* Fixed tidy.lm with `quick = TRUE` to return terms as character rather than factor (thanks to #191 from Matteo Sostero)
* Added tidiers for `ivreg` objects from the AER package (thanks to #245 from David Hugh-Jones)
* Added tidiers for `survdiff` objects from the survival package (thanks to #147 from Michał Bojanowski)
* Added tidiers for `emmeans` from the emmeans package (thanks to #252 from Matthew Kay)
* Added tidiers for `speedlm` and `speedglm` from the speedglm package (thanks to #248 from David Hugh-Jones)
* Added tidiers for `muhaz` objects from the muhaz package (thanks to #251 from Andreas Bender)
* Added tidiers for `decompose` and `stl` objects from stats (thanks to #165 from Aaron Jacobs)

# broom 0.4.2

* Added tidiers for `lsmobj` and `ref.grid` objects from the lsmeans package
* Added tidiers for `betareg` objects from the betareg package
* Added tidiers for `lmRob` and `glmRob` objects from the robust package
* Added tidiers for `brms` objects from the brms package (thanks to #149 from Paul Buerkner)
* Fixed tidiers for orcutt 2.0
* Changed `tidy.glmnet` to filter out rows where estimate == 0.
* Updates to `rstanarm` tidiers (thanks to #177 from Jonah Gabry)
* Fixed issue with survival package 2.40-1 (thanks to #180 from Marcus Walz)

# broom 0.4.1

* Added AppVeyor, codecov.io, and code of conduct
* Changed name of "NA's" column in summaryDefault output to "na"
* Fixed `tidy.TukeyHSD` to include `term` column. Also added `separate.levels` argument, with option to separate `comparison` into `level1` and `level2`
* Fixed `tidy.manova` to use correct column name for test (previously, always `pillai`)
* Added `kde_tidiers` to tidy kernel density estimates
* Added `orcutt_tidiers` to tidy the results of `cochrane.orcutt` orcutt package
* Added `tidy.dist` to tidy the distance matrix output of `dist` from the stats package
* Added `tidy` and `glance` for `lmodel2` objects from the lmodel2 package
* Added tidiers for `poLCA` objects from the poLCA package
* Added tidiers for sparse matrices from the Matrix package
* Added tidiers for `prcomp` objects
* Added tidiers for `Mclust` objects from the Mclust package
* Added tidiers for `acf` objects
* Fixed to be compatible with dplyr 0.5, which is being submitted to CRAN

# broom 0.4.0

* Added tidiers for geeglm, nlrq, roc, boot, bgterm, kappa, binWidth, binDesign, rcorr, stanfit, rjags, gamlss, and mle2 objects.
* Added `tidy` methods for lists, including u, d, v lists from `svd`, and x, y, z lists used by `image` and `persp`
* Added `quick` argument to `tidy.lm`, `tidy.nls`, and `tidy.biglm`, to create a smaller and faster version of the output.
* Changed `rowwise_df_tidiers` to allow the original data to be saved as a list column, then provided as a column name to `augment`. This required removing `data` from the `augment` S3 signature. Also added `tests-rowwise.R`
* Fixed various issues in ANOVA output
* Fixed various issues in lme4 output
* Fixed issues in tests caused by dev version of ggplot2

# broom 0.3.7

* Added tidiers for "plm" (panel linear model) objects from the plm package.
* Added `tidy.coeftest` for coeftest objects from the lmtest package.
* Set up `tidy.lm` to work with "mlm" (multiple linear model) objects (those with multiple response columns).
* Added `tidy` and `glance` for "biglm" and "bigglm" objects from the biglm package.
* Fixed bug in `tidy.coxph` when one-row matrices are returned
* Added `tidy.power.htest`
* Added `tidy` and `glance` for `summaryDefault` objects
* Added tidiers for "lme" (linear mixed effects models) from the nlme package
* Added `tidy` and `glance` for `multinom` objects from the nnet package.

# broom 0.3.6

* Fixed bug in `tidy.pairwise.htest`, which now can handle cases where the grouping variable is numeric.
* Added `tidy.aovlist` method. This added `stringr` package to IMPORTS to trim whitespace from the beginning and end of the `term` and `stratum` columns. This also required adjusting `tidy.aov` so that it could handle strata that are missing p-values.
* Set up `glance.lm` to work with `aov` objects along with `lm` objects.
* Added `tidy` and `glance` for matrix objects, with `tidy.matrix` converting a matrix to a data frame with rownames included, and `glance.matrix` returning the same result as `glance.data.frame`.
* Changed DESCRIPTION Authors@R to new format

# broom 0.3.5

* Fixed small bug in `felm` where the `.fitted` and `.resid` columns were matrices rather than vectors.
* Added tidiers for `rlm` (robust linear model) and `gam` (generalized additive model) objects, including adjustments to "lm" tidiers in order to handle them. See `?rlm_tidiers` and `?gam_tidiers` for more.
* Removed rownames from `tidy.cv.glmnet` output

# broom 0.3.4

* The behavior of `augment`, particularly with regard to missing data and the `na.exclude` argument, has through the use of the `augment_columns` function been made consistent across the following models:
    * `lm`
    * `glm`
    * `nls`
    * `merMod` (`lme4`)
    * `survreg` (`survival`)
    * `coxph` (`survival`)

    Unit tests in `tests/testthat/test-augment.R` were added to ensure consistency across these models.
* `tidy`, `augment` and `glance` methods were added for `rowwise_df` objects, and are set up to apply across their rows. This allows for simple patterns such as:

        regressions <- mtcars %>% group_by(cyl) %>% do(mod = lm(mpg ~ wt, .))
        regressions %>% tidy(mod)
        regressions %>% augment(mod)

    See `?rowwise_df_tidiers` for more.
* Added `tidy` and `glance` methods for `Arima` objects, and `tidy` for `pairwise.htest` objects.
* Fixes for CRAN: change package description to title case, removed NOTES, mostly by adding `globals.R` to declare global variables.
* This is the original version published on CRAN.


# broom 0.3

* Tidiers have been added for S3 objects from the following packages:
    * `lme4`
    * `glmnet`
    * `survival`
    * `zoo`
    * `felm`
    * `MASS` (`ridgelm` objects)
* `tidy` and `glance` methods for data.frames have also been added, and `augment.data.frame` produces an error (rather than returning the same data.frame).
* `stderror` has been changed to `std.error` (affects many functions) to be consistent with broom's naming conventions for columns.
* A function `bootstrap` has been added based on [this example](https://github.com/hadley/dplyr/issues/269), to perform the common use case of bootstrapping models.

# broom 0.2

* Added "augment" S3 generic and various implementations. "augment" does something different from tidy: it adds columns to the original dataset, including predictions, residuals, or cluster assignments. This was originally described as "fortify" in ggplot2.
* Added "glance" S3 generic and various implementations. "glance" produces a *one-row* data frame summary, which is necessary for tidy outputs with values like R^2 or F-statistics.
* Re-wrote intro broom vignette/README to introduce all three methods.
* Wrote a new kmeans vignette.
* Added tidying methods for multcomp, sp, and map objects (from fortify-multcomp, fortify-sp, and fortify-map from ggplot2).
* Because this integrates substantial amounts of ggplot2 code (with permission), added Hadley Wickham as an author in DESCRIPTION.
