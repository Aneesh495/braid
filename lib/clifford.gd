#############################################################################
##
##  lib/clifford.gd                braid Package
##
##  Declarations for the binary symplectic group Sp(2n, F2),
##  Clifford group representations, and Bruhat circuit synthesis.
##
#############################################################################

DeclareCategory( "IsSymplecticMatrix", IsComponentObjectRep );

DeclareGlobalFunction( "SymplecticFormOmega" );
DeclareGlobalFunction( "IsSymplecticMatrix" );
DeclareGlobalFunction( "TableauToSymplecticMatrix" );
DeclareGlobalFunction( "MultiplySymplecticMatrices" );
DeclareGlobalFunction( "SymplecticInverse" );
DeclareGlobalFunction( "SymplecticTransvection" );
DeclareGlobalFunction( "SynthesizeCNOTCircuit" );
DeclareGlobalFunction( "SynthesizeCliffordCircuit" );
DeclareGlobalFunction( "CliffordGateCost" );
DeclareGlobalFunction( "PrintCircuit" );
