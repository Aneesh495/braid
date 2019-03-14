#############################################################################
##
##  lib/pauli.gd                   braid Package
##
##  Declarations for multi-qubit Pauli operators, symplectic vectors,
##  and finite field binary commutation geometry.
##
#############################################################################

DeclareCategory( "IsPauliOperator", IsComponentObjectRep );

DeclareGlobalFunction( "PauliOperator" );
DeclareGlobalFunction( "PauliFromString" );
DeclareGlobalFunction( "StringFromPauli" );
DeclareGlobalFunction( "PauliWeight" );
DeclareGlobalFunction( "SymplecticInnerProduct" );
DeclareGlobalFunction( "CommutesWith" );
DeclareGlobalFunction( "MultiplyPauli" );
DeclareGlobalFunction( "TensorPauli" );
DeclareGlobalFunction( "PauliPower" );
DeclareGlobalFunction( "PauliHermitianConjugate" );
DeclareGlobalFunction( "SingleQubitPauli" );
DeclareGlobalFunction( "PauliIdentity" );
