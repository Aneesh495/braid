#############################################################################
##
##  lib/decoder.gd                 braid Package
##
##  Declarations for quantum syndrome decoders: Lookup Table (LUT),
##  Minimum-Weight Perfect Matching (MWPM) Blossom, and BP-OSD.
##
#############################################################################

DeclareGlobalFunction( "LookupTableDecoder" );
DeclareGlobalFunction( "DecodeWithLUT" );
DeclareGlobalFunction( "MWPMSurfaceDecoder" );
DeclareGlobalFunction( "DecodeWithMWPM" );
DeclareGlobalFunction( "BPOSDDecoder" );
DeclareGlobalFunction( "DecodeWithBPOSD" );
DeclareGlobalFunction( "VerifyCorrectionSuccess" );
