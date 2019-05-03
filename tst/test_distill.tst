gap> START_TEST( "braid: distill" );
gap> d := MagicStateDistillation15to1( 0.01 );;
gap> d.output_error < 0.0001;
true
gap> d.acceptance_probability > 0.95;
true
gap> lev := MagicStateFactoryLevels( 1.0e-6, 0.01 );;
gap> lev.required_levels >= 1;
true
gap> ccz := BravyiKitaevCCZFactory( 0.01 );;
gap> ccz.purified_ccz_yield;
2
gap> STOP_TEST( "test_distill.tst", 10000 );
