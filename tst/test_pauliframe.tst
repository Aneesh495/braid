gap> START_TEST( "braid: pauliframe" );
gap> pf := PauliFrame( 3 );;
gap> PauliFrameWeight( pf );
0
gap> PauliFrameApplyPauli( pf, 1, "X" );;
gap> PauliFrameWeight( pf );
1
gap> PauliFrameApplyH( pf, 1 );; # X -> Z
gap> pf!.x[1];
0
gap> pf!.z[1];
1
gap> PauliFrameApplyH( pf, 1 );; # Z -> X
gap> pf!.x[1];
1
gap> pf!.z[1];
0
gap> PauliFrameApplyCNOT( pf, 1, 2 );; # X1 -> X1 X2
gap> pf!.x[2];
1
gap> PauliFrameCorrectMeasurement( pf, 2, 0 ); # flipped by X2
1
gap> PauliFrameCorrectMeasurement( pf, 2, 1 );
0
gap> PauliFrameCorrectMeasurement( pf, 3, 0 ); # untouched qubit
0
gap> op := PauliFrameToPauliOperator( pf );;
gap> PauliWeight( op );
2
gap> PauliFrameReset( pf );;
gap> PauliFrameWeight( pf );
0
gap> STOP_TEST( "test_pauliframe.tst", 10000 );
