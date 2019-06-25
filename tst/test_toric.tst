gap> START_TEST( "braid: toric" );
gap> tc2 := ToricCode( 2 );;
gap> StabilizerNumQubits( tc2 );
8
gap> StabilizerNumLogicalQubits( tc2 );
2
gap> ToricCodeLinearSize( tc2 );
2
gap> Length( ToricCodeStarStabilizers( tc2 ) );
3
gap> Length( ToricCodePlaquetteStabilizers( tc2 ) );
3
gap> ops2 := ToricCodeLogicalOperators( tc2 );;
gap> PauliWeight( ops2.z1 );
2
gap> PauliWeight( ops2.x1 );
2
gap> SymplecticInnerProduct( ops2.z1, ops2.x1 );
1
gap> SymplecticInnerProduct( ops2.z2, ops2.x2 );
1
gap> SymplecticInnerProduct( ops2.z1, ops2.x2 );
0
gap> SymplecticInnerProduct( ops2.z2, ops2.x1 );
0
gap> tc3 := ToricCode( 3 );;
gap> StabilizerNumQubits( tc3 );
18
gap> StabilizerNumLogicalQubits( tc3 );
2
gap> ToricCodeLinearSize( tc3 );
3
gap> ops3 := ToricCodeLogicalOperators( tc3 );;
gap> PauliWeight( ops3.z1 );
3
gap> PauliWeight( ops3.x1 );
3
gap> SymplecticInnerProduct( ops3.z1, ops3.x1 );
1
gap> SymplecticInnerProduct( ops3.z2, ops3.x2 );
1
gap> STOP_TEST( "test_toric.tst", 10000 );
