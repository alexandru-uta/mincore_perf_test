#!/bin/bash

# Script that runs a parameter sweep for the rust program defined in
# this project. The script returns a csv file with the results of the
# following type:
# region_size, percentage_pages, mprotect_granularity, time

# The output of the rust program is something like:
# 0.04434
# the time is in seconds.

# The script receives one argument, which is the output file where the
# results will be stored.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <output_file>"
    exit 1
fi

cargo build --release

REGION_SIZES=(1 2 4 8 10 12 16)
PERCENTAGES=(1 5 10 20 25 50)
MPROTECT_GRANULARITY=(1 2 4 8 16 32 64 128)

OUTPUT_FILE=$1

echo "region_size,percentage_pages,mprotect_granularity,time" > $OUTPUT_FILE

for region_size in ${REGION_SIZES[@]}; do
    for percentage in ${PERCENTAGES[@]}; do
        for mprotect_granularity in ${MPROTECT_GRANULARITY[@]}; do
            echo "Running with region_size: $region_size, percentage: $percentage, mprotect_granularity: $mprotect_granularity"
            runtime=`./target/release/mincore_perf_test --region-size=${region_size} --percentage-pages=${percentage} --mprotect-granularity=${mprotect_granularity}`
            
            echo "$region_size,$percentage,$mprotect_granularity,$runtime" >> $OUTPUT_FILE
        done
    done
done
