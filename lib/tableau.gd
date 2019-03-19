#############################################################################
##
##  lib/tableau.gd                 braid Package
##
##  Declarations for the Gottesman-Knill stabilizer tableau engine,
##  Clifford gate transformations, and projective Pauli measurements.
##
#############################################################################

DeclareCategory( "IsStabilizerTableau", IsComponentObjectRep );

DeclareGlobalFunction( "StabilizerTableau" );
DeclareGlobalFunction( "CloneTableau" );
DeclareGlobalFunction( "TableauNumQubits" );
DeclareGlobalFunction( "RowSum" );
DeclareGlobalFunction( "ApplyHadamard" );
DeclareGlobalFunction( "ApplyPhase" );
DeclareGlobalFunction( "ApplyPhaseDagger" );
DeclareGlobalFunction( "ApplyPauliX" );
DeclareGlobalFunction( "ApplyPauliY" );
DeclareGlobalFunction( "ApplyPauliZ" );
DeclareGlobalFunction( "ApplyCNOT" );
DeclareGlobalFunction( "ApplyCZ" );
DeclareGlobalFunction( "ApplySWAP" );
DeclareGlobalFunction( "MeasurePauliZ" );
DeclareGlobalFunction( "MeasureArbitraryPauli" );
DeclareGlobalFunction( "GetStabilizerGenerators" );
DeclareGlobalFunction( "GetDestabilizerGenerators" );
DeclareGlobalFunction( "IsStabilizerTableauCanonical" );
DeclareGlobalFunction( "TableauToMatrix" );
DeclareGlobalFunction( "PrintTableau" );
