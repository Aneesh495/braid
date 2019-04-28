#############################################################################
##
##  lib/noise.gi                   braid Package
##
##  Implementations for quantum noise channels: depolarizing, bit-flip,
##  phase-flip, and phenomenological measurement error models.
##
#############################################################################

#############################################################################
##
##  SampleBernoulli( prob_float )
##
##  Samples a Bernoulli random variable with parameter prob_float in [0, 1].
##
SampleBernoulli := function( prob_float )
  local scale, threshold, roll;
  if prob_float <= 0.0 then
    return 0;
  fi;
  if prob_float >= 1.0 then
    return 1;
  fi;
  scale := 1000000;
  threshold := Int( Float( prob_float ) * Float( scale ) );
  roll := Random( [1 .. scale] );
  if roll <= threshold then
    return 1;
  else
    return 0;
  fi;
end;

#############################################################################
##
##  GenerateDepolarizingError( nqubits, p_error )
##
##  Generates a random multi-qubit Pauli error according to the depolarizing
##  channel: on each qubit, I with prob 1 - p, and X, Y, Z each with prob p/3.
##
InstallGlobalFunction( GenerateDepolarizingError, function( nqubits, p_error )
  local x_vec, z_vec, p_sub, i, roll, scale, t1, t2, t3;

  x_vec := ListWithIdenticalEntries( nqubits, 0 );
  z_vec := ListWithIdenticalEntries( nqubits, 0 );

  if p_error <= 0.0 then
    return PauliOperator( nqubits, 0, x_vec, z_vec );
  fi;

  scale := 3000000;
  p_sub := Float( p_error ) / 3.0;
  t1 := Int( p_sub * Float( scale ) );
  t2 := 2 * t1;
  t3 := 3 * t1;

  for i in [1 .. nqubits] do
    roll := Random( [1 .. scale] );
    if roll <= t1 then
      x_vec[i] := 1; # Pauli X
    elif roll <= t2 then
      x_vec[i] := 1; z_vec[i] := 1; # Pauli Y
    elif roll <= t3 then
      z_vec[i] := 1; # Pauli Z
    fi;
  od;

  return PauliOperator( nqubits, 0, x_vec, z_vec );
end );

#############################################################################
##
##  GenerateIndependentXZError( nqubits, px, pz )
##
##  Generates independent bit-flip (X) and phase-flip (Z) errors.
##
InstallGlobalFunction( GenerateIndependentXZError, function( nqubits, px, pz )
  local x_vec, z_vec, i;
  x_vec := List( [1 .. nqubits], i -> SampleBernoulli( px ) );
  z_vec := List( [1 .. nqubits], i -> SampleBernoulli( pz ) );
  return PauliOperator( nqubits, 0, x_vec, z_vec );
end );

#############################################################################
##
##  InjectPhenomenologicalNoise( code, p_physical )
##
##  Injects depolarizing noise on the physical qubits of code and extracts
##  the resulting syndrome vector.
##
InstallGlobalFunction( InjectPhenomenologicalNoise, function( code, p_physical )
  local n, err, syn;
  n := code!.nqubits;
  err := GenerateDepolarizingError( n, p_physical );
  syn := SyndromeFromPauli( code, err );

  return rec(
    error := err,
    syndrome := syn
  );
end );

#############################################################################
##
##  AddMeasurementReadoutErrors( syndrome_vec, p_meas )
##
##  Flips each syndrome bit with probability p_meas to simulate noisy syndrome
##  extraction circuits.
##
InstallGlobalFunction( AddMeasurementReadoutErrors, function( syndrome_vec, p_meas )
  local noisy_syn, i;
  noisy_syn := List( syndrome_vec, s -> (s + SampleBernoulli( p_meas )) mod 2 );
  return noisy_syn;
end );

#############################################################################
##
##  SamplePauliChannel( pI, pX, pY, pZ )
##
##  Returns a single-qubit Pauli character ('I', 'X', 'Y', 'Z') sampled from
##  the given probability distribution.
##
InstallGlobalFunction( SamplePauliChannel, function( pI, pX, pY, pZ )
  local scale, roll, tX, tY, tZ;
  scale := 1000000;
  roll := Random( [1 .. scale] );
  tX := Int( Float( pX ) * Float( scale ) );
  tY := tX + Int( Float( pY ) * Float( scale ) );
  tZ := tY + Int( Float( pZ ) * Float( scale ) );

  if roll <= tX then
    return 'X';
  elif roll <= tY then
    return 'Y';
  elif roll <= tZ then
    return 'Z';
  else
    return 'I';
  fi;
end );
