import numpy;
import sys;
import pandas as pd; 
f=sys.argv[1];
#df=pd.read_csv('radeontop-version1_gpu_utilization-GPU0__2020-03-25__14_42_41.csv'); 

def gpu_utilization(f): 
    df=pd.read_csv(f); 
    print('Ave. GPU Utilization: ',df.mean()[0]);
    print('Max. GPU Utilization: ',df.max()[0]);
    print('Stddev GPU Utilization: ',df.std()[0]);

def main():
    gpu_utilization(f)


if __name__ == '__main__':
    main()








