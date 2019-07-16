#############################################################################
##
##  benchmarks/bench_threshold.g   braid Package
##
##  Throughput and scaling benchmark for Monte Carlo surface code threshold
##  simulations under depolarizing and phenomenological Pauli noise.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

RunThresholdBenchmark := function( code, p, trials )
  local decoder, t0, t1, p_L, elapsed_ms, trials_per_sec, failures;

  decoder := LookupTableDecoder( code );

  t0 := Runtime();
  p_L := SimulateLogicalErrorRate( code, decoder, p, trials );
  t1 := Runtime();

  failures := Int( p_L * Float( trials ) );
  elapsed_ms := Maximum( 1, t1 - t0 );
  trials_per_sec := Int( (Float( trials ) / Float( elapsed_ms )) * 1000.0 );

  Print( String( code!.nqubits, 8 ), " | ",
         String( p, 16 ), " | ",
         String( trials, 8 ), " | ",
         String( failures, 14 ), " | ",
         String( p_L, 10 ), " | ",
         String( trials_per_sec, 12 ), "\n" );
end;

Print( "\n=================================================================================\n" );
Print( "              braid Benchmark: Surface Code Threshold Throughput                 \n" );
Print( "=================================================================================\n" );
Print( "  Qubits | Physical Error p | Trials  | Logical Errors | Fail Rate  |  Trials/sec  \n" );
Print( "---------+------------------+---------+----------------+------------+--------------\n" );

c_steane := SteaneCode();
c_surf := RotatedSurfaceCode( 3 );

for code in [ c_steane, c_surf ] do
  for p in [ 0.01, 0.05, 0.10 ] do
    RunThresholdBenchmark( code, p, 100 );
  od;
od;

Print( "=================================================================================\n\n" );
