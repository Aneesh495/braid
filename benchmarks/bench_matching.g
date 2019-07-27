#############################################################################
##
##  benchmarks/bench_matching.g    braid Package
##
##  Throughput and latency benchmark for Minimum-Weight Perfect Matching (MWPM)
##  Blossom decoder across rotated surface code patches of increasing distance.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

RunMatchingBenchmark := function( d, num_shots )
  local code, decoder, t0, t1, shot, noise_shot, recov, elapsed_ms, decodes_per_sec;

  code := RotatedSurfaceCode( d );
  decoder := MWPMSurfaceDecoder( code );

  t0 := Runtime();

  for shot in [1 .. num_shots] do
    noise_shot := InjectPhenomenologicalNoise( code, 0.05 );
    recov := DecodeWithMWPM( decoder, noise_shot.syndrome );
  od;

  t1 := Runtime();
  elapsed_ms := Maximum( 1, t1 - t0 );
  decodes_per_sec := Int( (Float( num_shots ) / Float( elapsed_ms )) * 1000.0 );

  Print( String( d, 8 ), " | ",
         String( code!.nqubits, 12 ), " | ",
         String( Length( code!.generators ), 11 ), " | ",
         String( num_shots, 10 ), " | ",
         String( elapsed_ms, 12 ), " | ",
         String( decodes_per_sec, 12 ), "\n" );
end;

Print( "\n=================================================================================\n" );
Print( "              braid Benchmark: MWPM Blossom Decoder Latency                      \n" );
Print( "=================================================================================\n" );
Print( "Distance | Total Qubits | Stabilizers |  Decodes   | Elapsed (ms) |  Decodes/sec  \n" );
Print( "---------+--------------+-------------+------------+--------------+---------------\n" );

for dist in [ 3, 5 ] do
  RunMatchingBenchmark( dist, 500 );
od;

Print( "=================================================================================\n\n" );
