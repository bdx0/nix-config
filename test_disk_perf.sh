lsblk -d -o NAME,ROTA,SCHED
fio --name=test \
    --filename=/dev/sdb \
    --rw=write \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --size=2G \
    --runtime=60 \
    --time_based \
    --ioengine=libaio \
    --direct=1 \
    --unlink=1

fio --name=write_throughput \
    --directory=/srv/mergerfs/storage/ \
    --numjobs=16 --size=10G \
    --time_based \
    --runtime=1m \
    --ramp_time=2s \
    --ioengine=libaio \
    --direct=1 \
    --verify=0 \
    --bs=1M \
    --iodepth=64 \
    --rw=write \
    --group_reporting=1 \
    --iodepth_batch_submit=64 \
    --iodepth_batch_complete=64

fio --name=test-vdb \
    --file=/dev/vdb \
    --direct=1 \
    --rw=randread \
    --bs=4k \
    --size=1G \
    --numjobs=4 \
    --time_based \
    --runtime=30s \
    --group_reporting

# mixed read/write
fio --name=rw-mix \
    --filename=/dev/vdb \
    --direct=1 \
    --rw=randrw \
    --rwmixread=70 \
    --bs=4k \
    --size=1G \
    --numjobs=4 \
    --time_based \
    --runtime=30s \
    --group_reporting
