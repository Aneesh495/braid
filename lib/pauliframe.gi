#############################################################################
##
##  lib/pauliframe.gi             braid Package
##
##  Implementations for classical Pauli Frame tracking.
##  Allows virtual Clifford gate evolution and zero-physical-overhead correction
##  of Pauli errors in quantum fault tolerance.
##
#############################################################################

#############################################################################
##
##  PauliFrame( nqubits )
##
InstallGlobalFunction( PauliFrame, function( nqubits )
  return rec(
    nqubits := nqubits,
    x := ListWithIdenticalEntries( nqubits, 0 ),
    z := ListWithIdenticalEntries( nqubits, 0 )
  );
end );

#############################################################################
##
##  PauliFrameApplyPauli( frame, qubit, pauli_char )
##
InstallGlobalFunction( PauliFrameApplyPauli, function( frame, qubit, pauli_char )
  if pauli_char = "X" or pauli_char = 'X' then
    frame!.x[qubit] := (frame!.x[qubit] + 1) mod 2;
  elif pauli_char = "Z" or pauli_char = 'Z' then
    frame!.z[qubit] := (frame!.z[qubit] + 1) mod 2;
  elif pauli_char = "Y" or pauli_char = 'Y' then
    frame!.x[qubit] := (frame!.x[qubit] + 1) mod 2;
    frame!.z[qubit] := (frame!.z[qubit] + 1) mod 2;
  elif pauli_char = "I" or pauli_char = 'I' then
    # Identity: no-op
  else
    Error( "PauliFrameApplyPauli: unknown Pauli character ", pauli_char );
  fi;
  return frame;
end );

#############################################################################
##
##  PauliFrameApplyH( frame, qubit )
##
##  Conjugation by Hadamard: H X H^dag = Z, H Z H^dag = X, H Y H^dag = -Y.
##
InstallGlobalFunction( PauliFrameApplyH, function( frame, qubit )
  local tmp;
  tmp := frame!.x[qubit];
  frame!.x[qubit] := frame!.z[qubit];
  frame!.z[qubit] := tmp;
  return frame;
end );

#############################################################################
##
##  PauliFrameApplyS( frame, qubit )
##
##  Conjugation by Phase gate: S X S^dag = Y, S Z S^dag = Z.
##
InstallGlobalFunction( PauliFrameApplyS, function( frame, qubit )
  frame!.z[qubit] := (frame!.z[qubit] + frame!.x[qubit]) mod 2;
  return frame;
end );

#############################################################################
##
##  PauliFrameApplyCNOT( frame, ctrl, target )
##
##  Conjugation by CNOT:
##  X_c -> X_c X_t, X_t -> X_t
##  Z_c -> Z_c,     Z_t -> Z_c Z_t
##
InstallGlobalFunction( PauliFrameApplyCNOT, function( frame, ctrl, target )
  frame!.x[target] := (frame!.x[target] + frame!.x[ctrl]) mod 2;
  frame!.z[ctrl] := (frame!.z[ctrl] + frame!.z[target]) mod 2;
  return frame;
end );

#############################################################################
##
##  PauliFrameCorrectMeasurement( frame, qubit, raw_outcome )
##
##  Z-basis measurement is inverted if Pauli frame contains X or Y on qubit.
##
InstallGlobalFunction( PauliFrameCorrectMeasurement, function( frame, qubit, raw_outcome )
  return (raw_outcome + frame!.x[qubit]) mod 2;
end );

#############################################################################
##
##  PauliFrameToPauliOperator( frame )
##
InstallGlobalFunction( PauliFrameToPauliOperator, function( frame )
  return PauliOperator( frame!.nqubits, 0, frame!.x, frame!.z );
end );

#############################################################################
##
##  PauliFrameReset( frame )
##
InstallGlobalFunction( PauliFrameReset, function( frame )
  frame!.x := ListWithIdenticalEntries( frame!.nqubits, 0 );
  frame!.z := ListWithIdenticalEntries( frame!.nqubits, 0 );
  return frame;
end );

#############################################################################
##
##  PauliFrameWeight( frame )
##
InstallGlobalFunction( PauliFrameWeight, function( frame )
  local wt, q;
  wt := 0;
  for q in [1 .. frame!.nqubits] do
    if frame!.x[q] = 1 or frame!.z[q] = 1 then
      wt := wt + 1;
    fi;
  od;
  return wt;
end );
