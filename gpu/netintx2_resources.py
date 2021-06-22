import sys
import pandas as pd


mylines = []
f=sys.argv[1]
encoder0 = []
encoder1 = []
enc0 = []

def netintLoad(f):
    mylines = []
    encoder0 = []
    encoder1 = []
    enc0 = []
    enc1 = []
    something = []

    with open(f, 'r+') as myfile:
        for line in myfile:
            mylines.append(line.rstrip('\n'))
    for idx, word in enumerate(mylines):
        index = word.find('Num encoders:')
        if index != -1:
            something.append(mylines[idx + 1])
            encoder0.append(mylines[idx + 2])
            encoder1.append(mylines[idx + 3])
    for i in encoder0:
        enc0.append(i.rstrip().split())

    for i in encoder1:
        enc1.append(i.rstrip().split())

    df_enc0 = pd.DataFrame(enc0)
    s_load0 = pd.Series(df_enc0[:][2].astype('int'))
    s_model_load0 = pd.Series(df_enc0[:][3].astype('int'))
    s_mem0 = pd.Series(df_enc0[:][4].astype('int'))
    s_inst0 = pd.Series(df_enc0[:][5].astype('int'))

    df_enc1 = pd.DataFrame(enc1)
    s_load1 = pd.Series(df_enc1[:][1].astype('int'))
    s_model_load1 = pd.Series(df_enc1[:][2].astype('int'))
    s_mem1 = pd.Series(df_enc1[:][3].astype('int'))
    s_inst1 = pd.Series(df_enc1[:][4].astype('int'))

    ave_load0 = s_load0.mean()
    ave_load1 = s_load1.mean()

    ave_model_load0 =  s_model_load0.mean()
    ave_model_load1 =  s_model_load1.mean()

    ave_mem0 = s_mem0.mean()
    ave_mem1 = s_mem1.mean()

    ave_inst0 = s_inst0.mean()
    ave_inst1 = s_inst1.mean()

    return ave_load0, ave_load1, ave_model_load0, ave_model_load1, ave_mem0, ave_mem1, ave_inst0, ave_inst1 




def main():
    ave_load0, ave_load1, ave_model_load0, ave_model_load1, ave_mem0, ave_mem1, ave_inst0, ave_inst1 = netintLoad(f)
    print('Ave. Load 0 = ', ave_load0)
    print('Ave. Model Load 0 = ', ave_model_load0)
    print('Ave. MEM 0 = ', ave_mem0)
    print('Ave. INST 0 = ', ave_inst0)

    print('Ave. Load 1 = ', ave_load1)
    print('Ave. Model Load 1 = ', ave_model_load1)
    print('Ave. MEM 1 = ', ave_mem1)
    print('Ave. INST 1 = ', ave_inst1)

if __name__ == '__main__':
    main()



