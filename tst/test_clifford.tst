gap> START_TEST( "braid: clifford" );
gap> omega1 := SymplecticFormOmega( 1 );;
gap> IsBinarySymplecticMatrix( omega1 );
true
gap> omega2 := SymplecticFormOmega( 2 );;
gap> IsBinarySymplecticMatrix( omega2 );
true
gap> id4 := [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ];;
gap> IsBinarySymplecticMatrix( id4 );
true
gap> tab := StabilizerTableau( 2 );;
gap> ApplyHadamard( tab, 1 );;
gap> ApplyCNOT( tab, 1, 2 );;
gap> M := TableauToSymplecticMatrix( tab );;
gap> IsBinarySymplecticMatrix( M );
true
gap> Minv := SymplecticInverse( M );;
gap> IsBinarySymplecticMatrix( Minv );
true
gap> prod := MultiplySymplecticMatrices( M, Minv );;
gap> prod = id4;
true
gap> invertible_mat := [ [ 1, 1 ], [ 0, 1 ] ];;
gap> cnot_circuit := SynthesizeCNOTCircuit( invertible_mat );;
gap> Length( cnot_circuit ) >= 1;
true
gap> STOP_TEST( "test_clifford.tst", 10000 );
