gap> START_TEST( "braid: pauli" );
gap> pX := PauliFromString( "+X" );;
gap> pY := PauliFromString( "+Y" );;
gap> pZ := PauliFromString( "+Z" );;
gap> pI := PauliIdentity( 1 );;
gap> StringFromPauli( pX );
"+X"
gap> StringFromPauli( pY );
"+Y"
gap> StringFromPauli( pZ );
"+Z"
gap> StringFromPauli( pI );
"+I"
gap> StringFromPauli( MultiplyPauli( pX, pY ) );
"+iZ"
gap> StringFromPauli( MultiplyPauli( pY, pX ) );
"-iZ"
gap> StringFromPauli( MultiplyPauli( pX, pZ ) );
"-iY"
gap> StringFromPauli( MultiplyPauli( pZ, pX ) );
"+iY"
gap> StringFromPauli( MultiplyPauli( pY, pZ ) );
"+iX"
gap> StringFromPauli( MultiplyPauli( pZ, pY ) );
"-iX"
gap> CommutesWith( pX, pZ );
false
gap> CommutesWith( pX, pX );
true
gap> CommutesWith( pI, pX );
true
gap> p2 := PauliFromString( "+XZ" );;
gap> PauliWeight( p2 );
2
gap> p3 := PauliFromString( "-iXI" );;
gap> PauliWeight( p3 );
1
gap> StringFromPauli( PauliPower( pX, 2 ) );
"+I"
gap> StringFromPauli( PauliPower( pX, 3 ) );
"+X"
gap> StringFromPauli( PauliHermitianConjugate( p3 ) );
"+iXI"
gap> pTens := TensorPauli( pX, pZ );;
gap> StringFromPauli( pTens );
"+XZ"
gap> STOP_TEST( "test_pauli.tst", 10000 );
