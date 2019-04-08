gap> START_TEST( "braid: transversal" );
gap> steane := SteaneCode();;
gap> IsTransversalHadamardValid( steane );
true
gap> IsTransversalCNOTValid( steane );
true
gap> TransversalLogicalAction( steane, "H" );
"Logical_H"
gap> TransversalLogicalAction( steane, "CNOT" );
"Logical_CNOT"
gap> p := PauliFromString( "+XIZ" );;
gap> perm := (1, 2);;
gap> p_perm := PermutePauliOperator( p, perm );;
gap> StringFromPauli( p_perm );
"+IXZ"
gap> STOP_TEST( "test_transversal.tst", 10000 );
