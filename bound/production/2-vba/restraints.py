#!/usr/bin/env python

import math
import sys

#===================================================================================================
# INPUTS
#===================================================================================================

K = 8.314472*0.001  # Gas constant in kJ/mol/K
V = 1.66            # standard volume in nm^3

T      = 300.0      # Temperature in Kelvin
r0     = 0.3676     # Distance in nm
thA    = 76.768     # Angle in degrees 
thB    = 103.562    # Angle in degrees

K_r    = 10000.0    # force constant for distance (kJ/mol/nm^2)
K_thA  = 1000.0     # force constant for angle (kJ/mol/rad^2)
K_thB  = 1000.0     # force constant for angle (kJ/mol/rad^2)
K_phiA = 1000.0     # force constant for dihedral (kJ/mol/rad^2)
K_phiB = 1000.0     # force constant for dihedral (kJ/mol/rad^2)
K_phiC = 1000.0     # force constant for dihedral (kJ/mol/rad^2)          

sym    = 2 
#===================================================================================================
# BORESCH FORMULA
#===================================================================================================

thA = math.radians(thA)  # convert angle from degrees to radians --> math.sin() wants radians
thB = math.radians(thB)  # convert angle from degrees to radians --> math.sin() wants radians

arg =(
    (8.0 * math.pi**2.0 * V) / (r0**2.0 * math.sin(thA) * math.sin(thB)) 
    * 
    (
        ( (K_r * K_thA * K_thB * K_phiA * K_phiB * K_phiC)**0.5 ) / ( (2.0 * math.pi * K * T)**(3.0) )
    )
)

dG = - K * T * math.log(arg)

print("dG_off = %8.3f kcal/mol" %(dG/4.184))
print("dG_on  = %8.3f kcal/mol" %(-dG/4.184))
print("dG_on  = %8.3f kJ/mol" %(-dG))

dGsym = - K * T * math.log(sym)

print("dG_sym  = %8.3f kcal/mol" %(dGsym/4.184))
print("dG_sym  = %8.3f kJ/mol" %(dGsym))
