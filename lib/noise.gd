#############################################################################
##
##  lib/noise.gd                   braid Package
##
##  Declarations for quantum noise channels: depolarizing, bit-flip,
##  phase-flip, and phenomenological measurement error models.
##
#############################################################################

DeclareGlobalFunction( "GenerateDepolarizingError" );
DeclareGlobalFunction( "GenerateIndependentXZError" );
DeclareGlobalFunction( "InjectPhenomenologicalNoise" );
DeclareGlobalFunction( "AddMeasurementReadoutErrors" );
DeclareGlobalFunction( "SamplePauliChannel" );
