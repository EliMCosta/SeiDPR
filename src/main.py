import robot
import os
import shutil
import time

while True:
    logFile = open('mylog.txt', 'w')
    robot.run("dpr.robot", stdout=logFile)
    time.sleep(5)
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    shutil.move(var1[0]+'/report.html', var1[0]+'/results/report.html')
    shutil.move(var1[0]+'/output.xml', var1[0]+'/results/output.xml')
    shutil.move(var1[0]+'/log.html', var1[0]+'/results/log.html')
    time.sleep(30)
