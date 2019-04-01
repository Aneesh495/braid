gap> START_TEST( "braid: stabilizer" );
gap> code5 := FiveQubitCode();;
gap> StabilizerNumQubits( code5 );
5
gap> StabilizerNumLogicalQubits( code5 );
1
gap> ComputeCodeDistance( code5 );
3
gap> bit3 := ThreeQubitBitFlipCode();;
gap> StabilizerNumQubits( bit3 );
3
gap> StabilizerNumLogicalQubits( bit3 );
1
gap> syn := SyndromeFromPauli( bit3, PauliFromString( "+XII" ) );;
gap> syn;
[ 1, 0 ]
gap> syn_z := SyndromeFromPauli( bit3, PauliFromString( "+ZII" ) );;
gap> syn_z;
[ 0, 0 ]
gap> STOP_TEST( "test_stabilizer.tst", 10000 );
