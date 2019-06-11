gap> START_TEST( "braid: graphstate" );
gap> c3 := ClusterState1D( 3 );;
gap> StabilizerNumQubits( c3 );
3
gap> StabilizerNumLogicalQubits( c3 );
0
gap> gens3 := List( StabilizerGenerators( c3 ), StringFromPauli );;
gap> "+XZI" in gens3;
true
gap> "+ZXZ" in gens3;
true
gap> "+IZX" in gens3;
true
gap> c2d := ClusterState2D( 2, 2 );;
gap> StabilizerNumQubits( c2d );
4
gap> A_star := [ [ 0, 1, 1 ], [ 1, 0, 0 ], [ 1, 0, 0 ] ];;
gap> A_lc := LocalComplementation( A_star, 1 );;
gap> A_lc[2][3];
1
gap> STOP_TEST( "test_graphstate.tst", 10000 );
