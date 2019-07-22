#############################################################################
##
##  benchmarks/bench_cnot.g        braid Package
##
##  Synthesis benchmark for CNOT circuit decomposition over GL(n, F2):
##  measures synthesis latency, CNOT gate counts, and gate density.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

GenerateRandomInvertibleMatrix := function( n )
  local mat, step, r1, r2, c, i;
  mat := List( [1 .. n], i -> ListWithIdenticalEntries( n, 0 ) );
  for i in [1 .. n] do
    mat[i][i] := 1;
  od;

  # Apply random elementary row additions (guaranteed invertible)
  for step in [1 .. 3 * n] do
    r1 := Random( [1 .. n] );
    r2 := Random( [1 .. n] );
    if r1 <> r2 then
      for c in [1 .. n] do
        mat[r1][c] := (mat[r1][c] + mat[r2][c]) mod 2;
      od;
    fi;
  od;

  return mat;
end;

RunCNOTBenchmark := function( n, num_matrices )
  local t0, t1, iter, mat, circuit, total_cnots, elapsed_ms, synth_per_sec, avg_cnots;

  total_cnots := 0;
  t0 := Runtime();

  for iter in [1 .. num_matrices] do
    mat := GenerateRandomInvertibleMatrix( n );
    circuit := SynthesizeCNOTCircuit( mat );
    total_cnots := total_cnots + Length( circuit );
  od;

  t1 := Runtime();
  elapsed_ms := Maximum( 1, t1 - t0 );
  synth_per_sec := Int( (Float( num_matrices ) / Float( elapsed_ms )) * 1000.0 );
  avg_cnots := Int( Float( total_cnots ) / Float( num_matrices ) );

  Print( String( n, 8 ), " | ",
         String( num_matrices, 10 ), " | ",
         String( avg_cnots, 10 ), " | ",
         String( elapsed_ms, 12 ), " | ",
         String( synth_per_sec, 12 ), "\n" );
end;

Print( "\n=================================================================\n" );
Print( "              braid Benchmark: CNOT Circuit Synthesis            \n" );
Print( "=================================================================\n" );
Print( "Dimension|  Matrices  | Avg CNOTs  | Elapsed (ms) | Syntheses/sec \n" );
Print( "---------+------------+------------+--------------+---------------\n" );

for n in [ 4, 8, 12, 16, 20, 28 ] do
  RunCNOTBenchmark( n, 20 );
od;

Print( "=================================================================\n\n" );
