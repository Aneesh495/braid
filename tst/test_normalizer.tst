gap> START_TEST( "braid: normalizer" );
gap> SymplecticGroupF2Order( 1 );
6
gap> SymplecticGroupF2Order( 2 );
720
gap> CliffordGroupOrder( 1 );
24
gap> CliffordGroupOrder( 2 );
11520
gap> steane := SteaneCode();;
gap> norm_info := StabilizerCentralizerInClifford( steane );;
gap> norm_info.identity_normalizes;
true
gap> STOP_TEST( "test_normalizer.tst", 10000 );
