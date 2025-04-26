WAIT UNTIL SHIP:UNPACKED.
//CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print "Automatic drop tank script loaded".
set droptanks TO SHIP:PARTSDUBBED("droptank").
if droptanks:LENGTH > 0
{
	set tanks_dropped to FALSE.
	print "Waiting until tanks are empty".
	
	until tanks_dropped
	{
		set fuel_remaining to 0.
		for droptank in droptanks 
		{
			for resource in droptank:RESOURCES
			{
				set fuel_remaining to fuel_remaining + resource:AMOUNT.
			}
		}
		if fuel_remaining <= 0
		{
			print "Dropping tanks".
			ag4 on.
			wait 0.01.
			ag4 off.
			set tanks_dropped to TRUE.
		}
	}
	print "Tanks dropped, stopping script".
}
else
{
	print "No drop tanks attached, stopping script".
}