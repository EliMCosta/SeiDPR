import robot

logFile = open('mylog.txt', 'w')
robot.run("dpr.robot", stdout=logFile)
