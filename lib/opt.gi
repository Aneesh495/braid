#############################################################################
##
##  lib/opt.gi                    braid Package
##
##  Implementations for phase polynomial optimization of Clifford+T circuits.
##  Merges non-Clifford T rotations modulo 2*pi, reduces T-count, and synthesizes
##  parity networks.
##
#############################################################################

#############################################################################
##
##  PhasePolynomialCircuit( nqubits )
##
InstallGlobalFunction( PhasePolynomialCircuit, function( nqubits )
  local wire_parities, i;

  wire_parities := List( [1 .. nqubits], i -> ListWithIdenticalEntries( nqubits, 0 ) );
  for i in [1 .. nqubits] do
    wire_parities[i][i] := 1;
  od;

  return rec(
    nqubits := nqubits,
    wire_parities := wire_parities,
    terms := [ ],
    optimized_terms := [ ]
  );
end );

#############################################################################
##
##  PhasePolyAddCNOT( circ, ctrl, target )
##
InstallGlobalFunction( PhasePolyAddCNOT, function( circ, ctrl, target )
  local n, j;
  n := circ!.nqubits;
  circ!.wire_parities[target] := List( [1 .. n], j -> (circ!.wire_parities[target][j] + circ!.wire_parities[ctrl][j]) mod 2 );
  return circ;
end );

#############################################################################
##
##  PhasePolyAddPhase( circ, qubit, angle_mult )
##
##  Adds a phase rotation of angle_mult * pi / 4 to the current parity on qubit.
##  angle_mult = 1 (T), 2 (S), 3 (TS), 4 (Z), 7 (T^dag).
##
InstallGlobalFunction( PhasePolyAddPhase, function( circ, qubit, angle_mult )
  local par, a;
  a := angle_mult mod 8;
  if a <> 0 then
    par := ShallowCopy( circ!.wire_parities[qubit] );
    Add( circ!.terms, rec( parity := par, angle := a ) );
  fi;
  return circ;
end );

#############################################################################
##
##  PhasePolyTerms( circ )
##
InstallGlobalFunction( PhasePolyTerms, function( circ )
  if IsBound( circ!.is_optimized ) and circ!.is_optimized then
    return circ!.optimized_terms;
  fi;
  return circ!.terms;
end );

#############################################################################
##
##  PhasePolyOptimize( circ )
##
##  Aggregates terms on identical linear parities mod 8.
##  T(a) * T(a) reduces to S(a), T(a) * T^dag(a) reduces to I.
##
InstallGlobalFunction( PhasePolyOptimize, function( circ )
  local map_keys, map_vals, t, idx, i, merged, net_angle;

  map_keys := [ ];
  map_vals := [ ];

  for t in circ!.terms do
    idx := Position( map_keys, t.parity );
    if idx = fail then
      Add( map_keys, t.parity );
      Add( map_vals, t.angle );
    else
      map_vals[idx] := (map_vals[idx] + t.angle) mod 8;
    fi;
  od;

  merged := [ ];
  for i in [1 .. Length( map_keys )] do
    net_angle := map_vals[i];
    if net_angle <> 0 then
      Add( merged, rec( parity := map_keys[i], angle := net_angle ) );
    fi;
  od;

  circ!.optimized_terms := merged;
  circ!.is_optimized := true;
  return circ;
end );

#############################################################################
##
##  PhasePolyTCount( circ )
##
##  Returns the number of non-Clifford T gates in the circuit.
##  Angles 1, 3, 5, 7 require T gates; 2, 4, 6 are Clifford (S, Z, S^dag).
##
InstallGlobalFunction( PhasePolyTCount, function( circ )
  local terms, count, t;
  terms := PhasePolyTerms( circ );
  count := 0;
  for t in terms do
    if (t.angle mod 2) <> 0 then
      count := count + 1;
    fi;
  od;
  return count;
end );

#############################################################################
##
##  PhasePolySynthesize( circ )
##
##  Synthesizes the optimized phase polynomial into a discrete sequence of
##  CNOT, T, S, and Z gates.
##
InstallGlobalFunction( PhasePolySynthesize, function( circ )
  local terms, gates, t, active_qubits, lead_qubit, other_qubits, q;

  terms := PhasePolyTerms( circ );
  gates := [ ];

  for t in terms do
    active_qubits := [ ];
    for q in [1 .. circ!.nqubits] do
      if t.parity[q] = 1 then
        Add( active_qubits, q );
      fi;
    od;

    if Length( active_qubits ) > 0 then
      lead_qubit := active_qubits[1];
      other_qubits := active_qubits{[2 .. Length( active_qubits )]};

      # Compute parity onto lead_qubit
      for q in other_qubits do
        Add( gates, rec( gate := "CNOT", ctrl := q, target := lead_qubit ) );
      od;

      # Apply single-qubit phase rotation
      if t.angle = 1 then
        Add( gates, rec( gate := "T", qubit := lead_qubit ) );
      elif t.angle = 2 then
        Add( gates, rec( gate := "S", qubit := lead_qubit ) );
      elif t.angle = 4 then
        Add( gates, rec( gate := "Z", qubit := lead_qubit ) );
      elif t.angle = 7 then
        Add( gates, rec( gate := "Tdg", qubit := lead_qubit ) );
      else
        Add( gates, rec( gate := "Rz", angle_mult := t.angle, qubit := lead_qubit ) );
      fi;

      # Uncompute parity
      for q in Reversed( other_qubits ) do
        Add( gates, rec( gate := "CNOT", ctrl := q, target := lead_qubit ) );
      od;
    fi;
  od;

  return gates;
end );
