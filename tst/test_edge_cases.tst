gap> START_TEST( "braid: edge cases" );
gap> # Edge Case 1: Trivial 1-qubit code with no stabilizers (k = 1)
gap> triv1 := StabilizerCode( 1, [ ] );;
gap> StabilizerNumQubits( triv1 );
1
gap> StabilizerNumLogicalQubits( triv1 );
1
gap> # Edge Case 2: 1-qubit pure state code (k = 0) with generator Z
gap> z_gen := PauliFromString( "+Z" );;
gap> code_pure := StabilizerCode( 1, [ z_gen ] );;
gap> StabilizerNumQubits( code_pure );
1
gap> StabilizerNumLogicalQubits( code_pure );
0
gap> # Edge Case 3: Syndrome of Identity Pauli error is all zeros
gap> id_err := PauliFromString( "+IIIIIII" );;
gap> steane := SteaneCode();;
gap> syn_id := SyndromeFromPauli( steane, id_err );;
gap> Sum( syn_id );
0
gap> # Edge Case 4: Zero noise injection produces weight-0 error
gap> zero_shot := InjectPhenomenologicalNoise( steane, 0.0 );;
gap> PauliWeight( zero_shot.error );
0
gap> Sum( zero_shot.syndrome );
0
gap> # Edge Case 5: LUT decoder on zero syndrome returns identity recovery
gap> lut := LookupTableDecoder( steane );;
gap> rec_id := DecodeWithLUT( lut, syn_id );;
gap> PauliWeight( rec_id );
0
gap> # Edge Case 6: MWPM decoder on zero syndrome returns identity recovery
gap> sc3 := RotatedSurfaceCode( 3 );;
gap> mwpm := MWPMSurfaceDecoder( sc3 );;
gap> syn_zero_sc := ListWithIdenticalEntries( Length( sc3!.generators ), 0 );;
gap> rec_mwpm_zero := DecodeWithMWPM( mwpm, syn_zero_sc );;
gap> PauliWeight( rec_mwpm_zero );
0
gap> # Edge Case 7: Graph state on complete graph K3
gap> adj_k3 := [ [ 0, 1, 1 ], [ 1, 0, 1 ], [ 1, 1, 0 ] ];;
gap> gs_k3 := GraphState( adj_k3 );;
gap> StabilizerNumQubits( gs_k3 );
3
gap> StabilizerNumLogicalQubits( gs_k3 );
0
gap> # Edge Case 8: Phase polynomial optimizer with no gates
gap> empty_poly := PhasePolynomialCircuit( 4 );;
gap> PhasePolyOptimize( empty_poly );;
gap> PhasePolyTCount( empty_poly );
0
gap> Length( PhasePolyTerms( empty_poly ) );
0
gap> STOP_TEST( "test_edge_cases.tst", 10000 );
