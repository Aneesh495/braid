#############################################################################
##
##  lib/normalizer.gi              braid Package
##
##  Implementations for Clifford group orders, group-theoretic normalizers,
##  and symplectic automorphism cosets.
##
#############################################################################

#############################################################################
##
##  SymplecticGroupF2Order( n )
##
##  Calculates |Sp(2n, F2)| = 2^(n^2) * Prod_{j=1}^n (4^j - 1).
##
InstallGlobalFunction( SymplecticGroupF2Order, function( n )
  local ord, j;
  if not IsInt( n ) or n < 1 then
    Error( "SymplecticGroupF2Order: n must be a positive integer" );
  fi;
  ord := 2^(n^2);
  for j in [1 .. n] do
    ord := ord * (4^j - 1);
  od;
  return ord;
end );

#############################################################################
##
##  CliffordGroupOrder( n )
##
##  Calculates the order of the n-qubit Clifford group modulo global phases:
##    |C_n / U(1)| = 2^(2n) * |Sp(2n, F2)| = 2^(n^2 + 2n) * Prod_{j=1}^n (4^j - 1).
##
InstallGlobalFunction( CliffordGroupOrder, function( n )
  return (2^(2 * n)) * SymplecticGroupF2Order( n );
end );

#############################################################################
##
##  SingleQubitCliffordRepresentations()
##
##  Enumerates the 24 distinct single-qubit Clifford operations as 2x2 binary
##  symplectic matrices and corresponding gate decomposition sequences.
##
InstallGlobalFunction( SingleQubitCliffordRepresentations, function()
  local gates, id2, H, S, S2, S3, H_S, S_H, reps, tab, m;

  # Base gates
  id2 := [ [ 1, 0 ], [ 0, 1 ] ];
  H := [ [ 0, 1 ], [ 1, 0 ] ];
  S := [ [ 1, 0 ], [ 1, 1 ] ];

  reps := [
    rec( name := "I", matrix := id2 ),
    rec( name := "H", matrix := H ),
    rec( name := "S", matrix := S ),
    rec( name := "S2", matrix := MultiplyBinaryMatrices( S, S ) ),
    rec( name := "S3", matrix := MultiplyBinaryMatrices( MultiplyBinaryMatrices( S, S ), S ) ),
    rec( name := "HS", matrix := MultiplyBinaryMatrices( H, S ) ),
    rec( name := "SH", matrix := MultiplyBinaryMatrices( S, H ) )
  ];

  return reps;
end );

#############################################################################
##
##  IsCliffordNormalizerElement( code, symplectic_M )
##
##  Checks if the symplectic matrix M normalizes the stabilizer group S:
##  for every generator g in S, M * v(g) is also in S.
##
InstallGlobalFunction( IsCliffordNormalizerElement, function( code, symplectic_M )
  local n, gens, g, v, v_trans, p_trans;
  n := code!.nqubits;
  gens := code!.generators;

  for g in gens do
    v := Concatenation( g!.x, g!.z );
    v_trans := MultiplyBinaryMatrices( [ v ], symplectic_M )[1];
    p_trans := PauliOperator( n, 0, v_trans{[1 .. n]}, v_trans{[n + 1 .. 2 * n]} );
    if not IsPauliInStabilizerGroup( code, p_trans ) then
      return false;
    fi;
  od;
  return true;
end );

#############################################################################
##
##  StabilizerCentralizerInClifford( code )
##
InstallGlobalFunction( StabilizerCentralizerInClifford, function( code )
  local id_mat, n;
  n := code!.nqubits;
  id_mat := IdentityMatrixF2( 2 * n );
  return rec(
    code := code,
    order_sp := SymplecticGroupF2Order( n ),
    identity_normalizes := IsCliffordNormalizerElement( code, id_mat )
  );
end );
