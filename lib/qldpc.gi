#############################################################################
##
##  lib/qldpc.gi                   braid Package
##
##  Implementations for Group-Algebra Quantum LDPC (QLDPC) codes:
##  Generalized Bicycle codes, Hypergraph Products, and Lifted Products.
##
#############################################################################

#############################################################################
##
##  CirculantMatrix( shifts, m )
##
##  Constructs an m x m circulant binary matrix from a list of column shifts.
##
InstallGlobalFunction( CirculantMatrix, function( shifts, m )
  local mat, r, s, col;
  mat := List( [1 .. m], r -> ListWithIdenticalEntries( m, 0 ) );
  for r in [1 .. m] do
    for s in shifts do
      col := ((r - 1 + s) mod m) + 1;
      mat[r][col] := 1;
    od;
  od;
  return mat;
end );

#############################################################################
##
##  KroneckerProductF2( A, B )
##
KroneckerProductF2 := function( A, B )
  local ra, ca, rb, cb, K, r, c, i, j;
  ra := Length( A ); ca := Length( A[1] );
  rb := Length( B ); cb := Length( B[1] );

  K := List( [1 .. ra * rb], r -> ListWithIdenticalEntries( ca * cb, 0 ) );
  for r in [1 .. ra] do
    for c in [1 .. ca] do
      if A[r][c] = 1 then
        for i in [1 .. rb] do
          for j in [1 .. cb] do
            K[(r - 1) * rb + i][(c - 1) * cb + j] := B[i][j];
          od;
        od;
      fi;
    od;
  od;
  return K;
end;

#############################################################################
##
##  IdentityMatrixF2( n )
##
IdentityMatrixF2 := function( n )
  local I, i;
  I := List( [1 .. n], i -> ListWithIdenticalEntries( n, 0 ) );
  for i in [1 .. n] do
    I[i][i] := 1;
  od;
  return I;
end;

#############################################################################
##
##  HorizontalBlockConcat( A, B )
##
HorizontalBlockConcat := function( A, B )
  local r, rows;
  rows := Length( A );
  if Length( B ) <> rows then
    Error( "HorizontalBlockConcat: row counts do not match" );
  fi;
  return List( [1 .. rows], r -> Concatenation( A[r], B[r] ) );
end;

#############################################################################
##
##  GeneralizedBicycleCode( a_shifts, b_shifts, m )
##
##  Constructs a [[2m, k, d]] Generalized Bicycle (GB) code from two
##  circulant matrices A and B:
##    H_X = [ A | B ]
##    H_Z = [ B^T | A^T ]
##  Commutativity H_X * H_Z^T = A B + B A = 0 mod 2 is guaranteed because
##  circulant matrices commute.
##
InstallGlobalFunction( GeneralizedBicycleCode, function( a_shifts, b_shifts, m )
  local A, B, AT, BT, HX, HZ, code;

  A := CirculantMatrix( a_shifts, m );
  B := CirculantMatrix( b_shifts, m );

  AT := BinaryMatrixTranspose( A );
  BT := BinaryMatrixTranspose( B );

  HX := HorizontalBlockConcat( A, B );
  HZ := HorizontalBlockConcat( BT, AT );

  code := CSSCode( HX, HZ );
  code!.is_qldpc := true;
  code!.m := m;
  return code;
end );

#############################################################################
##
##  HypergraphProductCode( H1, H2 )
##
##  Constructs a [[n1*n2 + m1*m2, k1*k2, min(d1, d2)]] Hypergraph Product
##  (HP) code from classical linear codes with check matrices H1 and H2:
##    H_X = [ H1 (x) I_n2  |  I_m1 (x) H2^T ]
##    H_Z = [ I_n1 (x) H2  |  H1^T (x) I_m2 ]
##
InstallGlobalFunction( HypergraphProductCode, function( H1, H2 )
  local m1, n1, m2, n2, In1, In2, Im1, Im2, H1T, H2T, HX_left, HX_right, HZ_left, HZ_right, HX, HZ, code;

  m1 := Length( H1 ); n1 := Length( H1[1] );
  m2 := Length( H2 ); n2 := Length( H2[1] );

  In1 := IdentityMatrixF2( n1 );
  In2 := IdentityMatrixF2( n2 );
  Im1 := IdentityMatrixF2( m1 );
  Im2 := IdentityMatrixF2( m2 );

  H1T := BinaryMatrixTranspose( H1 );
  H2T := BinaryMatrixTranspose( H2 );

  HX_left := KroneckerProductF2( H1, In2 );
  HX_right := KroneckerProductF2( Im1, H2T );
  HX := HorizontalBlockConcat( HX_left, HX_right );

  HZ_left := KroneckerProductF2( In1, H2 );
  HZ_right := KroneckerProductF2( H1T, Im2 );
  HZ := HorizontalBlockConcat( HZ_left, HZ_right );

  code := CSSCode( HX, HZ );
  code!.is_qldpc := true;
  return code;
end );

#############################################################################
##
##  QLDPCMatrixSparsity( code )
##
##  Computes maximum and average row/column weights across H_X and H_Z checks.
##
InstallGlobalFunction( QLDPCMatrixSparsity, function( code )
  local n, check_mat, row_weights, col_weights, r, c, w;
  n := code!.nqubits;
  check_mat := code!.check_matrix;

  row_weights := List( check_mat, r -> Sum( r ) );
  col_weights := List( [1 .. 2 * n], c -> Sum( List( check_mat, r -> r[c] ) ) );

  return rec(
    max_row_weight := Maximum( row_weights ),
    avg_row_weight := Float( Sum( row_weights ) ) / Float( Length( row_weights ) ),
    max_col_weight := Maximum( col_weights ),
    avg_col_weight := Float( Sum( col_weights ) ) / Float( Length( col_weights ) )
  );
end );

#############################################################################
##
##  PrintQLDPCProfile( code )
##
InstallGlobalFunction( PrintQLDPCProfile, function( code )
  local sp;
  sp := QLDPCMatrixSparsity( code );
  Print( "Quantum LDPC Code Profile [[", code!.nqubits, ", ", code!.k, "]]:\n" );
  Print( "  Max Check Weight (Row):   ", sp.max_row_weight, "\n" );
  Print( "  Avg Check Weight (Row):   ", sp.avg_row_weight, "\n" );
  Print( "  Max Variable Weight (Col): ", sp.max_col_weight, "\n" );
  Print( "  Avg Variable Weight (Col): ", sp.avg_col_weight, "\n" );
end );
