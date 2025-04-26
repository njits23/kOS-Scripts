WAIT UNTIL SHIP:UNPACKED.
//CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print "Automatic engine control script loaded".
set engines TO SHIP:PARTSDUBBED("engine").
set jetengines to SHIP:PARTSDUBBED("jetengine").
if engines:LENGTH > 0
{
	set finished to FALSE.
	print "managing engines".
	set maxEngineTemp to 2790.
	set engineThrustLimit to 100.
	
	set maxJetEngineTemp to 695.
	
	//set enginePID to PIDLOOP(0.0001, 0.02, 0.02, 0, 100). //PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
	//set enginePID:SetPoint to maxEngineTemp.
	
	until finished
	{
		set t0 to TIME:SECONDS.
		set engineTemp to engines[0]:getmodule("ModuleEnginesAJERamjet"):getfield("eng. internal temp").
		//print engines[0]:ALLMODULES.
		//print jetengines[0]:ALLMODULES.
		//print engines[0]:getmodule("ModuleEnginesAJERamjet"):allfields.
		//print engines[0]:getmodule("ModuleEnginesAJERamjet"):getfield("eng. internal temp").
		//set engineThrustLimit to enginePID:Update(TIME:SECONDS, engineTemp).
		if engineTemp > maxEngineTemp
		{
			set engineThrustLimit to max(0,engineThrustLimit-1).
			print "lowered thrust limit to " + engineThrustLimit.
		}
		else if engineTemp < (maxEngineTemp - 100) and throttle > 0.99 and engineThrustLimit < 100
		{
			set engineThrustLimit to min(100,engineThrustLimit+1).
			print "raised thrust limit to " + engineThrustLimit.
		}
		//print engineThrustLimit.
		//print enginePID:error.
		//print engineTemp.
		for engine in engines
		{
			engine:getmodule("ModuleEnginesAJERamjet"):setfield("thrust limiter", engineThrustLimit).
		}
		for jetengine in jetengines
		{
			set jetenginemodule to jetengine:getmodule("ModuleEnginesAJEJet").
			//print jetenginemodule:allfields.
			//print jetenginemodule:allevents.
			if jetenginemodule:getfield("eng. internal temp") > maxJetEngineTemp
			{
				if jetenginemodule:HasEvent("shutdown engine")
				{
					print "shutting down jet engine".
					jetenginemodule:DoEvent("shutdown engine").
				}
			}
		}
		if FALSE
		{
			print "bazinga".
			set finished to TRUE.
		}
		wait until TIME:SECONDS > t0+0.05.
	}
	print "stopping script".
}
else
{
	print "No engines detected, stopping script".
}