set -euxo pipefail

ROOT=~/cuda-fletcher-base
CSV_FILENAME=
SCRATCH_OUTPUT_FOLDER=
HOME_OUT=~/fletcher-base-experiment-output


CSV_FILE=$ROOT/$CSV_FILENAME
mapfile -t csv_lines < <(tail -n +2 "$CSV_FILE")

# setup the output
OUTFOLDER=$(printf "%s%s" "$SCRATCH" "$SCRATCH_OUTPUT_FOLDER")
mkdir -p $OUTFOLDER

# path to executable
MAINPATH=$ROOT/Star-Fletcher

cd $MAINPATH

echo "building the final program"

make

echo "Running the tests..."

for line in "${csv_lines[@]}"; do
    [[ -z "$line" ]] && continue # skip empty

    # depend on the experimental project
    IFS=',' read -r size output <<< "$line"

    echo "============================="
    echo "  Size: $size"
    echo "  Output: $output"
    echo "============================="


    FILENAME=$(printf "%s_%s" "$size" "$output")
    
    dt=0.0005
    totalsteps=10
    t=$(awk "BEGIN { print $dt * $totalsteps }")
    absorption=16
    dtoutput=$(awk "BEGIN { print $dt * $output }")

    OUTPUT_FOLDER=$OUTFOLDER \
    OUTPUT_FILE=$FILENAME \
    ./main $size $size $size \
    $absorption 12.5 12.5 12.5 $dt $t $dtoutput 2>&1 > $OUTFOLDER/$FILENAME.out

    cat $OUTFOLDER/$FILENAME.out

    chmod u+rw $OUTFOLDER/out-$FILENAME.rsf@
done


echo "retriving the experimental results"

# retrive the resources in the scratch folder
mkdir -p $HOME_OUT

cp $OUTFOLDER/* $HOME_OUT


echo "done"

