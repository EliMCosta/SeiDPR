import robot

logFile = open('mylog.txt', 'w')
robot.run("Robot2.robot", stdout=logFile)
