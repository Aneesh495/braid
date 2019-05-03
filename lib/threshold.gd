#############################################################################
##
##  lib/threshold.gd               braid Package
##
##  Declarations for Monte Carlo fault-tolerant threshold simulation,
##  logical error rate curves (p_L vs p), and crossing point analysis.
##
#############################################################################

DeclareGlobalFunction( "SimulateLogicalErrorRate" );
DeclareGlobalFunction( "ComputeThresholdCurve" );
DeclareGlobalFunction( "SurfaceCodeThresholdScan" );
DeclareGlobalFunction( "DetectThresholdCrossing" );
DeclareGlobalFunction( "PrintThresholdReport" );
