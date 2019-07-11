#############################################################################
##
##  benchmarks/bench_tableau.g     braid Package
##
##  Performance benchmark for Gottesman-Knill stabilizer tableau engine:
##  measures scaling of single-qubit Cliffords, two-qubit CNOTs, and measurements
##  as a function of qubit register width n.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

RunTableauBenchmark := function( nqubits, num_gates )
  local tab, t0, t1, g, q1, q2, op_type, elapsed_ms, gates_per_sec;

  tab := StabilizerTableau( nqubits );

  t0 := Runtime();

  for g in [1 .. num_gates] do
    op_type := g mod 4;
    q1 := (g mod nqubits) + 1;
    q2 := ((g + 1) mod nqubits) + 1;

    if op_type = 0 then
      ApplyHadamard( tab, q1 );
    elif op_type = 1 then
      ApplyPhase( tab, q1 );
    elif op_type = 2 then
      ApplyCNOT( tab, q1, q2 );
    else
      MeasurePauliZ( tab, q1 );
    fi;
  od;

  t1 := Runtime();
  elapsed_ms := Maximum( 1, t1 - t0 );
  gates_per_sec := Int( (Float( num_gates ) / Float( elapsed_ms )) * 1000.0 );

  Print( String( nqubits, 8 ), " | ",
         String( num_gates, 14 ), " | ",
         String( elapsed_ms, 12 ), " | ",
         String( gates_per_sec, 14 ), "\n" );
end;

Print( "\n=================================================================\n" );
Print( "         braid Benchmark: Stabilizer Tableau Scaling             \n" );
Print( "=================================================================\n" );
Print( "  Qubits | Gates Executed | Elapsed (ms) |      Gates/sec \n" );
Print( "---------+----------------+--------------+----------------\n" );

for n in [ 10, 25, 50, 100, 200 ] do
  RunTableauBenchmark( n, 2000 );
od;

Print( "=================================================================\n\n" );
