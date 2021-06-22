import sys
import pandas as pd
import re
from numpy import mean

f=sys.argv[1]

def netint_resources(f):
    lines = []
    netint_resources = []
    load_lst = []
    model_load_lst = []
    mem_lst = []
    inst_lst = []

    with open(f, 'r+') as myfile:
        for line in myfile:
            lines.append(line.rstrip('\n'))
    for i in lines:
        if re.search(r'L[\s]', i):
            netint_resources.append(i.split())
    df = pd.DataFrame(netint_resources[1::2]) #print only odd indices in list.
    print(df)

    for i in df[2]:
        load_lst.append(int(i))
    print(load_lst)
    average_load = mean(load_lst)
    #print('LOAD = ',"{:.2f}".format(average_load))

    for i in df[3]:
        model_load_lst.append(int(i))
    print(model_load_lst)
    average_model_load = mean(model_load_lst)
    #print('MODEL_LOAD = ',"{:.2f}".format(average_model_load))

    for i in df[4]:
        mem_lst.append(int(i))
    print(mem_lst)
    average_mem = mean(mem_lst)
    #print('MEM = ',"{:.2f}".format(average_mem))

    for i in df[5]:
        inst_lst.append(int(i))
    print(inst_lst)
    average_inst = mean(inst_lst)
    #print('INST = ',"{:.2f}".format(average_inst))

    return average_load, average_model_load, average_mem, average_inst

def main():
    average_load, average_model_load, average_mem, average_inst = netint_resources(f)
    print('LOAD = ',"{:.2f}".format(average_load)) 
    print('MODEL_LOAD = ',"{:.2f}".format(average_model_load))
    print('MEM = ',"{:.2f}".format(average_mem))
    print('INST = ',"{:.2f}".format(average_inst))

if __name__ == '__main__':
    main()




