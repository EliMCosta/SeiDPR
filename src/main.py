import robot
import os
import shutil

logFile = open('mylog.txt', 'w')
robot.run("dpr2.robot", stdout=logFile)

dir_path = os.path.dirname(os.path.realpath(__file__))
var1 = dir_path.split('/src')
shutil.move(var1[0]+'/report.html', var1[0]+'/results/report.html')
shutil.move(var1[0]+'/output.xml', var1[0]+'/results/output.xml')
shutil.move(var1[0]+'/log.html', var1[0]+'/results/log.html')
