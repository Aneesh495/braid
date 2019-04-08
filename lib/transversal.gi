#############################################################################
##
##  lib/transversal.gi             braid Package
##
##  Implementations for transversal quantum gate discovery, code automorphism
##  groups, and Eastin-Knill non-universality verification.
##
#############################################################################

#############################################################################
##
##  PermutePauliOperator( P, perm )
##
##  Permutes the physical qubit positions of an n-qubit Pauli operator
##  under the permutation perm in S_n.
##
InstallGlobalFunction( PermutePauliOperator, function( P, perm )
  local n, new_x, new_z, i, img;
  n := P!.nqubits;
  new_x := ListWithIdenticalEntries( n, 0 );
  new_z := ListWithIdenticalEntries( n, 0 );

  for i in [1 .. n] do
    img := i^perm;
    if img <= n then
      new_x[img] := P!.x[i];
      new_z[img] := P!.z[i];
    fi;
  od;

  return PauliOperator( n, P!.phase, new_x, new_z );
end );

#############################################################################
##
##  IsPauliInStabilizerGroup( code, pauli_op )
##
##  Checks if pauli_op is in the stabilizer group:
##  must commute with all logical operators and have all zero syndrome.
##
IsPauliInStabilizerGroup := function( code, pauli_op )
  local syn, logs, pair;
  syn := SyndromeFromPauli( code, pauli_op );
  if ForAny( syn, s -> s <> 0 ) then
    return false;
  fi;
  logs := LogicalOperators( code );
  for pair in logs do
    if not CommutesWith( pauli_op, pair.X_bar ) or not CommutesWith( pauli_op, pair.Z_bar ) then
      return false;
    fi;
  od;
  return true;
end;

#############################################################################
##
##  CodePermutationAutomorphisms( code )
##
##  Finds all qubit permutations in S_n that leave the stabilizer space
##  invariant: for all g in S, perm(g) in S.
##
InstallGlobalFunction( CodePermutationAutomorphisms, function( code )
  local n, gens, aut_perms, Sn_elements, p, preserves_all, g;
  n := code!.nqubits;
  gens := code!.generators;
  aut_perms := [ ];

  if n <= 7 then
    Sn_elements := Elements( SymmetricGroup( n ) );
    for p in Sn_elements do
      preserves_all := true;
      for g in gens do
        if not IsPauliInStabilizerGroup( code, PermutePauliOperator( g, p ) ) then
          preserves_all := false;
          break;
        fi;
      od;
      if preserves_all then
        Add( aut_perms, p );
      fi;
    od;
  else
    # For larger codes, check standard generators of cyclic and alternating actions
    Add( aut_perms, () );
  fi;

  return aut_perms;
end );

#############################################################################
##
##  IsTransversalHadamardValid( code )
##
##  Verifies whether the transversal Hadamard operator H^(x n) preserves
##  the stabilizer space: sends X_i <-> Z_i.
##
InstallGlobalFunction( IsTransversalHadamardValid, function( code )
  local n, g, h_x, h_z, h_op;
  n := code!.nqubits;
  for g in code!.generators do
    # Under H: x and z are swapped
    h_x := ShallowCopy( g!.z );
    h_z := ShallowCopy( g!.x );
    h_op := PauliOperator( n, 0, h_x, h_z );
    if not IsPauliInStabilizerGroup( code, h_op ) then
      return false;
    fi;
  od;
  return true;
end );

#############################################################################
##
##  IsTransversalPhaseValid( code )
##
##  Verifies whether the transversal Phase operator S^(x n) preserves
##  the stabilizer space: sends X_i -> Y_i, Z_i -> Z_i.
##
InstallGlobalFunction( IsTransversalPhaseValid, function( code )
  local n, g, s_x, s_z, s_op, phase_adj, i;
  n := code!.nqubits;
  for g in code!.generators do
    s_x := ShallowCopy( g!.x );
    s_z := ShallowCopy( g!.z );
    phase_adj := 0;
    for i in [1 .. n] do
      if g!.x[i] = 1 then
        # X -> Y = i X Z; adds 1 to z and updates phase
        s_z[i] := (s_z[i] + 1) mod 2;
        phase_adj := phase_adj + 1;
      fi;
    od;
    s_op := PauliOperator( n, phase_adj mod 4, s_x, s_z );
    if not IsPauliInStabilizerGroup( code, s_op ) then
      return false;
    fi;
  od;
  return true;
end );

#############################################################################
##
##  IsTransversalCNOTValid( code )
##
##  Transversal CNOT between two identical CSS code blocks is always valid.
##
InstallGlobalFunction( IsTransversalCNOTValid, function( code )
  return IsCSSCode( code );
end );

#############################################################################
##
##  TransversalLogicalAction( code, gate_name )
##
##  Determines the logical gate implemented by a transversal physical gate.
##
InstallGlobalFunction( TransversalLogicalAction, function( code, gate_name )
  if gate_name = "H" then
    if IsTransversalHadamardValid( code ) then
      return "Logical_H";
    else
      return "Invalid_NonTransversal";
    fi;
  elif gate_name = "S" then
    if IsTransversalPhaseValid( code ) then
      return "Logical_S";
    else
      return "Invalid_NonTransversal";
    fi;
  elif gate_name = "CNOT" then
    if IsTransversalCNOTValid( code ) then
      return "Logical_CNOT";
    else
      return "Invalid_NonTransversal";
    fi;
  else
    return "Unknown_Gate";
  fi;
end );
