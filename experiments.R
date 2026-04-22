library(DoE.base)
library(tidyverse)

generate_experiment <- function(factors, seed, path) {
  replications <- 5
  DoE.base::fac.design(
    nfactors = length(factors),
    replications = replications,
    repeat.only = FALSE,
    blocks = 1,
    randomize = TRUE,
    seed = seed,
    nlevels = sapply(factors, length),
    factor.names = factors
  ) |> readr::write_csv(path)
}

seed <- 0
cpu_factors <- list(
  Output = c(1, 5, 10) # how many steps to save the code
  #Segmentation = c(4, 8, 12)
)
generate_experiment(cpu_factors, seed, "./fletcher-base-experiments.csv")


