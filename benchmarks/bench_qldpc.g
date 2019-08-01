#############################################################################
##
##  benchmarks/bench_qldpc.g       braid Package
##
##  Structural benchmark for Group-Algebra Quantum LDPC codes:
##  evaluates check matrix sparsity, asymptotic rate k/n, and construction latency
##  across Generalized Bicycle and Hypergraph Product codes.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

RunQLDPCBenchmark := function( ell )
  local t0, t1, gb, sp, elapsed_ms, n, k, rate;

  t0 := Runtime();
  gb := GeneralizedBicycleCode( [ 0, 1, 3 ], [ 0, 2, 5 ], ell );
  t1 := Runtime();

  elapsed_ms := Maximum( 1, t1 - t0 );
  n := StabilizerNumQubits( gb );
  k := StabilizerNumLogicalQubits( gb );
  rate := Float( k ) / Float( n );
  sp := QLDPCMatrixSparsity( gb );

  Print( String( ell, 11 ), " | ",
         String( n, 10 ), " | ",
         String( k, 11 ), " | ",
         String( sp.max_row_weight, 14 ), " | ",
         String( rate, 12 ), " | ",
         String( elapsed_ms, 12 ), "\n" );
end;

Print( "\n=================================================================================\n" );
Print( "              braid Benchmark: Group-Algebra Quantum LDPC Codes                  \n" );
Print( "=================================================================================\n" );
Print( "Group Order | n (Qubits) | k (Logical) | Max Row Weight | Rate (k/n)   | Elapsed (ms)  \n" );
Print( "------------+------------+-------------+----------------+--------------+---------------\n" );

for l in [ 7, 15, 31, 63 ] do
  RunQLDPCBenchmark( l );
od;

Print( "=================================================================================\n\n" );
