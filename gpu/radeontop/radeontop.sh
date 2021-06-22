#!/bin/bash  

# Notes:
#  There are 2 versions of radeontop that provide different capabilities
#  radeontop_version1 - collect GPU utilization data for both AMD GPU's.  This version doesn't output video encoding info
#  radeontop_version2 - collect GPU video encoding utilization data for one of the AMD GPU's.
#

# how long to collect data for in seconds
#DURATION=120
DURATION=60

# is a useful one-liner which will give you the full directory name of the script no matter where it is being called from.
# https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# copied these libs that radeontop uses to libs subdir: libdrm.so.2  libpciaccess.so.0  libtinfo.so.5
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${DIR}/libs

EXE_VERSION1=${DIR}/radeontop_version1
EXE_VERSION2=${DIR}/radeontop_version2
if [ ! -f ${EXE_VERSION1} ] ; then
    echo "Cannot find EXE_VERSION1=${EXE_VERSION1}.  Will exit"
    exit 1
fi
if [ ! -f ${EXE_VERSION2} ] ; then
    echo "Cannot find EXE_VERSION2=${EXE_VERSION2}.  Will exit"
    exit 1
fi

   
### 
# Find 3x GPU cards on your system
### 
TMPFILE=$(mktemp /tmp/tmp.XXXXXX)
sudo lspci | grep Adv | grep VGA >& ${TMPFILE}
BUS0=$( cat ${TMPFILE} | head -1 | awk -F: '{print $1}')
DEV0=$( cat ${TMPFILE} | head -1 | awk -F: '{print $2}')
BUS1=$( cat ${TMPFILE} | head -2 | tail -1 | awk -F: '{print $1}')
DEV1=$( cat ${TMPFILE} | head -2 | tail -1 | awk -F: '{print $2}')
#BUS2=$( cat ${TMPFILE} | tail -3 | tail -1 | awk -F: '{print $1}')
#DEV2=$( cat ${TMPFILE} | tail -3 | tail -1 | awk -F: '{print $2}')
CARD0="${BUS0}:${DEV0}"
CARD1="${BUS1}:${DEV1}"
#CARD2="${BUS2}:${DEV2}"

# make sure both AMD GPUs detecteds
N_GPU=$(grep VGA ${TMPFILE}  | wc -l)
#if [ ${N_GPU} -ne 3 ] ; then
if [ ${N_GPU} -ne 2 ] ; then
    #echo "Error: cannot find 3 AMD GPU"
    echo "Error: cannot find 2 AMD GPU"
    echo "Found these GPU card(s):"
    cat ${TMPFILE}
    echo "Will exit"
    exit 1
fi

echo ""
echo "Will collect AMD GPU utilization for these cards:"
cat $TMPFILE
echo "CARD0=${CARD0}"
echo "CARD1=${CARD1}"
#echo "CARD2=${CARD2}"
echo ""

TIMESTAMP=$(date "+%Y-%m-%d__%H_%M_%S")

echo "starting radeontop version1 ... collectiong overall GPU utilization for all AMD GPUs"
LOG01=radeontop-version1_gpu_utilization-GPU0__${TIMESTAMP}.log
sudo ${EXE_VERSION1} -b ${CARD0} -l ${DURATION} -i 1 -d ${LOG01} &
PID01=$!

LOG11=radeontop-version1_gpu_utilization-GPU1__${TIMESTAMP}.log 
sudo ${EXE_VERSION1} -b ${CARD1} -l ${DURATION} -i 1 -d ${LOG11} &
PID11=$!

#LOG21=radeontop-version1_gpu_utilization-GPU2__${TIMESTAMP}.log
#sudo ${EXE_VERSION1} -b ${CARD2} -l ${DURATION} -i 1 -d ${LOG21} &
#PID21=$!


#echo "starting radeontop version2 ... collectiong GPU video encoding utilization"
#LOG02=radeontop-version2_GPU-Utilization-GPU0__videoEncoding_utilization__${TIMESTAMP}.log 
#sudo ${EXE_VERSION2} -l ${DURATION} -i 1 -d ${LOG02} &
#PID_VCE02=$!

#LOG12=radeontop-version2_GPU-Utilization-GPU1__videoEncoding_utilization__${TIMESTAMP}.log
#sudo ${EXE_VERSION2} -l ${DURATION} -i 1 -d ${LOG12} &
#PID_VCE12=$!


#LOG22=radeontop-version2_GPU-Utilization-GPU2__videoEncoding_utilization__${TIMESTAMP}.log        
#sudo ${EXE_VERSION2} -l ${DURATION} -i 1 -d ${LOG22} &    
#PID_VCE22=$!


wait ${PID01}
wait ${PID11}
#wait ${PID21}

#wait ${PID_VCE02}
#wait ${PID_VCE12}
#wait ${PID_VCE22}
echo "Finished collecting radeontop data for ${DURATION} seconds"

echo ""
echo ""
echo "Converting radeontop logfiles to CSV files and calculating average utilization"

# GPU Utilization GPU0 from radeontop-version1
OUTPUT_CSV_FILE=$(basename ${LOG01} .log).csv
while read p; do
    GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
    echo ${GPU_UTIL} >> ${OUTPUT_CSV_FILE}
done < ${LOG01}
# use awk to calc ave
AVE_GPU_UTIL_GPU0=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$1} END{print sum/NR}' )    
echo "GPU0 Average GPU utilization = ${AVE_GPU_UTIL_GPU0}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG01}"



# GPU Utilization GPU1 from radeontop-version1
OUTPUT_CSV_FILE=$(basename ${LOG11} .log).csv
while read p; do
    GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
    echo ${GPU_UTIL} >> ${OUTPUT_CSV_FILE}
done < ${LOG11}
# use awk to calc ave
AVE_GPU_UTIL_GPU1=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$1} END{print sum/NR}' )    
echo "GPU1 Average GPU utilization = ${AVE_GPU_UTIL_GPU1}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG11}"


# GPU Utilization GPU2 from radeontop-version1
#OUTPUT_CSV_FILE=$(basename ${LOG21} .log).csv
#while read p; do
#	GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
#	echo ${GPU_UTIL} >> ${OUTPUT_CSV_FILE}
#done < ${LOG21}
# use awk to calc ave
#AVE_GPU_UTIL_GPU2=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$1} END{print sum/NR}' )
#echo "GPU2 Average GPU utilization = ${AVE_GPU_UTIL_GPU2}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG21}"









# video encoding Utilization unknown GPU (seems to pick one randomly) from radeontop-version2
#OUTPUT_CSV_FILE=$(basename ${LOG02} .log).csv
#while read p; do
#    GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
#    VIDEO_ENCODE=$(echo "$p" | awk '{print $27}' | awk -F'%,' '{print $1}')
#    echo ${GPU_UTIL}, ${VIDEO_ENCODE} >> ${OUTPUT_CSV_FILE}
#done < ${LOG02}
# # use awk to calc ave, get average video encoding (vde) from 2nd column so awk sum+=$2 not $1 as above for column 1
#AVE_GPU_VCE0=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$2} END{print sum/NR}' )    
#echo "GPU0 Average video encoding utilization (vde) = ${AVE_GPU_VCE0}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG02}"


# video encoding Utilization unknown GPU (seems to pick one randomly) from radeontop-version2
#OUTPUT_CSV_FILE=$(basename ${LOG12} .log).csv
#while read p; do
#	GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
#	VIDEO_ENCODE=$(echo "$p" | awk '{print $27}' | awk -F'%,' '{print $1}')
#	echo ${GPU_UTIL}, ${VIDEO_ENCODE} >> ${OUTPUT_CSV_FILE}
#done < ${LOG12}
# # use awk to calc ave, get average video encoding (vde) from 2nd column so awk sum+=$2 not $1 as above for column 1
#AVE_GPU_VCE1=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$2} END{print sum/NR}' )
#echo "GPU Average video encoding utilization (vde) = ${AVE_GPU_VCE1}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG12}"


# video encoding Utilization unknown GPU (seems to pick one randomly) from radeontop-version2
#OUTPUT_CSV_FILE=$(basename ${LOG22} .log).csv
#while read p; do
#	GPU_UTIL=$(echo "$p" | awk '{print $5}' | awk -F'%,' '{print $1}')
#	VIDEO_ENCODE=$(echo "$p" | awk '{print $27}' | awk -F'%,' '{print $1}')
#	echo ${GPU_UTIL}, ${VIDEO_ENCODE} >> ${OUTPUT_CSV_FILE}
#done < ${LOG22}
# # use awk to calc ave, get average video encoding (vde) from 2nd column so awk sum+=$2 not $1 as above for column 1
#AVE_GPU_VCE2=$(cat ${OUTPUT_CSV_FILE} | awk '{sum+=$2} END{print sum/NR}' )
#echo "GPU Average video encoding utilization (vde) = ${AVE_GPU_VCE2}, CSV summary file=${OUTPUT_CSV_FILE}, radeontop log file=${LOG22}"




# remove tmp file
[ -f ${TMPFILE} ] && rm ${TMPFILE}
exit
