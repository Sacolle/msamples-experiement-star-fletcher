#!/bin/bash
#SBATCH --job-name=fletcher
#SBATCH --partition=poti
#SBATCH --nodes=1
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

set -euxo pipefail

BASE_DIR=~/msamples-cpu-star-fletcher

FLAKE_DIR=$BASE_DIR/$(false)

RUN_SCRIPT=$BASE_DIR/inner-run.sh

nix develop $FLAKE_DIR -c bash $RUN_SCRIPT
