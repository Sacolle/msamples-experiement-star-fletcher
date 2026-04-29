library(DoE.base)
library(glue)
library(tidyverse)

generate_experiment <- function(factors, replications, seed) {
  DoE.base::fac.design(
    nfactors = length(factors),
    replications = replications,
    repeat.only = FALSE,
    randomize = TRUE,
    seed = seed,
    nlevels = sapply(factors, length),
    factor.names = factors
  )
}

border_size = 4
absorb_size = 8
seed = 0
output = 5
replications = 2


# variar o valor + 24 deve ser divisível por 4, 5 e 8
cpu_factors <- list(
    WithIO = c(0, 1),
	Size = c(80, 120, 160, 200, 240) |> map(\(x) x - 2 * (border_size + absorb_size)),
	Segmentation = c(4, 5, 8), 
	Steps = c(1, 5, 10, 20, 40) 
)
machines = c("poti", "cei", "draco")

generate_experiment(cpu_factors, replications, seed) |> readr::write_csv(glue("./experiments-cpu.csv"))




