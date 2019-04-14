gap> START_TEST( "braid: surface" );
gap> sc3 := RotatedSurfaceCode( 3 );;
gap> StabilizerNumQubits( sc3 );
9
gap> StabilizerNumLogicalQubits( sc3 );
1
gap> SurfaceCodeDistance( sc3 );
3
gap> Length( SurfaceCodeXStabilizers( sc3 ) );
4
gap> Length( SurfaceCodeZStabilizers( sc3 ) );
4
gap> logX := SurfaceCodeLogicalX( sc3 );;
gap> logZ := SurfaceCodeLogicalZ( sc3 );;
gap> PauliWeight( logX );
3
gap> PauliWeight( logZ );
3
gap> CommutesWith( logX, logZ );
false
gap> syn := SurfaceCodeSyndromes( sc3, PauliFromString( "+XIIIIIIII" ) );;
gap> syn.z_syndromes[3];
1
gap> STOP_TEST( "test_surface.tst", 10000 );
