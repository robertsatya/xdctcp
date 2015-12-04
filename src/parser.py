from os import listdir
from collections import OrderedDict
import matplotlib.pyplot as plt
import plotly.plotly as py
import plotly.graph_objs as go

l = listdir('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/2_3/')

# parser for getting optimal g, ns, nl values
nq = 2
ns = 3
delay = OrderedDict()
thr_dict = {}
delay_dict = {}
d_list = []
t_list = []
p_list = []
for file_name in l:
    with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/2_3/' + file_name, 'r') as f:
        s = f.read()
        s_lines = s.strip().split('\n')
        params = s_lines[0].strip().split()
        if params[1] != 0.0:

            avg_d = 0
            for i in range(1,nq+ns+1):
                avg_d += float(s_lines[i].strip().split()[1])
            avg_d /= (nq+ns)
            delay[avg_d] = params
            d_list.append(avg_d)
            delay_dict["_".join(params)] = avg_d

            avg_t = 0
            for i in range(nq+1,9):
                avg_t += float(s_lines[i].strip().split()[2])
            avg_t /= (8 - nq)
            t_list.append(avg_t)
            thr_dict["_".join(params)] = avg_t
            p_list.append("g = {dg}, dctcp_ns_ = {ns}, dctcp_nl_ = {nl}".format(dg= params[0], ns = params[1], nl= params[2]))

# delay_sorted = sorted(delay.items(), key = lambda t: t[0])

trace = go.Scatter(x=d_list, y=t_list, mode='markers', marker=dict(size=12, line=dict(width=1)), text = p_list)
data = [trace]
layout = go.Layout(
    title='Avg Throughput for long flows vs Avg Delay for short flows',
    hovermode='closest',
    xaxis=dict(
        title='Average Delay for short flows',
        ticklen=5,
        zeroline=False,
        gridwidth=2,
    ),
    yaxis=dict(
        title='Average Throughput for long flows',
        ticklen=5,
        gridwidth=2,
    ),
)
fig = go.Figure(data=data, layout=layout)
plot_url = py.plot(fig, filename='delay-vs-thr')
##plt.plot(d_list, t_list, 'ro')
##plt.grid(True)
##plt.show()

#parser for variation in delay, throughput vs ns vs nl
#ll_t = [ [0]*5 for _ in xrange(6) ]
#ll_d = [ [0]*5 for _ in xrange(6) ]
#for file_name in l:
#    with open('/usr/local/home/cse222a19/ucsdcse222a/group19/src/sim1_1203/2_3/' + file_name, 'r') as f:
#        s = f.read()
#        s_lines = s.strip().split('\n')
#        params = s_lines[0].strip().split()
#        if params[0] == "0.095000000000000001":
#            
#            avg_d = 0
#            for i in range(1,6):
#                avg_d += float(s_lines[i].strip().split()[1])
#            avg_d /= 5
#
#            avg_t = 0
#            for i in range(6,9):
#                avg_t += float(s_lines[i].strip().split()[2])
#            avg_t /= 3
#            
#            i = int(round(float(params[2])*10 - 5))
#            j = int(round(float(params[1])*10 - 1))
#            
#            ll_t[i][j] = avg_t
#            ll_d[i][j] = avg_d
## ppl.pcolormesh(fig, ax, np.array(ll_t), xticklabels= ['0.1', '0.2', '0.3', '0.4', '0.5'], yticklabels= ['0.5', '0.6', '0.7', '0.8', '0.9', '1.0'], cmap=red_purple)
#            
#data = [
#    go.Heatmap(
#        z=ll_t,
#        x=['0.1', '0.2', '0.3', '0.4', '0.5'],
#        y=['0.5', '0.6', '0.7', '0.8', '0.9', '1.0']
#    )
#]
#plot_url = py.plot(data, filename='thr-heatmap')
