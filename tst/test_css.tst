gap> START_TEST( "braid: css" );
gap> steane := SteaneCode();;
gap> StabilizerNumQubits( steane );
7
gap> StabilizerNumLogicalQubits( steane );
1
gap> ComputeCodeDistance( steane );
3
gap> IsCSSCode( steane );
true
gap> Length( CSSXStabilizers( steane ) );
3
gap> Length( CSSZStabilizers( steane ) );
3
gap> shor := ShorCode();;
gap> StabilizerNumQubits( shor );
9
gap> StabilizerNumLogicalQubits( shor );
1
gap> IsCSSCode( shor );
true
gap> STOP_TEST( "test_css.tst", 10000 );
