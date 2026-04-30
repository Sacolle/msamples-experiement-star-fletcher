#!/bin/bash
#SBATCH --job-name=star-fletcher-msamples
#SBATCH --partition=cei
#SBATCH --nodes=1
#SBATCH --time=08:00:00
#SBATCH --output=cei.out
#SBATCH --error=cei.err

set -euxo pipefail

#%x_%j.err


FLAKE_DIR=~/Star-Fletcher

EXPERIMENT_DIR=~/msample-experiments/

RUN_SCRIPT=$(nix build $EXPERIMENT_DIR --no-link --print-out-paths)/bin/run-experiment

nix develop $FLAKE_DIR -c bash $RUN_SCRIPT
