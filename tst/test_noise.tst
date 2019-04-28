gap> START_TEST( "braid: noise" );
gap> err0 := GenerateDepolarizingError( 5, 0.0 );;
gap> PauliWeight( err0 );
0
gap> err_xz := GenerateIndependentXZError( 5, 0.0, 0.0 );;
gap> PauliWeight( err_xz );
0
gap> noisy_syn := AddMeasurementReadoutErrors( [ 0, 0, 0 ], 0.0 );;
gap> noisy_syn;
[ 0, 0, 0 ]
gap> STOP_TEST( "test_noise.tst", 10000 );
