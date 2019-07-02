#############################################################################
##
##  lib/pauliframe.gd             braid Package
##
##  Declarations for classical Pauli Frame tracking: virtual software updates
##  under Clifford gates and zero-latency measurement correction.
##
#############################################################################

DeclareGlobalFunction( "PauliFrame" );
DeclareGlobalFunction( "PauliFrameApplyPauli" );
DeclareGlobalFunction( "PauliFrameApplyH" );
DeclareGlobalFunction( "PauliFrameApplyS" );
DeclareGlobalFunction( "PauliFrameApplyCNOT" );
DeclareGlobalFunction( "PauliFrameCorrectMeasurement" );
DeclareGlobalFunction( "PauliFrameToPauliOperator" );
DeclareGlobalFunction( "PauliFrameReset" );
DeclareGlobalFunction( "PauliFrameWeight" );
