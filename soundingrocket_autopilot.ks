//CLEARSCREEN.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
PRINT "NJCorp Automatic Sounding Rocket Pilot Initialized".

LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "T-" + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

STAGE.

print "Waiting for SRBs to burn out".
wait 1.
wait until maxthrust < 14.
print "Jettisoning SRBs".
stage.

print "Waiting for first stage to burn out".
wait until maxthrust = 0.

PRINT "Waiting for Q-penalty to dissipate".
lock throttle to 0.0.

WAIT until ship:dynamicpressure < 0.05.
print "Igniting upper stage".
STAGE.
wait 0.1.
lock throttle to 1.0.

wait until maxthrust = 0.
if ship:stagenum = 1 {
	print "Detected parachute stage".
	print "Waiting to reach space".
	wait until ship:altitude > 140000.
	print "Staging final stage".
	stage.
}.

print "Disengaging NJCorp Automatic Sounding Rocket Pilot".
print "Thank you for flying NJCorp".