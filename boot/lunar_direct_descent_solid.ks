WAIT UNTIL SHIP:UNPACKED.
print "Waiting until lunar space and suborbital".
wait until Body:name = "Moon".
wait until Ship:Status = "Flying" or Ship:Status = "Sub_Orbital" or Ship:Status = "Escaping".
runpath("0:/lander/directdescent.ks", 0).