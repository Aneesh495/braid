gap> START_TEST( "braid: surgery" );
gap> pA := RotatedSurfaceCode( 3 );;
gap> pB := RotatedSurfaceCode( 3 );;
gap> merged_zz := LatticeSurgeryMergeZZ( pA, pB );;
gap> StabilizerNumQubits( merged_zz );
18
gap> Length( LatticeSurgeryJointMeasurement( merged_zz ) );
3
gap> merged_xx := LatticeSurgeryMergeXX( pA, pB );;
gap> StabilizerNumQubits( merged_xx );
18
gap> Length( LatticeSurgeryJointMeasurement( merged_xx ) );
3
gap> STOP_TEST( "test_surgery.tst", 10000 );
