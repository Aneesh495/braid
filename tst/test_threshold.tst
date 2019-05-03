gap> START_TEST( "braid: threshold" );
gap> steane := SteaneCode();;
gap> lut := LookupTableDecoder( steane );;
gap> p_L := SimulateLogicalErrorRate( steane, lut, 0.0, 50 );;
gap> p_L;
0.
gap> curve := ComputeThresholdCurve( steane, lut, [ 0.001, 0.01 ], 50 );;
gap> Length( curve );
2
gap> STOP_TEST( "test_threshold.tst", 10000 );
