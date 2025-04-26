wait until Ship:Unpacked.

local debugGui is GUI(300, 80).
set debugGui:X to 950.
set debugGui:Y to debugGui:Y + 380.
local mainBox is debugGui:AddVBox().
local debugStat1 is mainBox:AddLabel("Angle between pitch vectors: ").
local debugStat2 is mainBox:AddLabel("Angle between yaw vectors: ").
local debugStat3 is mainBox:AddLabel("Angle between roll vectors: ").
debugGui:Show().

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
	


// Upwards vector
SET upArrow TO VECDRAW(
  V(0,0,0),								//Origin
  { return getRadialOutVec() * 5. },						//Direction and magnitude
  RGBA(1, 1, 1, 1),	//Colour
  "Up",									//Label
  1.0,									//Scale
  TRUE,									//Show
  0.2,									//Width
  TRUE, 								//Pointy
  TRUE 									//Wiping
).

//Capsule orientation vector:
SET shipArrow TO VECDRAW(
  V(0,0,0),								//Origin
  { return Ship:Facing:TopVector * 5. },				//Direction and magnitude
  RGBA(1, 1, 1, 1),	//Colour
  "Capsule orientation",				//Label
  1.0,									//Scale
  TRUE,									//Show
  0.2,									//Width
  TRUE, 								//Pointy
  TRUE 									//Wiping
).



//Capsule orientation vector:
SET rollVecRefArrow TO VECDRAW(
  V(0,0,0),								//Origin
  { return tangentVecRef()*5. },				//Direction and magnitude
  RGBA(1, 1, 1, 1),	//Colour
  "rollVecref",				//Label
  1.0,									//Scale
  TRUE,									//Show
  0.2,									//Width
  TRUE, 								//Pointy
  TRUE 									//Wiping
).

local function pitchVecRef
{
	return (getRadialOutVec() * angleaxis(90, tangentVecRef())). 
}

//Capsule orientation vector:
SET pitchdirrefArrow TO VECDRAW(
  V(0,0,0),								//Origin
  { return pitchVecRef()*5. },				//Direction and magnitude
  RGBA(1, 1, 1, 1),	//Colour
  "pitchvecref",				//Label
  1.0,									//Scale
  TRUE,									//Show
  0.2,									//Width
  TRUE, 								//Pointy
  TRUE 									//Wiping
).



until false
{
	local offsetAngles is getOffsetAngles.
	set debugStat1:text to "Angle between pitch vectors: " + round(offsetAngles[0], 2).
	set debugStat2:text to "Angle between yaw vectors: " + round(offsetAngles[1], 2).
	set debugStat3:text to "Angle between roll vectors: " + round(offsetAngles[2], 2).
}