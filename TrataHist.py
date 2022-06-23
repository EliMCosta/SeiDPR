import re

with open('/tmp/automations/hist.txt') as f:
    lines = f.readlines()
    line_andamento=lines[3]
    var_1=line_andamento.split('(')
    var_2=var_1[1].split(' ')
    num_reg=var_2[0]
num_reg=int(num_reg)
if num_reg > 100:
    print('True')
else:
    print('False')

f.close