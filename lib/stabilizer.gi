#############################################################################
##
##  lib/stabilizer.gi              braid Package
##
##  Implementations for generic quantum stabilizer codes [[n, k, d]],
##  check matrices, canonicalization, and logical operators.
##
#############################################################################

CodeFamily := NewFamily( "StabilizerCodeFamily", IsStabilizerCode );
CodeType := NewType( CodeFamily, IsStabilizerCode );

#############################################################################
##
##  BinaryNullspace( M )
##
##  Computes a basis for the nullspace of a binary matrix M over F2:
##  finds all vectors v such that M * v = 0 mod 2.
##
BinaryNullspace := function( M )
  local rows, cols, A, r, c, pivot_col, pivot_row, pivots, free_cols, basis, b, j, k, p;

  rows := Length( M );
  if rows = 0 then
    return [ ];
  fi;
  cols := Length( M[1] );

  # Work on a copy of M
  A := List( M, r -> ShallowCopy( r ) );
  pivots := [ ];
  pivot_row := 1;

  for c in [1 .. cols] do
    # Find pivot in column c
    pivot_col := 0;
    for r in [pivot_row .. rows] do
      if A[r][c] = 1 then
        pivot_col := r;
        break;
      fi;
    od;

    if pivot_col > 0 then
      # Swap rows if necessary
      if pivot_col <> pivot_row then
        b := A[pivot_row];
        A[pivot_row] := A[pivot_col];
        A[pivot_col] := b;
      fi;

      # Eliminate other rows
      for r in [1 .. rows] do
        if r <> pivot_row and A[r][c] = 1 then
          for k in [1 .. cols] do
            A[r][k] := (A[r][k] + A[pivot_row][k]) mod 2;
          od;
        fi;
      od;

      Add( pivots, [ pivot_row, c ] );
      pivot_row := pivot_row + 1;
      if pivot_row > rows then
        break;
      fi;
    fi;
  od;

  free_cols := Difference( [1 .. cols], List( pivots, p -> p[2] ) );
  basis := [ ];

  for j in free_cols do
    b := ListWithIdenticalEntries( cols, 0 );
    b[j] := 1;
    for p in pivots do
      r := p[1];
      c := p[2];
      if A[r][j] = 1 then
        b[c] := 1;
      fi;
    od;
    Add( basis, b );
  od;

  return basis;
end;

#############################################################################
##
##  StabilizerCode( nqubits, generators )
##
##  Constructs a stabilizer code from an independent list of commuting
##  Pauli generators.
##
InstallGlobalFunction( StabilizerCode, function( nqubits, generators )
  local n, m, k, i, j, g1, g2, check_mat, x, z;

  n := nqubits;
  m := Length( generators );

  if m > n then
    Error( "StabilizerCode: number of generators cannot exceed nqubits" );
  fi;

  # Check that generators pairwise commute
  for i in [1 .. m] do
    g1 := generators[i];
    if g1!.nqubits <> n then
      Error( "StabilizerCode: generator qubit count does not match nqubits" );
    fi;
    for j in [i + 1 .. m] do
      g2 := generators[j];
      if not CommutesWith( g1, g2 ) then
        Error( "StabilizerCode: generators ", i, " and ", j, " do not commute" );
      fi;
    od;
  od;

  k := n - m;

  # Construct check matrix: m rows by 2n columns
  check_mat := [ ];
  for i in [1 .. m] do
    Add( check_mat, Concatenation( generators[i]!.x, generators[i]!.z ) );
  od;

  return Objectify( CodeType, rec(
    nqubits := n,
    k := k,
    generators := List( generators, g -> PauliFromString( StringFromPauli( g ) ) ),
    check_matrix := check_mat,
    cached_distance := -1,
    cached_logicals := fail
  ) );
end );

#############################################################################
##
##  StabilizerGenerators( code )
##
InstallGlobalFunction( StabilizerGenerators, function( code )
  return code!.generators;
end );

#############################################################################
##
##  StabilizerCheckMatrix( code )
##
InstallGlobalFunction( StabilizerCheckMatrix, function( code )
  return code!.check_matrix;
end );

#############################################################################
##
##  StabilizerNumQubits( code )
##
InstallGlobalFunction( StabilizerNumQubits, function( code )
  return code!.nqubits;
end );

#############################################################################
##
##  StabilizerNumLogicalQubits( code )
##
InstallGlobalFunction( StabilizerNumLogicalQubits, function( code )
  return code!.k;
end );

#############################################################################
##
##  CanonicalizeStabilizers( code )
##
##  Pivots the check matrix over F2 to standard isotropic generator form.
##
InstallGlobalFunction( CanonicalizeStabilizers, function( code )
  local n, m, H, r, c, pivot, row, k, canon_gens;
  n := code!.nqubits;
  m := Length( code!.generators );
  H := List( code!.check_matrix, r -> ShallowCopy( r ) );

  pivot := 1;
  for c in [1 .. 2 * n] do
    row := 0;
    for r in [pivot .. m] do
      if H[r][c] = 1 then
        row := r;
        break;
      fi;
    od;

    if row > 0 then
      if row <> pivot then
        H{[pivot, row]} := H{[row, pivot]};
      fi;

      for r in [1 .. m] do
        if r <> pivot and H[r][c] = 1 then
          for k in [1 .. 2 * n] do
            H[r][k] := (H[r][k] + H[pivot][k]) mod 2;
          od;
        fi;
      od;

      pivot := pivot + 1;
      if pivot > m then
        break;
      fi;
    fi;
  od;

  canon_gens := [ ];
  for r in [1 .. m] do
    Add( canon_gens, PauliOperator( n, 0, H[r]{[1 .. n]}, H[r]{[n + 1 .. 2 * n]} ) );
  od;

  return StabilizerCode( n, canon_gens );
end );

#############################################################################
##
##  LogicalOperators( code )
##
##  Computes k canonical logical pairs (X_bar_j, Z_bar_j) that commute with all
##  stabilizers and satisfy <X_bar_i, Z_bar_j> = delta_ij.
##
InstallGlobalFunction( LogicalOperators, function( code )
  local n, m, k, H, H_omega, null_basis, indep_centralizers, log_pairs, i, j, v, p_cand, found_z, z_cand;

  if code!.cached_logicals <> fail then
    return code!.cached_logicals;
  fi;

  n := code!.nqubits;
  k := code!.k;

  if k = 0 then
    code!.cached_logicals := [ ];
    return [ ];
  fi;

  H := code!.check_matrix;
  m := Length( H );

  # H * Omega has rows [ Z | X ]
  H_omega := List( H, r -> Concatenation( r{[n + 1 .. 2 * n]}, r{[1 .. n]} ) );

  # Centralizer space C(S) is the nullspace of H_omega
  null_basis := BinaryNullspace( H_omega );

  # Extract elements not in the span of the stabilizers
  log_pairs := [ ];
  for i in [1 .. Length( null_basis )] do
    v := null_basis[i];
    p_cand := PauliOperator( n, 0, v{[1 .. n]}, v{[n + 1 .. 2 * n]} );

    # Check that p_cand is not identity and not trivial
    if PauliWeight( p_cand ) > 0 then
      # Look for a conjugate partner Z_bar with symplectic inner product = 1
      found_z := false;
      for j in [i + 1 .. Length( null_basis )] do
        z_cand := PauliOperator( n, 0, null_basis[j]{[1 .. n]}, null_basis[j]{[n + 1 .. 2 * n]} );
        if SymplecticInnerProduct( p_cand, z_cand ) = 1 then
          Add( log_pairs, rec( X_bar := p_cand, Z_bar := z_cand ) );
          found_z := true;
          break;
        fi;
      od;
      if Length( log_pairs ) = k then
        break;
      fi;
    fi;
  od;

  code!.cached_logicals := log_pairs;
  return log_pairs;
end );

#############################################################################
##
##  SyndromeFromPauli( code, error_pauli )
##
##  Computes the binary syndrome vector s in F2^m for a given Pauli error:
##  s_i = <g_i, error_pauli>_sym.
##
InstallGlobalFunction( SyndromeFromPauli, function( code, error_pauli )
  local gens, syn, i;
  gens := code!.generators;
  syn := List( [1 .. Length( gens )], i -> SymplecticInnerProduct( gens[i], error_pauli ) );
  return syn;
end );

#############################################################################
##
##  ComputeCodeDistance( code )
##
##  Calculates the minimum weight of any non-trivial logical operator
##  in C(S) \ S.
##
InstallGlobalFunction( ComputeCodeDistance, function( code )
  local logs, d, pair;

  if code!.cached_distance <> -1 then
    return code!.cached_distance;
  fi;

  logs := LogicalOperators( code );
  if Length( logs ) = 0 then
    code!.cached_distance := 0;
    return 0;
  fi;

  d := code!.nqubits;
  for pair in logs do
    d := Minimum( d, PauliWeight( pair.X_bar ) );
    d := Minimum( d, PauliWeight( pair.Z_bar ) );
  od;

  code!.cached_distance := d;
  return d;
end );

#############################################################################
##
##  FiveQubitCode()
##
##  Constructs the optimal [[5, 1, 3]] quantum error-correcting code.
##  Generators:
##    g1 = X Z Z X I
##    g2 = I X Z Z X
##    g3 = X I X Z Z
##    g4 = Z X I X Z
##
InstallGlobalFunction( FiveQubitCode, function()
  local g1, g2, g3, g4;
  g1 := PauliFromString( "+XZZXI" );
  g2 := PauliFromString( "+IXZZX" );
  g3 := PauliFromString( "+XIXZZ" );
  g4 := PauliFromString( "+ZXIXZ" );
  return StabilizerCode( 5, [ g1, g2, g3, g4 ] );
end );

#############################################################################
##
##  ThreeQubitBitFlipCode()
##
InstallGlobalFunction( ThreeQubitBitFlipCode, function()
  local g1, g2;
  g1 := PauliFromString( "+ZZI" );
  g2 := PauliFromString( "+IZZ" );
  return StabilizerCode( 3, [ g1, g2 ] );
end );

#############################################################################
##
##  ThreeQubitPhaseFlipCode()
##
InstallGlobalFunction( ThreeQubitPhaseFlipCode, function()
  local g1, g2;
  g1 := PauliFromString( "+XXI" );
  g2 := PauliFromString( "+IXX" );
  return StabilizerCode( 3, [ g1, g2 ] );
end );

#############################################################################
##
##  PrintStabilizerCode( code )
##
InstallGlobalFunction( PrintStabilizerCode, function( code )
  local n, k, d, i;
  n := code!.nqubits;
  k := code!.k;
  d := ComputeCodeDistance( code );
  Print( "Stabilizer Code [[", n, ", ", k, ", ", d, "]]:\n" );
  Print( "Generators (", Length( code!.generators ), "):\n" );
  for i in [1 .. Length( code!.generators )] do
    Print( "  g", i, ": ", StringFromPauli( code!.generators[i] ), "\n" );
  od;
end );

InstallMethod( ViewString, "for StabilizerCode", [ IsStabilizerCode ],
  function( code )
    return Concatenation( "<StabilizerCode [[", String( code!.nqubits ), ", ", String( code!.k ), "]]>" );
  end );

InstallMethod( PrintObj, "for StabilizerCode", [ IsStabilizerCode ],
  function( code )
    PrintStabilizerCode( code );
  end );
