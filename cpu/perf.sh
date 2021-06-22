mpstat -P ALL 1 60 > mpstat.log &
sudo perf record -a -- sleep 60
sleep 2
sudo perf report --sort comm -n --show-cpu-utilization --stdio > perf_commands.log
sudo perf report --sort comm,dso -n --show-cpu-utilization --stdio > perf_libs.log
sudo perf report --sort symbol -n --show-cpu-utilization --stdio > perf_symbols.log
