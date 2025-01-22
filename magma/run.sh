#!/bin/bash

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
# - env POLL: time (in seconds) to sleep between polls
# - env TIMEOUT: time to run the campaign
# - env MAGMA: path to Magma support files
# + env LOGSIZE: size (in bytes) of log file to generate (default: 1 MiB)
##

# set default max log size to 1 MiB
LOGSIZE=${LOGSIZE:-$[1 << 20]}

export MONITOR="$SHARED/monitor"
mkdir -p "$MONITOR"

# change working directory to somewhere accessible by the fuzzer and target
cd "$SHARED"

# prune the seed corpus for any fault-triggering test-cases
seeds=($(find "$TARGET/corpus/$PROGRAM" -type f))
for seed in "${seeds[@]}"; do
    out="$("$MAGMA"/runonce.sh "$seed")"
    code=$?

    if [ $code -ne 0 ]; then
        echo "$seed: $out"
        rm "$seed"
    fi
done

seeds=($(find "$TARGET/corpus/$PROGRAM" -type f))
if [ ${#seeds[@]} -eq 0 ]; then
    echo "No seeds remaining! Campaign will not be launched."
    exit 1
fi


# launch the fuzzer in parallel with the monitor
rm -f "$MONITOR/tmp"*
polls=("$MONITOR"/*)
if [ ${#polls[@]} -eq 0 ]; then
    counter=0
else
    timestamps=($(sort -n < <(basename -a "${polls[@]}")))
    last=${timestamps[-1]}
    counter=$(( last + POLL ))
fi

while true; do
    "$OUT/monitor" --dump row > "$MONITOR/tmp"
    if [ $? -eq 0 ]; then
        mv "$MONITOR/tmp" "$MONITOR/$counter"
    else
        rm "$MONITOR/tmp"
    fi
    counter=$(( counter + POLL ))
    sleep $POLL
done &

echo "Campaign launched at $(date '+%F %R')"

# use process substitution to start multilog
timeout $TIMEOUT "$FUZZER/run.sh" > >(multilog n2 s$LOGSIZE "$SHARED/log") &
RUN_PID=$!

echo "RUN_PID: $RUN_PID"

echo "Running jobs: $(jobs -l)"

while kill -0 $RUN_PID 2>/dev/null; do
    if [ -f "/tmp/magma_bug_t" ]; then
        echo "Termination signal received, stopping fuzzer..."
        kill $RUN_PID
        break
    fi
    sleep $(( POLL * 2 ))
done

sleep 2
if kill -0 $RUN_PID 2>/dev/null; then
    echo "Fuzzer did not terminate, killing it..."
    kill -9 $RUN_PID
fi

echo "Campaign terminated at $(date '+%F %R')"

echo "Still running jobs: $(jobs -l)"

kill $(jobs -p)
