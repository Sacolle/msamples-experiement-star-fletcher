
set -eux



RUN_SLURM=${RUN_SLURM:-"run.slurm"}
EXTRA_FILES=$@

EXPERIMENT_FOLDER=${EXPERIMENT_FOLDER:-$(basename $(pwd))}

# make the folder
ssh pcad "mkdir -p ~/$EXPERIMENT_FOLDER"

scp $RUN_SLURM $EXTRA_FILES pcad:~/$EXPERIMENT_FOLDER/
