gap> START_TEST( "braid: opt" );
gap> circ := PhasePolynomialCircuit( 3 );;
gap> PhasePolyAddPhase( circ, 1, 1 );; # T on q1
gap> PhasePolyAddPhase( circ, 1, 1 );; # another T on q1 -> net angle 2 (S)
gap> PhasePolyTCount( circ );
2
gap> PhasePolyOptimize( circ );;
gap> PhasePolyTCount( circ );
0
gap> Length( PhasePolyTerms( circ ) );
1
gap> circ2 := PhasePolynomialCircuit( 2 );;
gap> PhasePolyAddPhase( circ2, 1, 1 );; # T
gap> PhasePolyAddPhase( circ2, 1, 7 );; # Tdg -> cancels!
gap> PhasePolyOptimize( circ2 );;
gap> Length( PhasePolyTerms( circ2 ) );
0
gap> circ3 := PhasePolynomialCircuit( 3 );;
gap> PhasePolyAddCNOT( circ3, 1, 2 );;
gap> PhasePolyAddPhase( circ3, 2, 1 );; # T on (q1 XOR q2)
gap> PhasePolyAddCNOT( circ3, 2, 3 );;
gap> PhasePolyAddPhase( circ3, 3, 2 );; # S on (q1 XOR q2 XOR q3)
gap> PhasePolyOptimize( circ3 );;
gap> PhasePolyTCount( circ3 );
1
gap> gates := PhasePolySynthesize( circ3 );;
gap> Length( gates ) > 0;
true
gap> STOP_TEST( "test_opt.tst", 10000 );
