// Wait for unpack
wait until Ship:Unpacked.
set Config:IPU to 2000.

if Config:IPU < 2000
{
	print "WARNING!!! IPU SET TOO LOW! PID INSTABILITY LIKELY! WARNING!!!".
	print "Current IPU config: " + Config:IPU.
	print "Increase IPU in difficulty settings manually!".
}

LOCAL activation_gui IS GUI(200).
set activation_gui:X to 952.
set activation_gui:Y to activation_gui:Y + 342.
LOCAL label IS activation_gui:ADDLABEL("Re-Entry Autopilot").
SET label:STYLE:ALIGN TO "CENTER".
SET label:STYLE:HSTRETCH TO True. // Fill horizontally
LOCAL ACTIVATE TO activation_gui:ADDBUTTON("ACTIVATE").
activation_gui:SHOW().
local activated is False.
function activateAutopilot 
{
	set activated to True.
}
SET ACTIVATE:ONCLICK TO activateAutopilot@.
wait until activated.
activation_gui:hide().

print "Engaging Re-Entry Autopilot".
Core:Part:ControlFrom().

local debugGui is GUI(300, 80).
set debugGui:X to 950.
set debugGui:Y to debugGui:Y + 380.
local mainBox is debugGui:AddVBox().
local debugStat1 is mainBox:AddLabel("Status: ").
local debugStat2 is mainBox:AddLabel("Acceleration: ").
local debugStat3 is mainBox:AddLabel("Target Orientation: ").
local debugStat4 is mainBox:AddLabel("Current Orientation: ").
debugGui:Show().

if Core:Part:Tag = "invert"
{
	set RollOffset to 0.
	set CommandMults to -1.
}
else
{
	set RollOffset to 180.
	set CommandMults to 1.
}

local function getRadialOutVec
{
	local normalVec is vcrs(ship:velocity:surface:normalized,-body:position:normalized).
	return -vcrs(ship:velocity:surface:normalized,normalVec).
}

local function pitchVecRef
{
	return ship:velocity:surface:normalized. 
}

local function tangentVecRef
{
	return (getRadialOutVec() * angleaxis(90, pitchVecRef())). 
}

function getOffsetAngles
{
	return list(vang(Ship:Facing:TopVector, pitchVecRef()), vang(Ship:Facing:vector, tangentVecRef()), vang(Ship:Facing:TopVector, tangentVecRef())).
}

for a in Ship:ModulesNamed("ModuleProceduralAvionics")
{
	if a:HasEvent("activate avionics")
		a:DoEvent("activate avionics").
}

print "Using RollOffset of " + RollOffset + " degrees.".

set PIDSetPoints to 90.

set PitchCommand to 0.
set YawCommand to 0.
set RollCommand to 0.

set PitchPID to PIDLOOP(0.05, 0.01, 0.1, -0.75, 0.75, 0.1). //PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
set PitchPID:SetPoint to PIDSetPoints.

set YawPID to PIDLOOP(0.05, 0.01, 0.1, -0.3, 0.3, 0.1). //PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
set YawPID:SetPoint to PIDSetPoints.

set RollPID to PIDLOOP(0.05, 0.001, 0.1, -0.3, 0.3, 0.1). //PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
set RollPID:SetPoint to PIDSetPoints.

local function CorrectOrientation
{
	set CurrentOrientation to GetOffsetAngles().
	set PitchCommand to PitchPID:Update(TIME:SECONDS, CurrentOrientation[0]).
	set YawCommand to YawPID:Update(TIME:SECONDS, CurrentOrientation[1])*CommandMults.
	set RollCommand to RollPID:Update(TIME:SECONDS, CurrentOrientation[2])*CommandMults.
	set Ship:Control:Pitch to -PitchCommand.
	set Ship:Control:Yaw to YawCommand.
	set Ship:Control:Roll to RollCommand.
	//print ""+ PitchCommand + " " + YawCommand + " " + RollCommand.
}

local function CorrectRoll
{
	set CurrentOrientation to GetOffsetAngles().
	set RollCommand to RollPID:Update(TIME:SECONDS, CurrentOrientation[2])*CommandMults.
	set Ship:Control:Roll to RollCommand.
}

local prevSpeed is Ship:Velocity:Surface:Mag.
local prevTime is Time:Seconds.
local accel is 0.
local function UpdateGUI
{
	if (Time:Seconds - prevTime) > 1 or (Time:Seconds - prevTime) = 0
	{
		set prevSpeed to Ship:Velocity:Surface:Mag.
		set prevTime to Time:Seconds.
	}
	else
	{
		set accel to (Ship:Velocity:Surface:Mag - prevSpeed) / (Time:Seconds - prevTime).
		set prevSpeed to Ship:Velocity:Surface:Mag.
		set prevTime to Time:Seconds.
	}
		
	set debugStat2:Text to "Acceleration: " + round(accel, 2) + " m/s²".
	set debugStat4:text to "Current Orientation: (" + round(getOffsetAngles()[0], 2) + "," + round(getOffsetAngles()[1], 2) + "," + round(getOffsetAngles()[2], 2) + ")".
}

if Body:name <> "Earth"
{
	print "Wrong body, aborting".
	set debugStat1:Text to "Status: Wrong body, aborting".
	wait 5.
	debugGui:hide().
	runpath("0:/lifting_reentry_autopilot.ks").
}

print "Checking Pe <61km".
if Ship:Obt:Periapsis > 61000
{
	if Ship:status = "ORBITING"
	{
		print "Pe >61km, lowering to 60km".
		set debugStat1:Text to "Status: Pe >61km, lowering to 60km".
		rcs on.
		lock steering to Ship:Retrograde + R(0,0,RollOffset).
		set kUniverse:Timewarp:mode to "PHYSICS".
		set kUniverse:TimeWarp:Warp to 1.
		wait until vang(Ship:Facing:vector, Ship:Retrograde:vector) < 0.25.
		lock throttle to 1.
		wait until Ship:Obt:Periapsis < 70000.
		kUniverse:Timewarp:CancelWarp.
		wait until Ship:Obt:Periapsis < 60100.
		lock throttle to 0.
		wait 1.
	}
	else
	{
		print "Periapsis >61km on non-orbital trajectory, adjust it manually".
		set debugStat1:Text to "Status: Periapsis >61km on non-orbital trajectory, adjust it manually".
		wait 5.
		debugGui:hide().
		runpath("0:/lifting_reentry_autopilot.ks").
	}
}
print "Pe <61km, warping to atmosphere".
set debugStat1:Text to "Status: Pe <61km, warping to atmosphere".
set kUniverse:Timewarp:mode to "RAILS".
set kUniverse:TimeWarp:Warp to 5.
wait until Ship:Altitude < Ship:Body:Atm:Height.

local decouplerStage is 999.
for part in Ship:partsTagged("serviceModuleDecoupler")
{
	set decouplerStage to part:Stage.
}
if decouplerStage < 999
{
	print "Service module decoupler found, staging until decoupled".
	until Ship:StageNum = decouplerStage
	{
		stage.
		wait 0.5.
	}
}

print "Facing SVEL-".
set debugStat1:Text to "Status: Facing SVEL-".
set debugStat3:Text to "Target Orientation: (90,90,90)".

rcs on.
lock steering to Ship:SrfRetrograde + R(0,0,RollOffset).

until vang(Ship:Facing:ForeVector, Ship:SrfRetrograde:ForeVector) < 1 and abs(vdot(Facing:Vector, Ship:AngularVel)) < 0.2 and getOffsetAngles()[2] > 89 and getOffsetAngles()[2] < 91 //and accel < 0
{
	UpdateGUI().
	wait 0.
}
wait 2.
unlock steering.

print "Engaging PIDs at " +PIDSetPoints+ " degrees".
print "Waiting until alt<100km and vel<8000m/s to shift CoM".
set debugStat1:Text to "Status: Waiting until alt<100km and vel<8000m/s to shift CoM".

set kUniverse:Timewarp:mode to "PHYSICS".
if Ship:Velocity:Surface:Mag > 8000
{
	set kUniverse:TimeWarp:Warp to 2.
}
else
{
	set kUniverse:TimeWarp:Warp to 3.
}
//Control all orientations until lifting flight
until Ship:Altitude < 100000 and Ship:Velocity:Surface:Mag < 8000
{
	CorrectOrientation().
	UpdateGUI().
	wait 0.
}

set Ship:Control:Pitch to 0.
set Ship:Control:Yaw to 0.

if Core:Part:HasModule("AdjustableCoMShifter")
{
	if Core:Part:GetModule("AdjustableCoMShifter"):HasEvent("turn descent mode on")
	{
		Core:Part:GetModule("AdjustableCoMShifter"):DoEvent("turn descent mode on").
		print "Shifting CoM".
	}
	else if Core:Part:GetModule("AdjustableCoMShifter"):HasEvent("turn descent mode off")
	{
		print "CoM already shifted".
	}
	set debugStat1:Text to "Status: Lifting flight engaged".
}
else
{
	print "Unable to shift CoM".
	set debugStat1:Text to "Unable to shift CoM!".
}

set debugStat3:Text to "Target Orientation: (free,free,90)".
set kUniverse:TimeWarp:Warp to 3.

// Maintain roll control until surface velocity reduces to a low value.
until Ship:Velocity:Surface:Mag < 300
{
	CorrectRoll().
	UpdateGUI().
	wait 0.
}	

set Ship:Control:Neutralize to true.
rcs off.

if Core:Part:HasModule("AdjustableCoMShifter")
{
	if Core:Part:GetModule("AdjustableCoMShifter"):HasEvent("turn descent mode off")
	{
		Core:Part:GetModule("AdjustableCoMShifter"):DoEvent("turn descent mode off").
		print "Equalizing CoM".
	}
	else if Core:Part:GetModule("AdjustableCoMShifter"):HasEvent("turn descent mode on")
	{
		print "CoM already equalized".
	}
	print "Roll program complete".
	set debugStat1:Text to "Status: Roll program ended".
}
else
{
	print "Unable to equalize CoM".
	set debugStat1:Text to "Unable to equalize CoM!".
}

for a in Ship:ModulesNamed("RealChuteModule")
{
	if a:HasAction("arm parachute")
		a:DoAction("arm parachute", True).
		set debugStat1:Text to "Status: Roll program ended, chutes armed".
}

print "Chutes armed, will kill warp at 100m".

wait until Ship:Altitude - Ship:GeoPosition:TerrainHeight < 100 or Ship:Altitude < 100.
kUniverse:Timewarp:CancelWarp.