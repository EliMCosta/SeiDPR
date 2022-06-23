import robot

logFile = open('mylog.txt', 'w')
robot.run("RecDistProc.robot",stdout=logFile)