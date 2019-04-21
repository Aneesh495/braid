gap> START_TEST( "braid: qldpc" );
gap> C7 := CirculantMatrix( [ 0, 1 ], 7 );;
gap> Length( C7 );
7
gap> Length( C7[1] );
7
gap> gb := GeneralizedBicycleCode( [ 0, 1 ], [ 0, 2 ], 7 );;
gap> StabilizerNumQubits( gb );
14
gap> sp := QLDPCMatrixSparsity( gb );;
gap> sp.max_row_weight;
4
gap> hp := HypergraphProductCode( [ [ 1, 1 ] ], [ [ 1, 1 ] ] );;
gap> StabilizerNumQubits( hp );
5
gap> StabilizerNumLogicalQubits( hp );
1
gap> STOP_TEST( "test_qldpc.tst", 10000 );
