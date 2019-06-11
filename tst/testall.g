#############################################################################
##
##  tst/testall.g                  braid Package
##
##  Master test runner for the braid quantum computation package.
##
#############################################################################

SetPackagePath( "braid", "." );
Read( "init.g" );
Read( "read.g" );

test_files := [
  "tst/test_pauli.tst",
  "tst/test_tableau.tst",
  "tst/test_clifford.tst",
  "tst/test_stabilizer.tst",
  "tst/test_css.tst",
  "tst/test_transversal.tst",
  "tst/test_surface.tst",
  "tst/test_qldpc.tst",
  "tst/test_noise.tst",
  "tst/test_decoder.tst",
  "tst/test_qasm.tst",
  "tst/test_distill.tst",
  "tst/test_threshold.tst",
  "tst/test_normalizer.tst",
  "tst/test_graphstate.tst",
  "tst/test_regression.tst"
];

Print( "\n=======================================================\n" );
Print( "              braid Master GAP Test Suite              \n" );
Print( "=======================================================\n\n" );

total_passed := 0;
total_failed := 0;

for tst_path in test_files do
  Print( "Running ", tst_path, " ... " );
  res := Test( tst_path, rec( compareFunction := "uptowhitespace" ) );
  if res then
    Print( "PASSED\n" );
    total_passed := total_passed + 1;
  else
    Print( "FAILED\n" );
    total_failed := total_failed + 1;
  fi;
od;

Print( "\n=======================================================\n" );
Print( "Summary: ", total_passed, " passed, ", total_failed, " failed out of ", Length( test_files ), " test suites.\n" );
Print( "=======================================================\n\n" );

if total_failed > 0 then
  Error( "Some GAP tests failed!" );
fi;

QUIT_GAP( 0 );
