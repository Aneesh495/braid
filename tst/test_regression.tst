gap> START_TEST( "braid: regression" );
gap> # Regression test for bug 1: Global symbol collision with GAP library
gap> # IsBinarySymplecticMatrix must be declared cleanly without clashing with GAP's IsSymplecticMatrix
gap> om := SymplecticFormOmega( 2 );;
gap> IsBinarySymplecticMatrix( om );
true
gap> # Regression test for bug 2: Scoped local variables in BinaryNullspace
gap> null_test := [ [ 1, 1, 0 ], [ 0, 1, 1 ] ];;
gap> code_reg := StabilizerCode( 3, [ PauliFromString("+ZZI"), PauliFromString("+IZZ") ] );;
gap> logs := LogicalOperators( code_reg );;
gap> Length( logs );
1
gap> # Regression test for bug 3: Distillation reduction factor conditional evaluation
gap> d_zero := MagicStateDistillation15to1( 0.0 );;
gap> d_zero.error_reduction_factor;
0.
gap> d_pos := MagicStateDistillation15to1( 0.01 );;
gap> d_pos.error_reduction_factor > 100.0;
true
gap> STOP_TEST( "test_regression.tst", 10000 );
