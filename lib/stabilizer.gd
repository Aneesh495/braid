#############################################################################
##
##  lib/stabilizer.gd              braid Package
##
##  Declarations for generic quantum stabilizer codes [[n, k, d]],
##  check matrices, canonicalization, and logical operators.
##
#############################################################################

DeclareCategory( "IsStabilizerCode", IsComponentObjectRep );

DeclareGlobalFunction( "StabilizerCode" );
DeclareGlobalFunction( "StabilizerGenerators" );
DeclareGlobalFunction( "StabilizerCheckMatrix" );
DeclareGlobalFunction( "StabilizerNumQubits" );
DeclareGlobalFunction( "StabilizerNumLogicalQubits" );
DeclareGlobalFunction( "CanonicalizeStabilizers" );
DeclareGlobalFunction( "LogicalOperators" );
DeclareGlobalFunction( "ComputeCodeDistance" );
DeclareGlobalFunction( "FiveQubitCode" );
DeclareGlobalFunction( "ThreeQubitBitFlipCode" );
DeclareGlobalFunction( "ThreeQubitPhaseFlipCode" );
DeclareGlobalFunction( "SyndromeFromPauli" );
DeclareGlobalFunction( "PrintStabilizerCode" );
