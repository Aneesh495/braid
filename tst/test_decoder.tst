gap> START_TEST( "braid: decoder" );
gap> steane := SteaneCode();;
gap> lut := LookupTableDecoder( steane );;
gap> err_x1 := PauliFromString( "+XIIIIII" );;
gap> syn1 := SyndromeFromPauli( steane, err_x1 );;
gap> rec1 := DecodeWithLUT( lut, syn1 );;
gap> StringFromPauli( rec1 );
"+XIIIIII"
gap> ver1 := VerifyCorrectionSuccess( steane, err_x1, rec1 );;
gap> ver1.success;
true
gap> err_z2 := PauliFromString( "+IZIIIII" );;
gap> syn2 := SyndromeFromPauli( steane, err_z2 );;
gap> rec2 := DecodeWithLUT( lut, syn2 );;
gap> StringFromPauli( rec2 );
"+IZIIIII"
gap> ver2 := VerifyCorrectionSuccess( steane, err_z2, rec2 );;
gap> ver2.success;
true
gap> sc3 := RotatedSurfaceCode( 3 );;
gap> mwpm := MWPMSurfaceDecoder( sc3 );;
gap> err_sc := PauliFromString( "+XIIIIIIII" );;
gap> syn_sc := SyndromeFromPauli( sc3, err_sc );;
gap> rec_mwpm := DecodeWithMWPM( mwpm, syn_sc );;
gap> PauliWeight( rec_mwpm ) >= 0;
true
gap> STOP_TEST( "test_decoder.tst", 10000 );
