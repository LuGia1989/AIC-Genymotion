'''
capture cpu utilization in 2 min:
top -n 120 -d 1 -b > top1@60fpsbbrv2.log
python3 top.py top1@60fpsbbrv2.log
'''
import sys
import pandas as pd

f = sys.argv[1]

def cpu_utilization(f):

    mylines = []
    cpulines = []
    cpuline_split = []

    with open(f, 'r+') as myfile:
        for line in myfile:
            mylines.append(line.rstrip('\n'))
    for i in mylines:
        index = i.find('%Cpu(s):')
        if index != -1:
            cpulines.append(i)


    for i in cpulines:
        i_split = i.split(',')
        #['%Cpu(s): 50.5 us', ' 39.4 sy', '  0.0 ni', '  8.2 id', '  0.0 wa', '  0.0 hi', '  2.0 si', '  0.0 st']
        #(cpuline_split.append(i_split)
        cpuline_split.append(float(i_split[3][0:6]))

    df_idle = pd.DataFrame(cpuline_split[1:])
    #print(df_idle.size)
    ave_cpu = (100 - df_idle.mean()[0])
    max_cpu = (100 - df_idle.min()[0])
    
    return ave_cpu, max_cpu

def main():
    ave_cpu, max_cpu = cpu_utilization(f)
    print('Ave. CPU Utilization: ', '{:.2f}'.format(ave_cpu))
    print('Max. CPU Utilization: ', '{:.2f}'.format(max_cpu))

if __name__ == '__main__':
    main()



