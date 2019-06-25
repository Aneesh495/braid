gap> START_TEST( "braid: color" );
gap> c3 := ColorCode( 3 );;
gap> StabilizerNumQubits( c3 );
7
gap> StabilizerNumLogicalQubits( c3 );
1
gap> ColorCodeDistance( c3 );
3
gap> Length( ColorCodeFaces( c3 ) );
3
gap> ColorCodeVerifyTransversalClifford( c3 );
true
gap> lx := ColorCodeLogicalX( c3 );;
gap> PauliWeight( lx );
7
gap> lz := ColorCodeLogicalZ( c3 );;
gap> PauliWeight( lz );
7
gap> SymplecticInnerProduct( lx, lz );
1
gap> STOP_TEST( "test_color.tst", 10000 );
