#!/bin/bash -x

#Number of burst/background cycles
ITERATIONS=1

#Maximum time to sleep before starting up the workload.  Used to stagger start times.
MAXSLEEP=60
#Initial sleep - don't all start at the same time
SLEEPTIME=$((1 + RANDOM % $MAXSLEEP))
echo sleep $SLEEPTIME

#Some databases are bigger than others.  For a given VM the value of BIGTEST determines
#if the DB is a large or regular DB. The difference between these VMs is in the size of the 
#burst IOPS.
BIGTEST=$((1 + RANDOM % 10))

for i in $(seq 1 $ITERATIONS)
do

if [[ $BIGTEST -ge 0 ]] ; 
then 
    # This is a BIG VM 2 in 10
    BURSTIOPS=$((8000 + RANDOM % 8000))
    READRATE=6000
    BACKGROUNDIOPS=$((10 + RANDOM % 10))
    LOGRATE=$((100 + RANDOM % 500))
else
    # This is a Normal VM 8 in 10
    BURSTIOPS=$((100 + RANDOM % 100))
    READRATE=400
    BACKGROUNDIOPS=$((10 + RANDOM % 10))
    LOGRATE=$((10 + RANDOM % 100))
fi



    #Be careful with small --runtime values as fio needs to fork
    BURSTTIME=$((5 + RANDOM % 20))
    BACKGROUNDTIME=$((15 + RANDOM % 10))
    echo fio --name global \
        --bs=16k \
        --ioengine=libaio \
        --direct=1 \
        --time_based \
        --runtime=$BACKGROUNDTIME \
        --size=2G \
        --name writes \
        --filename=/dev/sdb \
        --rw=randwrite \
        --iodepth=8 \
        --rate_iops=$BACKGROUNDIOPS \
        --name reads \
        --filename=/dev/sdb \
        --size=2G \
        --rw=randread \
        --iodepth=8 \
        --rate_iops=$READRATE \
        --name logwrites \
        --bs=32k \
        --filename=/dev/sdc \
        --size=2G \
        --rw=write \
        --iodepth=1 \
        --rate_iops=$LOGRATE

    echo fio --name global \
        --bs=16k \
        --ioengine=libaio \
        --direct=1 \
        --time_based \
        --runtime=$BURSTTIME \
        --size=2G \
        --name writes \
        --filename=/dev/sdb \
        --rw=randwrite \
        --iodepth=8 \
        --rate_iops=$BURSTIOPS \
        --name reads \
        --filename=/dev/sdb \
        --size=2G \
        --rw=randread \
        --iodepth=8 \
        --rate_iops=$READRATE \
        --name logwrites \
        --bs=32k \
        --filename=/dev/sdc \
        --size=2G \
        --rw=write \
        --iodepth=1 \
        --rate_iops=$LOGRATE
done