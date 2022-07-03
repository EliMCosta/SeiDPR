import robot

logFile = open('mylog.txt', 'w')
robot.run("rdata.robot", stdout=logFile)
