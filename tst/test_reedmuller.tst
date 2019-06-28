gap> START_TEST( "braid: reedmuller" );
gap> rm := QuantumReedMullerCode();;
gap> StabilizerNumQubits( rm );
15
gap> StabilizerNumLogicalQubits( rm );
1
gap> ReedMullerTransversalT( rm );
true
gap> lx := ReedMullerLogicalX( rm );;
gap> lz := ReedMullerLogicalZ( rm );;
gap> PauliWeight( lx );
15
gap> PauliWeight( lz );
7
gap> SymplecticInnerProduct( lx, lz );
1
gap> IsTriplyEvenCode( CSSXMatrix( rm ) );
true
gap> STOP_TEST( "test_reedmuller.tst", 10000 );
