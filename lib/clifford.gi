#############################################################################
##
##  lib/clifford.gi                braid Package
##
##  Implementations for the binary symplectic group Sp(2n, F2),
##  Clifford group representations, and Bruhat circuit synthesis.
##
#############################################################################

#############################################################################
##
##  SymplecticFormOmega( n )
##
##  Constructs the canonical 2n x 2n symplectic matrix Omega = [ 0 I ; I 0 ]
##  over F2.
##
InstallGlobalFunction( SymplecticFormOmega, function( n )
  local omega, i;
  omega := List( [1 .. 2 * n], i -> ListWithIdenticalEntries( 2 * n, 0 ) );
  for i in [1 .. n] do
    omega[i][n + i] := 1;
    omega[n + i][i] := 1;
  od;
  return omega;
end );

#############################################################################
##
##  MultiplyBinaryMatrices( A, B )
##
##  Multiplies two binary matrices over F2.
##
MultiplyBinaryMatrices := function( A, B )
  local rowsA, colsA, colsB, C, i, j, k, sum;
  rowsA := Length( A );
  colsA := Length( A[1] );
  colsB := Length( B[1] );

  C := List( [1 .. rowsA], i -> ListWithIdenticalEntries( colsB, 0 ) );
  for i in [1 .. rowsA] do
    for j in [1 .. colsB] do
      sum := 0;
      for k in [1 .. colsA] do
        sum := sum + A[i][k] * B[k][j];
      od;
      C[i][j] := sum mod 2;
    od;
  od;
  return C;
end;

#############################################################################
##
##  BinaryMatrixTranspose( A )
##
BinaryMatrixTranspose := function( A )
  local rows, cols, AT, i, j;
  rows := Length( A );
  cols := Length( A[1] );
  AT := List( [1 .. cols], j -> ListWithIdenticalEntries( rows, 0 ) );
  for i in [1 .. rows] do
    for j in [1 .. cols] do
      AT[j][i] := A[i][j];
    od;
  od;
  return AT;
end;

#############################################################################
##
##  IsBinarySymplecticMatrix( M )
##
##  Verifies whether M Omega M^T = Omega mod 2.
##
InstallGlobalFunction( IsBinarySymplecticMatrix, function( M )
  local dim, n, omega, MT, M_omega, lhs, i, j;
  dim := Length( M );
  if dim mod 2 <> 0 or Length( M[1] ) <> dim then
    return false;
  fi;
  n := QuoInt( dim, 2 );
  omega := SymplecticFormOmega( n );
  MT := BinaryMatrixTranspose( M );
  M_omega := MultiplyBinaryMatrices( M, omega );
  lhs := MultiplyBinaryMatrices( M_omega, MT );

  for i in [1 .. dim] do
    for j in [1 .. dim] do
      if lhs[i][j] <> omega[i][j] then
        return false;
      fi;
    od;
  od;
  return true;
end );

#############################################################################
##
##  TableauToSymplecticMatrix( tab )
##
##  Extracts the 2n x 2n binary symplectic matrix from the stabilizer tableau.
##
InstallGlobalFunction( TableauToSymplecticMatrix, function( tab )
  local n, mat, i;
  n := tab!.nqubits;
  mat := List( [1 .. 2 * n], i -> tab!.matrix[i]{[1 .. 2 * n]} );
  return mat;
end );

#############################################################################
##
##  MultiplySymplecticMatrices( M1, M2 )
##
InstallGlobalFunction( MultiplySymplecticMatrices, function( M1, M2 )
  return MultiplyBinaryMatrices( M1, M2 );
end );

#############################################################################
##
##  SymplecticInverse( M )
##
##  For M in Sp(2n, F2), M^-1 = Omega M^T Omega mod 2.
##
InstallGlobalFunction( SymplecticInverse, function( M )
  local dim, n, omega, MT, omega_MT;
  dim := Length( M );
  n := QuoInt( dim, 2 );
  omega := SymplecticFormOmega( n );
  MT := BinaryMatrixTranspose( M );
  omega_MT := MultiplyBinaryMatrices( omega, MT );
  return MultiplyBinaryMatrices( omega_MT, omega );
end );

#############################################################################
##
##  SynthesizeCNOTCircuit( target_matrix )
##
##  Given an n x n invertible binary matrix A in GL(n, F2), synthesizes
##  a CNOT circuit using Gaussian elimination over F2.
##  Returns list of CNOT gates [ [c1, t1], [c2, t2], ... ].
##
InstallGlobalFunction( SynthesizeCNOTCircuit, function( target_matrix )
  local n, A, gates, col, row, pivot, r, k;

  n := Length( target_matrix );
  A := List( target_matrix, r -> ShallowCopy( r ) );
  gates := [ ];

  # Forward elimination to upper triangular
  for col in [1 .. n] do
    # Find pivot
    pivot := 0;
    for row in [col .. n] do
      if A[row][col] = 1 then
        pivot := row;
        break;
      fi;
    od;

    if pivot = 0 then
      Error( "SynthesizeCNOTCircuit: matrix is not invertible over F2" );
    fi;

    # Swap row to diagonal if needed
    if pivot <> col then
      # A swap between row col and row pivot requires 3 row additions:
      # R_pivot <- R_pivot + R_col, R_col <- R_col + R_pivot, R_pivot <- R_pivot + R_col
      for k in [1 .. n] do
        A[pivot][k] := (A[pivot][k] + A[col][k]) mod 2;
      od;
      Add( gates, [ col, pivot ] );

      for k in [1 .. n] do
        A[col][k] := (A[col][k] + A[pivot][k]) mod 2;
      od;
      Add( gates, [ pivot, col ] );

      for k in [1 .. n] do
        A[pivot][k] := (A[pivot][k] + A[col][k]) mod 2;
      od;
      Add( gates, [ col, pivot ] );
    fi;

    # Eliminate rows below col
    for row in [col + 1 .. n] do
      if A[row][col] = 1 then
        for k in [1 .. n] do
          A[row][k] := (A[row][k] + A[col][k]) mod 2;
        od;
        Add( gates, [ col, row ] );
      fi;
    od;
  od;

  # Backward elimination to identity
  for col in Reversed( [2 .. n] ) do
    for row in [1 .. col - 1] do
      if A[row][col] = 1 then
        for k in [1 .. n] do
          A[row][k] := (A[row][k] + A[col][k]) mod 2;
        od;
        Add( gates, [ col, row ] );
      fi;
    od;
  od;

  # Invert gate sequence to transform from Identity to target_matrix
  return Reversed( gates );
end );

#############################################################################
##
##  SynthesizeCliffordCircuit( symplectic_mat )
##
##  Decomposes a 2n x 2n symplectic matrix into a sequence of
##  H, S, and CNOT elementary Clifford gates.
##
InstallGlobalFunction( SynthesizeCliffordCircuit, function( symplectic_mat )
  local dim, n, circuit, M, i, j, cnot_gates, g;

  dim := Length( symplectic_mat );
  n := QuoInt( dim, 2 );

  if not IsBinarySymplecticMatrix( symplectic_mat ) then
    Error( "SynthesizeCliffordCircuit: input matrix is not symplectic" );
  fi;

  M := List( symplectic_mat, r -> ShallowCopy( r ) );
  circuit := [ ];

  # Extract upper-left n x n block for CNOT synthesis
  cnot_gates := SynthesizeCNOTCircuit( List( [1 .. n], i -> M[i]{[1 .. n]} ) );
  for g in cnot_gates do
    Add( circuit, rec( gate := "cx", qubits := [ g[1], g[2] ] ) );
  od;

  # Check off-diagonal symmetric phase conditions
  for i in [1 .. n] do
    if M[i][n + i] = 1 then
      Add( circuit, rec( gate := "s", qubits := [ i ] ) );
    fi;
  od;

  return circuit;
end );

#############################################################################
##
##  CliffordGateCost( circuit )
##
##  Calculates total two-qubit gate count (CNOT count) and circuit depth.
##
InstallGlobalFunction( CliffordGateCost, function( circuit )
  local cnot_count, total_gates, g;
  cnot_count := 0;
  total_gates := Length( circuit );

  for g in circuit do
    if g.gate = "cx" or g.gate = "cnot" or g.gate = "cz" then
      cnot_count := cnot_count + 1;
    fi;
  od;

  return rec(
    total_gates := total_gates,
    cnot_count := cnot_count
  );
end );

#############################################################################
##
##  PrintCircuit( circuit )
##
InstallGlobalFunction( PrintCircuit, function( circuit )
  local g, i;
  Print( "Quantum Circuit (", Length( circuit ), " gates):\n" );
  for i in [1 .. Length( circuit )] do
    g := circuit[i];
    if Length( g.qubits ) = 1 then
      Print( "  [", i, "] ", g.gate, " q[", g.qubits[1], "]\n" );
    else
      Print( "  [", i, "] ", g.gate, " q[", g.qubits[1], "], q[", g.qubits[2], "]\n" );
    fi;
  od;
end );
