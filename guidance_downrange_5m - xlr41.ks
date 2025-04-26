CLEARSCREEN.

// Overrides
//SET SteeringManager:ROLLTS TO 2.0.
//SET STEERINGMANAGER:YAWTS TO 4.
//SET STEERINGMANAGER:PITCHTS TO 4.

// Variable
SET STEER_START_SVEL TO 50.
SET STEER_END_SVEL TO 1050.
SET PITCH_START TO 70.
SET TARGET_PITCH TO 43.

SET LAUNCH_DIR TO 90.

// Initialize
LOCK THROTTLE TO 1.0.
LOCK STEERING TO HEADING(LAUNCH_DIR, 90).
PRINT("INITIALIZED").
PRINT("WAITING FOR LIFTOFF").
SET INITIAL_FACING TO SHIP:FACING.
SET S0 TO SHIP:STAGENUM.
LOCK S TO SHIP:STAGENUM.
LOCK SI TO S0-S.
set initial_climb_complete to false.

//Automatic startup
LOCK THROTTLE TO 1.0.

//Count down from 10.
PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "T-" + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

STAGE.
WAIT until ship:thrust > maxthrust*0.8.
STAGE.

WAIT UNTIL S < S0 -1.
SET T0 TO TIME:SECONDS.
LOCK T TO TIME:SECONDS - T0.

PRINT("LIFT OFF AT T=" + T0).

// First stage logic
LOCK INITIAL_CLIMB_CHECK TO SHIP:VELOCITY:SURFACE:MAG < STEER_START_SVEL.
LOCK STEER_TO_PITCH TO PITCH_START - ((MIN(SHIP:VELOCITY:SURFACE:MAG, STEER_END_SVEL)  - STEER_START_SVEL) / (STEER_END_SVEL - STEER_START_SVEL) * (PITCH_START - TARGET_PITCH)).

UNTIL initial_climb_complete {
	CLEARSCREEN.
	PRINT("BOOSTER STAGE").
	PRINT("---------------").
	PRINT("STAGE: " + S + "; SI: " + SI + "; T=" + ROUND(T, 1)).
	
	IF INITIAL_CLIMB_CHECK {
		LOCK STEERING TO INITIAL_FACING.
		PRINT("HOLDING PITCH").
	} ELSE {
		LOCK STEERING TO HEADING(LAUNCH_DIR,STEER_TO_PITCH).
		PRINT("STEERING " + ROUND(STEER_TO_PITCH, 2) + " -> " + ROUND(TARGET_PITCH, 2)).
	}
	
	IF (NOT INITIAL_CLIMB_CHECK) AND T>60 AND ship:dynamicpressure < 0.15 AND SI <= 2 {
		PRINT("Beginning roll").
		LOCK STEERING TO SHIP:VELOCITY:SURFACE.
		SET SHIP:CONTROL:ROLL TO 1.0.
		set roll_enable_time to TIME:SECONDS.
		set initial_climb_complete to true.
	}
	WAIT 0.05.
}

until Ship:stagenum = 0
{
	if TIME:SECONDS+10 > roll_enable_time and ship:dynamicpressure <0.05 and maxthrust=0
	{
		if ship:mass > 3
		{
			LOCK THROTTLE TO 0.0.
			wait 0.1.
			print "Staging ullage".
			stage.
			wait 0.6.
			print "Igniting engines".
			LOCK THROTTLE TO 1.0.
			wait 0.3.
			print "Staging decoupler".
			stage.
		}
		else
		{
			print "Staging".
			stage.
		}
	}
	wait 0.05.
}

print "You better hope you get to 5Mm".

