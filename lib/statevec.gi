#############################################################################
##
##  lib/statevec.gi               braid Package
##
##  Implementations for stabilizer state bipartite entanglement entropy
##  and explicit statevector projection.
##
#############################################################################

#############################################################################
##
##  StabilizerEntanglementEntropy( code_or_gens, subsystem_A )
##
##  Computes exact bipartite von Neumann entanglement entropy S(A) across cut A|B
##  using the Fattal-Cubitt-Yamamoto-Gottesman theorem:
##  S(A) = |A| - dim(S_A), where S_A is the subgroup supported purely on A.
##
InstallGlobalFunction( StabilizerEntanglementEntropy, function( code_or_gens, subsystem_A )
  local gens, n, m, b_qubits, mb, g, row_b, rk, dim_sa;

  if IsRecord( code_or_gens ) and IsBound( code_or_gens!.generators ) then
    gens := code_or_gens!.generators;
    n := code_or_gens!.nqubits;
  elif IsList( code_or_gens ) and Length( code_or_gens ) > 0 then
    gens := code_or_gens;
    n := gens[1]!.nqubits;
  else
    Error( "StabilizerEntanglementEntropy: invalid stabilizer input" );
  fi;

  m := Length( gens );
  b_qubits := Difference( [1 .. n], subsystem_A );

  if Length( b_qubits ) = 0 then
    return 0;
  fi;

  # Build restricted check matrix on subsystem B: rows are [ x_B | z_B ]
  mb := [ ];
  for g in gens do
    row_b := Concatenation( g!.x{b_qubits}, g!.z{b_qubits} );
    Add( mb, row_b );
  od;

  # Compute rank over GF(2)
  rk := RankMat( mb * One( GF(2) ) );

  # dim(S_A) = m - rank(M_B)
  dim_sa := m - rk;

  return Length( subsystem_A ) - dim_sa;
end );

#############################################################################
##
##  StabilizerStatevector( gens, nqubits )
##
##  Constructs the explicit normalized 2^n complex statevector for n <= 6
##  by applying stabilizer projectors (I + g) / 2 to |0...0>.
##
InstallGlobalFunction( StabilizerStatevector, function( gens, nqubits )
  local dim, psi, g, new_psi, idx, k, bit_val, phase_mult, target_idx,
        q, norm_sq;

  if nqubits > 6 then
    Error( "StabilizerStatevector: exact statevector reconstruction limited to n <= 6" );
  fi;

  dim := 2^nqubits;
  psi := ListWithIdenticalEntries( dim, 0 );
  psi[1] := 1; # |0...0>

  # Project with each generator: psi <- (I + g) psi
  for g in gens do
    new_psi := ShallowCopy( psi );
    for idx in [1 .. dim] do
      k := idx - 1; # 0-indexed basis state
      phase_mult := 1;
      target_idx := k;

      for q in [1 .. nqubits] do
        bit_val := QuoInt( k, 2^(nqubits - q) ) mod 2;

        if g!.z[q] = 1 and bit_val = 1 then
          phase_mult := -phase_mult;
        fi;

        if g!.x[q] = 1 then
          # Flip bit q in target
          if bit_val = 1 then
            target_idx := target_idx - 2^(nqubits - q);
          else
            target_idx := target_idx + 2^(nqubits - q);
          fi;
        fi;
      od;

      new_psi[target_idx + 1] := new_psi[target_idx + 1] + phase_mult * psi[idx];
    od;
    psi := new_psi;
  od;

  # Normalize
  norm_sq := Sum( psi, x -> x * x );
  if norm_sq = 0 then
    Error( "StabilizerStatevector: projection annihilated statevector" );
  fi;

  return List( psi, x -> x / Sqrt( Float( norm_sq ) ) );
end );

#############################################################################
##
##  StatevectorInnerProduct( vec1, vec2 )
##
InstallGlobalFunction( StatevectorInnerProduct, function( vec1, vec2 )
  return Sum( [1 .. Length( vec1 )], i -> vec1[i] * vec2[i] );
end );

#############################################################################
##
##  StatevectorFidelity( vec1, vec2 )
##
InstallGlobalFunction( StatevectorFidelity, function( vec1, vec2 )
  local dot;
  dot := StatevectorInnerProduct( vec1, vec2 );
  return dot * dot;
end );
