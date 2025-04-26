WAIT UNTIL SHIP:UNPACKED.
//print "Waiting until we have been to space and are returning to Earth".
//wait until Ship:Status = "Orbiting".
//wait until Body:name = "Earth" and Ship:Status = "Sub_Orbital" and Ship:Altitude < Ship:Body:Atm:Height.
//wait until Ship:Altitude < Ship:Body:Atm:Height.
runpath("0:/lifting_reentry_autopilot.ks").


