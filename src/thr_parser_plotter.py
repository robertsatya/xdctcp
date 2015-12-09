from matplotlib import pyplot as plt
import numpy as np

thr_x = []
thr = []
t_x = []
t = []
#with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/3_3_mytrace/mytracefile_0.09_0.3_1.0.tr', 'r') as f:
with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/3_3_thr/thrfile_0.09_0.3_1.0.tr', 'r') as f:
    s = f.read()
    s_lines = s.strip().split('\n')
    i = 0
    for line in s_lines:
        if float(line.split()[0].strip()) >= 0.5 and float(line.split()[0].strip()) < .55:
            t_x.append(float(line.split()[0].strip()))    
            thr_x.append(float(line.split()[1].strip()))
        

#with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/3_3_mytrace/mytracefile_0.0625_0.5_0.5.tr', 'r') as f:
with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/3_3_thr/thrfile_0.0625_0.5_0.5.tr', 'r') as f:
    s = f.read()
    s_lines = s.strip().split('\n')
    for line in s_lines:
        if float(line.split()[0].strip()) >= 0.5 and float(line.split()[0].strip()) < .55:
            thr.append(float(line.split()[1].strip()))
            t.append(float(line.split()[0].strip()))

plt.axes(ylabel = 'Instantaneous Throughput', xlabel = 'Time (ms)')
plt.plot(t_x, thr_x, label='xDCTCP', color = 'blue')
plt.plot(t, thr, label='DCTCP', color = 'red')
plt.legend(loc=0,
           ncol=2, mode="None", borderaxespad=0.)
plt.grid(True)
plt.show()

