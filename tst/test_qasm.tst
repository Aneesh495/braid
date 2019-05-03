gap> START_TEST( "braid: qasm" );
gap> qasm_str := "OPENQASM 2.0;\nqreg q[2];\nh q[0];\ncx q[0], q[1];\n";;
gap> ast := ParseQASMString( qasm_str );;
gap> ast.num_qubits;
2
gap> QASMInstructionCount( ast );
2
gap> tab := StabilizerTableau( ast.num_qubits );;
gap> ExecuteQASMOnTableau( ast, tab );;
gap> stabs := List( GetStabilizerGenerators( tab ), StringFromPauli );;
gap> "+XX" in stabs;
true
gap> "+ZZ" in stabs;
true
gap> qasm_out := EmitOpenQASM( ast.num_qubits, ast.instructions );;
gap> Length( qasm_out ) > 0;
true
gap> STOP_TEST( "test_qasm.tst", 10000 );
