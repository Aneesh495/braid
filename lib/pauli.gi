#############################################################################
##
##  lib/pauli.gi                   braid Package
##
##  Implementations for multi-qubit Pauli operators, symplectic vectors,
##  and finite field binary commutation geometry.
##
#############################################################################

PauliFamily := NewFamily( "PauliFamily", IsPauliOperator );
PauliType := NewType( PauliFamily, IsPauliOperator );

#############################################################################
##
##  PauliOperator( nqubits, phase, xvec, zvec )
##
##  Constructs an n-qubit Pauli operator with phase in {0,1,2,3} representing
##  i^phase, and binary vectors xvec and zvec in F2^n.
##
InstallGlobalFunction( PauliOperator, function( nqubits, phase, xvec, zvec )
  local p, x, z, i;

  if not IsInt( nqubits ) or nqubits < 1 then
    Error( "PauliOperator: nqubits must be a positive integer" );
  fi;

  p := ((phase mod 4) + 4) mod 4;

  if Length( xvec ) <> nqubits or Length( zvec ) <> nqubits then
    Error( "PauliOperator: xvec and zvec must have length equal to nqubits" );
  fi;

  x := List( xvec, v -> (v mod 2) );
  z := List( zvec, v -> (v mod 2) );

  return Objectify( PauliType, rec(
    nqubits := nqubits,
    phase := p,
    x := x,
    z := z
  ) );
end );

#############################################################################
##
##  PauliIdentity( nqubits )
##
InstallGlobalFunction( PauliIdentity, function( nqubits )
  local zeros;
  zeros := ListWithIdenticalEntries( nqubits, 0 );
  return PauliOperator( nqubits, 0, zeros, zeros );
end );

#############################################################################
##
##  SingleQubitPauli( nqubits, target_qubit, char_label )
##
InstallGlobalFunction( SingleQubitPauli, function( nqubits, target_qubit, char_label )
  local x, z;

  if target_qubit < 1 or target_qubit > nqubits then
    Error( "SingleQubitPauli: target_qubit out of range" );
  fi;

  x := ListWithIdenticalEntries( nqubits, 0 );
  z := ListWithIdenticalEntries( nqubits, 0 );

  if char_label in [ 'I', 'i' ] then
    # identity: both zero
  elif char_label in [ 'X', 'x' ] then
    x[target_qubit] := 1;
  elif char_label in [ 'Y', 'y' ] then
    x[target_qubit] := 1;
    z[target_qubit] := 1;
  elif char_label in [ 'Z', 'z' ] then
    z[target_qubit] := 1;
  else
    Error( "SingleQubitPauli: unknown Pauli character ", char_label );
  fi;

  return PauliOperator( nqubits, 0, x, z );
end );

#############################################################################
##
##  PauliFromString( str )
##
##  Parses strings such as "+IXYZ", "-iXZ", "Z", "-X" into PauliOperator.
##
InstallGlobalFunction( PauliFromString, function( raw_str )
  local s, phase, idx, n, x, z, c, i;

  s := Filtered( raw_str, c -> c <> ' ' );
  if Length( s ) = 0 then
    Error( "PauliFromString: empty input string" );
  fi;

  phase := 0;
  idx := 1;

  # Check leading sign prefixes
  if Length( s ) >= 2 and s{[1..2]} = "+i" then
    phase := 1;
    idx := 3;
  elif Length( s ) >= 2 and s{[1..2]} = "-i" then
    phase := 3;
    idx := 3;
  elif s[1] = '+' then
    phase := 0;
    idx := 2;
  elif s[1] = '-' then
    phase := 2;
    idx := 2;
  elif s[1] = 'i' then
    phase := 1;
    idx := 2;
  fi;

  n := Length( s ) - idx + 1;
  if n < 1 then
    Error( "PauliFromString: no Pauli letters in string" );
  fi;

  x := ListWithIdenticalEntries( n, 0 );
  z := ListWithIdenticalEntries( n, 0 );

  for i in [1..n] do
    c := s[idx + i - 1];
    if c in [ 'I', 'i' ] then
      x[i] := 0; z[i] := 0;
    elif c in [ 'X', 'x' ] then
      x[i] := 1; z[i] := 0;
    elif c in [ 'Y', 'y' ] then
      x[i] := 1; z[i] := 1;
    elif c in [ 'Z', 'z' ] then
      x[i] := 0; z[i] := 1;
    else
      Error( "PauliFromString: unrecognized Pauli character '", c, "'" );
    fi;
  od;

  return PauliOperator( n, phase, x, z );
end );

#############################################################################
##
##  StringFromPauli( P )
##
InstallGlobalFunction( StringFromPauli, function( P )
  local res, prefix, i, xi, zi;

  if P!.phase = 0 then
    prefix := "+";
  elif P!.phase = 1 then
    prefix := "+i";
  elif P!.phase = 2 then
    prefix := "-";
  elif P!.phase = 3 then
    prefix := "-i";
  fi;

  res := ShallowCopy( prefix );
  for i in [1..P!.nqubits] do
    xi := P!.x[i];
    zi := P!.z[i];
    if xi = 0 and zi = 0 then
      Add( res, 'I' );
    elif xi = 1 and zi = 0 then
      Add( res, 'X' );
    elif xi = 1 and zi = 1 then
      Add( res, 'Y' );
    elif xi = 0 and zi = 1 then
      Add( res, 'Z' );
    fi;
  od;

  return res;
end );

InstallMethod( ViewString, "for PauliOperator", [ IsPauliOperator ],
  function( P )
    return StringFromPauli( P );
  end );

InstallMethod( PrintObj, "for PauliOperator", [ IsPauliOperator ],
  function( P )
    Print( StringFromPauli( P ) );
  end );

#############################################################################
##
##  PauliWeight( P )
##
##  Hamming weight of Pauli operator: count of non-identity qubit indices.
##
InstallGlobalFunction( PauliWeight, function( P )
  local wt, i;
  wt := 0;
  for i in [1..P!.nqubits] do
    if P!.x[i] <> 0 or P!.z[i] <> 0 then
      wt := wt + 1;
    fi;
  od;
  return wt;
end );

#############################################################################
##
##  SymplecticInnerProduct( P1, P2 )
##
##  Returns x1 * z2 + z1 * x2 mod 2.
##  Can accept either two PauliOperators or two pairs of binary vectors.
##
InstallGlobalFunction( SymplecticInnerProduct, function( arg1, arg2 )
  local sum, n, i, x1, z1, x2, z2;

  if IsPauliOperator( arg1 ) and IsPauliOperator( arg2 ) then
    if arg1!.nqubits <> arg2!.nqubits then
      Error( "SymplecticInnerProduct: qubit counts do not match" );
    fi;
    n := arg1!.nqubits;
    x1 := arg1!.x; z1 := arg1!.z;
    x2 := arg2!.x; z2 := arg2!.z;
  else
    # Vector form: [x1, z1] and [x2, z2]
    x1 := arg1[1]; z1 := arg1[2];
    x2 := arg2[1]; z2 := arg2[2];
    n := Length( x1 );
  fi;

  sum := 0;
  for i in [1..n] do
    sum := sum + x1[i] * z2[i] + z1[i] * x2[i];
  od;

  return (sum mod 2);
end );

#############################################################################
##
##  CommutesWith( P1, P2 )
##
InstallGlobalFunction( CommutesWith, function( P1, P2 )
  return SymplecticInnerProduct( P1, P2 ) = 0;
end );

#############################################################################
##
##  MultiplyPauli( P1, P2 )
##
##  Computes P1 * P2 exactly including phase updates.
##  Phase calculation rule for single-qubit multiplications:
##  XY = iZ, YX = -iZ, YZ = iX, ZY = -iX, ZX = iY, XZ = -iY
##
InstallGlobalFunction( MultiplyPauli, function( P1, P2 )
  local n, new_phase, new_x, new_z, i, x1, z1, x2, z2, delta;

  if P1!.nqubits <> P2!.nqubits then
    Error( "MultiplyPauli: qubit count mismatch" );
  fi;

  n := P1!.nqubits;
  new_x := ListWithIdenticalEntries( n, 0 );
  new_z := ListWithIdenticalEntries( n, 0 );
  new_phase := P1!.phase + P2!.phase;

  for i in [1..n] do
    x1 := P1!.x[i]; z1 := P1!.z[i];
    x2 := P2!.x[i]; z2 := P2!.z[i];

    new_x[i] := (x1 + x2) mod 2;
    new_z[i] := (z1 + z2) mod 2;

    # Exact phase contribution delta in {0, 1, 2, 3} where result is i^delta
    delta := 0;
    if x1 = 1 and z1 = 0 then       # X
      if x2 = 1 and z2 = 1 then     # X * Y = i Z
        delta := 1;
      elif x2 = 0 and z2 = 1 then   # X * Z = -i Y
        delta := 3;
      fi;
    elif x1 = 1 and z1 = 1 then     # Y
      if x2 = 1 and z2 = 0 then     # Y * X = -i Z
        delta := 3;
      elif x2 = 0 and z2 = 1 then   # Y * Z = i X
        delta := 1;
      fi;
    elif x1 = 0 and z1 = 1 then     # Z
      if x2 = 1 and z2 = 0 then     # Z * X = i Y
        delta := 1;
      elif x2 = 1 and z2 = 1 then   # Z * Y = -i X
        delta := 3;
      fi;
    fi;

    new_phase := new_phase + delta;
  od;

  new_phase := ((new_phase mod 4) + 4) mod 4;
  return PauliOperator( n, new_phase, new_x, new_z );
end );

#############################################################################
##
##  TensorPauli( P1, P2 )
##
##  Tensor product P1 (x) P2.
##
InstallGlobalFunction( TensorPauli, function( P1, P2 )
  local n, p, new_x, new_z;
  n := P1!.nqubits + P2!.nqubits;
  p := (P1!.phase + P2!.phase) mod 4;
  new_x := Concatenation( P1!.x, P2!.x );
  new_z := Concatenation( P1!.z, P2!.z );
  return PauliOperator( n, p, new_x, new_z );
end );

#############################################################################
##
##  PauliPower( P, k )
##
##  Computes P^k where k is an integer.
##
InstallGlobalFunction( PauliPower, function( P, k )
  local res, cur, exp;
  exp := k mod 4;
  if exp < 0 then
    exp := exp + 4;
  fi;

  res := PauliIdentity( P!.nqubits );
  cur := P;
  while exp > 0 do
    if exp mod 2 = 1 then
      res := MultiplyPauli( res, cur );
    fi;
    cur := MultiplyPauli( cur, cur );
    exp := QuoInt( exp, 2 );
  od;
  return res;
end );

#############################################################################
##
##  PauliHermitianConjugate( P )
##
##  Computes P^dagger. Since X, Y, Z are Hermitian, only the phase is conjugated:
##  (i^p)^dagger = i^(-p) = i^(4-p).
##
InstallGlobalFunction( PauliHermitianConjugate, function( P )
  local new_phase;
  new_phase := (4 - P!.phase) mod 4;
  return PauliOperator( P!.nqubits, new_phase, ShallowCopy( P!.x ), ShallowCopy( P!.z ) );
end );
