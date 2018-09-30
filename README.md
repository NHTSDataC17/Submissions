# 2018-NHTS-Data-Challenge

Working space for NHTS Data Challenge.

## Organization
-  `writeup`: Executive summary with appendix

-  `code`: Any R scripts (`*.R` and `*.Rmd`) and result files (`*.html`).

    - `bootstrap.*`: Comparison of weighted m-out-of-n bootstrap and delete-a-group jackknife resampling.

    - `Cramer_s_V.*`: Correlation bwtween `USES_TNC` and demographic features.

    - `BBN.*`: Bayesian Belief Network of `USES_TNC` and demographic features.

    - `BBN-with-Missing.*`: Missing value imputation and missing pattern encoding in BNN.

    - `Bootstrapped-Poisson-Regression.*`: Bootstrapped Poisson Regression.

    - `Semantic-Analysis.*`: Hierarchical n-gram model of transportation transformation.

    - `data`: Derived variable configuration.

- `summary_output`: Output data, figures and tables.

    - `data`: Markov chain of transportation transformation obtained by partial-pooling model.

    - `fig`: Model visualizations.

    - `table`: Models or methods comparison.

## Install

This project depends on [R](https://cran.r-project.org/). You will need to install several R packages for this project:

```r
# R pipeline of NHTS data
if(!require(summarizeNHTS)){
install.packages('devtools')
devtools::install_github('Westat-Transportation/summarizeNHTS')
require(summarizeNHTS)
}
# List of other packages this project depends on
packages <- c("dplyr","survey","vcd","knitr","bnlearn","Rgraphviz","missForest")
if(!require(packages)){
install.packages(packages)
require(packages)
}
```

## Code running set up

Download [2017 datasets](https://nhts.ornl.gov/downloads) to `~/data/cvs/`, replace `derived_variable_config.csv` and knit `code/*.Rmd`

## Method

- Resampling Fitting

  This work is inspired by the idea of function fitting. Firstly, I chosed a ratio as hyperparameter (in this project, the ratio is 0.1), then I used weighted m-out-of-n bootstrapping to mimic jackknifing, which achieved very close results in estimation and corresponding standard error of marginal and conditional probability (some results are shown in `src/bootstrape.html`). I also compared them in more complicated calculation, like Cramer's V, and I applied this bootstrapping strategy in Bayesian Belief Network and Poisson Regression. One obvious advantage is that bootstrapping returns a distribution so that we have chances to calculate any statistics based on it. Moreover, bootstrapping is known to be consistent in more cases and some modern models/algorithms, such as BBN, are more or less based on it. And for Poisson Regression, bootstrapping is actually the only hope since weighted count is not count variable anymore. So this work broadens and deepens our exploration of survey data.

- Bayesian Belief Network with Missing Pattern:

  BBN could be a useful tool for encoding correlation patterns among TNC usage and demographic features (education level, gender, race, age level and health condition). In order to make the most of data, I firstly applied Random Forrest in nonparametric imputation, and then I generated new boolean variables to encode missing pattern. Finally, I put them all in BBN learning. It turned out that some correlation, like health condition, would be overestimated if simply removing entries with missing value, but education level and age level seem to be reliable strong features.

- Hierarchical Semantic Model:

  This work is inspired by n-gram model in NLP. I used a demographic feature (education level) to build hierarchical models for transportation transformation, and it turned out that partial-pooling model outperformed fully-pooling/non-hierarchical model and no-pooling model.

## Results
- Characteristics & Typologies of TNC Trip Chain

    - Weighted distribution of TNC trip chains

        <p align="center">
        <img src="https://github.com/Yiran6/NHTS_DATA_COMPETITION/blob/master/result/fig/TNC%20trip%20chains.png" alt=""/>
        </p>     

- Bayesian Belief Network with Missing Values

    - Cramer's V

        <p align="center">
        <img src="https://github.com/xiaobw95/2018-NHTS-Data-Challenge/blob/master/result/table/Cramer_s_V_table.png" alt=""/>
        </p>

        <p align="center">
        <img src="https://github.com/xiaobw95/2018-NHTS-Data-Challenge/blob/master/result/fig/Cramer_s_V.PNG" alt=""/>
        </p>

    - BBN without (left) & with (right) missing pattern
        <p align="center">
        <img src="https://github.com/Yiran6/NHTS_DATA_COMPETITION/blob/master/result/fig/BNN_comparison.png" alt=""/>
        </p>

- Bootstrapped Poisson Regression

    - Parameters
        <p align="center">
        <img src="https://github.com/xiaobw95/2018-NHTS-Data-Challenge/blob/master/result/fig/Parameters_Poisson.PNG" alt=""/>
        </p>

- Hierarchical N-gram Model of Transportation Transformation

    - Model Comparison
        <p align="center">
        <img src="https://github.com/xiaobw95/2018-NHTS-Data-Challenge/blob/master/result/table/n-gram.png" alt=""/>
        </p>

    - Partial-pooling Model Visualization (local)
        <p align="center">
        <img src="https://github.com/Yiran6/NHTS_DATA_COMPETITION/blob/master/result/fig/TransportationTransformation.PNG" alt=""/>
        </p>
