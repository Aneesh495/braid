gap> START_TEST( "braid: statevec" );
gap> # Product state |00>: stabilizers Z1, Z2
gap> z1 := PauliOperator( 2, 0, [0, 0], [1, 0] );;
gap> z2 := PauliOperator( 2, 0, [0, 0], [0, 1] );;
gap> StabilizerEntanglementEntropy( [z1, z2], [1] );
0
gap> # Bell state |00> + |11>: stabilizers X1 X2, Z1 Z2
gap> xx := PauliOperator( 2, 0, [1, 1], [0, 0] );;
gap> zz := PauliOperator( 2, 0, [0, 0], [1, 1] );;
gap> StabilizerEntanglementEntropy( [xx, zz], [1] );
1
gap> # GHZ state on 3 qubits
gap> g1 := PauliOperator( 3, 0, [1, 1, 1], [0, 0, 0] );;
gap> g2 := PauliOperator( 3, 0, [0, 0, 0], [1, 1, 0] );;
gap> g3 := PauliOperator( 3, 0, [0, 0, 0], [0, 1, 1] );;
gap> StabilizerEntanglementEntropy( [g1, g2, g3], [1] );
1
gap> # Statevector for |00>
gap> psi := StabilizerStatevector( [z1, z2], 2 );;
gap> Length( psi );
4
gap> StatevectorFidelity( psi, psi );
1.
gap> STOP_TEST( "test_statevec.tst", 10000 );
