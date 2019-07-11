#############################################################################
##
##  lib/tableau.gi                 braid Package
##
##  Implementations for the Gottesman-Knill stabilizer tableau engine,
##  Clifford gate transformations, and projective Pauli measurements.
##
#############################################################################

TableauFamily := NewFamily( "TableauFamily", IsStabilizerTableau );
TableauType := NewType( TableauFamily, IsStabilizerTableau );

#############################################################################
##
##  GottesmanPhaseHelper( x1, z1, x2, z2 )
##
##  Calculates the exponent g(x1, z1, x2, z2) in {0, 1, 2, 3} for the
##  product of two single-qubit Pauli operators:
##    g = 0                if x1 = z1 = 0 (I)
##    g = z2 - x2          if x1 = 1, z1 = 0 (X)
##    g = x2*(1 - 2*z2)    if x1 = 1, z1 = 1 (Y)
##    g = x2 - z2          if x1 = 0, z1 = 1 (Z)
##
GottesmanPhaseHelper := function( x1, z1, x2, z2 )
  if x1 = 0 and z1 = 0 then
    return 0;
  elif x1 = 1 and z1 = 1 then
    return z2 - x2;
  elif x1 = 1 and z1 = 0 then
    return z2 * (2 * x2 - 1);
  elif x1 = 0 and z1 = 1 then
    return x2 * (1 - 2 * z2);
  fi;
  return 0;
end;

#############################################################################
##
##  StabilizerTableau( nqubits )
##
##  Initializes an n-qubit stabilizer tableau representing the computational
##  basis ground state |00...0>.
##  Tableau dimensions: 2n rows by (2n+1) columns.
##  Rows 1..n: destabilizers R_1..R_n (initialized to X_i)
##  Rows (n+1)..2n: stabilizers g_1..g_n (initialized to Z_i)
##  Column 2n+1: phases in {0, 1} where 0 is +1 and 1 is -1.
##
InstallGlobalFunction( StabilizerTableau, function( nqubits )
  local n, tab, i, j;

  if not IsInt( nqubits ) or nqubits < 1 then
    Error( "StabilizerTableau: nqubits must be a positive integer" );
  fi;

  n := nqubits;
  tab := List( [1 .. 2 * n], i -> ListWithIdenticalEntries( 2 * n + 1, 0 ) );

  # Initialize destabilizers to X_i: row i has x_ii = 1
  for i in [1 .. n] do
    tab[i][i] := 1;
  od;

  # Initialize stabilizers to Z_i: row n+i has z_{n+i, i} = 1
  for i in [1 .. n] do
    tab[n + i][n + i] := 1;
  od;

  return Objectify( TableauType, rec(
    nqubits := n,
    matrix := tab
  ) );
end );

#############################################################################
##
##  CloneTableau( tab )
##
InstallGlobalFunction( CloneTableau, function( tab )
  local new_mat, r;
  new_mat := List( tab!.matrix, r -> ShallowCopy( r ) );
  return Objectify( TableauType, rec(
    nqubits := tab!.nqubits,
    matrix := new_mat
  ) );
end );

#############################################################################
##
##  TableauNumQubits( tab )
##
InstallGlobalFunction( TableauNumQubits, function( tab )
  return tab!.nqubits;
end );

#############################################################################
##
##  RowSum( tab, target_row, source_row )
##
##  Multiplies the Pauli operator in source_row into target_row.
##  Updates target_row in place with full phase tracking.
##
InstallGlobalFunction( RowSum, function( tab, target_row, source_row )
  local n, delta, q, x1, z1, x2, z2, r1, r2, net_phase;

  n := tab!.nqubits;
  r1 := tab!.matrix[target_row][2 * n + 1];
  r2 := tab!.matrix[source_row][2 * n + 1];

  delta := 2 * r1 + 2 * r2;

  for q in [1 .. n] do
    x1 := tab!.matrix[target_row][q];
    z1 := tab!.matrix[target_row][n + q];
    x2 := tab!.matrix[source_row][q];
    z2 := tab!.matrix[source_row][n + q];

    delta := delta + GottesmanPhaseHelper( x1, z1, x2, z2 );
  od;

  net_phase := ((delta mod 4) + 4) mod 4;
  if net_phase = 0 then
    tab!.matrix[target_row][2 * n + 1] := 0;
  elif net_phase = 2 then
    tab!.matrix[target_row][2 * n + 1] := 1;
  else
    Error( "RowSum: invalid non-Hermitian phase encountered: ", net_phase );
  fi;

  for q in [1 .. n] do
    tab!.matrix[target_row][q] := (tab!.matrix[target_row][q] + tab!.matrix[source_row][q]) mod 2;
    tab!.matrix[target_row][n + q] := (tab!.matrix[target_row][n + q] + tab!.matrix[source_row][n + q]) mod 2;
  od;
end );

#############################################################################
##
##  ApplyHadamard( tab, qubit )
##
##  Applies Hadamard gate H to the specified qubit:
##    X -> Z, Z -> X, Y -> -Y
##
InstallGlobalFunction( ApplyHadamard, function( tab, qubit )
  local n, i, xi, zi, tmp;

  n := tab!.nqubits;
  if qubit < 1 or qubit > n then
    Error( "ApplyHadamard: qubit out of range" );
  fi;

  for i in [1 .. 2 * n] do
    xi := tab!.matrix[i][qubit];
    zi := tab!.matrix[i][n + qubit];

    # Phase update: flips if both xi and zi are 1 (Y gate)
    tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + (xi * zi)) mod 2;

    # Swap xi and zi
    tmp := xi;
    tab!.matrix[i][qubit] := zi;
    tab!.matrix[i][n + qubit] := tmp;
  od;
end );

#############################################################################
##
##  ApplyPhase( tab, qubit )
##
##  Applies Phase gate S to the specified qubit:
##    X -> Y, Z -> Z, Y -> -X
##
InstallGlobalFunction( ApplyPhase, function( tab, qubit )
  local n, i, xi, zi;

  n := tab!.nqubits;
  if qubit < 1 or qubit > n then
    Error( "ApplyPhase: qubit out of range" );
  fi;

  for i in [1 .. 2 * n] do
    xi := tab!.matrix[i][qubit];
    zi := tab!.matrix[i][n + qubit];

    # Phase update: flips if both xi and zi are 1
    tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + (xi * zi)) mod 2;

    # zi <- zi xor xi
    tab!.matrix[i][n + qubit] := (zi + xi) mod 2;
  od;
end );

#############################################################################
##
##  ApplyPhaseDagger( tab, qubit )
##
##  Applies S^\dagger = S^3.
##
InstallGlobalFunction( ApplyPhaseDagger, function( tab, qubit )
  ApplyPhase( tab, qubit );
  ApplyPhase( tab, qubit );
  ApplyPhase( tab, qubit );
end );

#############################################################################
##
##  ApplyPauliX( tab, qubit )
##
InstallGlobalFunction( ApplyPauliX, function( tab, qubit )
  local n, i;
  n := tab!.nqubits;
  for i in [1 .. 2 * n] do
    if tab!.matrix[i][n + qubit] = 1 then
      tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + 1) mod 2;
    fi;
  od;
end );

#############################################################################
##
##  ApplyPauliY( tab, qubit )
##
InstallGlobalFunction( ApplyPauliY, function( tab, qubit )
  local n, i, xi, zi;
  n := tab!.nqubits;
  for i in [1 .. 2 * n] do
    xi := tab!.matrix[i][qubit];
    zi := tab!.matrix[i][n + qubit];
    if (xi + zi) mod 2 = 1 then
      tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + 1) mod 2;
    fi;
  od;
end );

#############################################################################
##
##  ApplyPauliZ( tab, qubit )
##
InstallGlobalFunction( ApplyPauliZ, function( tab, qubit )
  local n, i;
  n := tab!.nqubits;
  for i in [1 .. 2 * n] do
    if tab!.matrix[i][qubit] = 1 then
      tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + 1) mod 2;
    fi;
  od;
end );

#############################################################################
##
##  ApplyCNOT( tab, control, target )
##
##  Applies CNOT gate:
##    X_c -> X_c X_t,  Z_t -> Z_c Z_t
##
InstallGlobalFunction( ApplyCNOT, function( tab, control, target )
  local n, i, xc, zc, xt, zt;

  n := tab!.nqubits;
  if control = target then
    Error( "ApplyCNOT: control and target must be distinct qubits" );
  fi;

  for i in [1 .. 2 * n] do
    xc := tab!.matrix[i][control];
    zc := tab!.matrix[i][n + control];
    xt := tab!.matrix[i][target];
    zt := tab!.matrix[i][n + target];

    # Phase update: r <- r xor (xc * zt * (xt xor zc xor 1))
    tab!.matrix[i][2 * n + 1] := (tab!.matrix[i][2 * n + 1] + (xc * zt * ((xt + zc + 1) mod 2))) mod 2;

    # xt <- xt xor xc
    tab!.matrix[i][target] := (xt + xc) mod 2;

    # zc <- zc xor zt
    tab!.matrix[i][n + control] := (zc + zt) mod 2;
  od;
end );

#############################################################################
##
##  ApplyCZ( tab, q1, q2 )
##
InstallGlobalFunction( ApplyCZ, function( tab, q1, q2 )
  ApplyHadamard( tab, q2 );
  ApplyCNOT( tab, q1, q2 );
  ApplyHadamard( tab, q2 );
end );

#############################################################################
##
##  ApplySWAP( tab, q1, q2 )
##
InstallGlobalFunction( ApplySWAP, function( tab, q1, q2 )
  ApplyCNOT( tab, q1, q2 );
  ApplyCNOT( tab, q2, q1 );
  ApplyCNOT( tab, q1, q2 );
end );

#############################################################################
##
##  MeasurePauliZ( tab, qubit )
##
##  Measures observable Z on the specified qubit.
##  Returns measurement outcome 0 (for eigenvalue +1) or 1 (for eigenvalue -1).
##  Updates the stabilizer tableau in place.
##
InstallGlobalFunction( MeasurePauliZ, function( tab, qubit )
  local n, p, i, outcome, scratch_row, scratch_tab;

  n := tab!.nqubits;
  if qubit < 1 or qubit > n then
    Error( "MeasurePauliZ: qubit out of range" );
  fi;

  # Check if any stabilizer row anticommutes with Z_qubit: that is, x_{n+i, qubit} = 1
  p := 0;
  for i in [1 .. n] do
    if tab!.matrix[n + i][qubit] = 1 then
      p := n + i;
      break;
    fi;
  od;

  if p > 0 then
    # Non-deterministic outcome
    # For every other row i <> p with x_{i, qubit} = 1, call RowSum(tab, i, p)
    for i in [1 .. 2 * n] do
      if i <> p and i <> (p - n) and tab!.matrix[i][qubit] = 1 then
        RowSum( tab, i, p );
      fi;
    od;

    # Copy row p to destabilizer row (p - n)
    tab!.matrix[p - n] := ShallowCopy( tab!.matrix[p] );

    # Set row p to all zeros except z_{p, qubit} = 1 and random phase
    outcome := Random( [0, 1] );
    tab!.matrix[p] := ListWithIdenticalEntries( 2 * n + 1, 0 );
    tab!.matrix[p][n + qubit] := 1;
    tab!.matrix[p][2 * n + 1] := outcome;

    return outcome;
  else
    # Deterministic outcome
    # Construct temporary scratch row initialized to 0
    scratch_row := ListWithIdenticalEntries( 2 * n + 1, 0 );
    # Embed into a temporary 1-row container to use RowSum
    scratch_tab := rec(
      nqubits := n,
      matrix := [ scratch_row ]
    );

    for i in [1 .. n] do
      if tab!.matrix[i][qubit] = 1 then
        # Add stabilizer row n + i into scratch row
        Add( scratch_tab.matrix, ShallowCopy( tab!.matrix[n + i] ) );
        RowSum( scratch_tab, 1, Length( scratch_tab.matrix ) );
      fi;
    od;

    outcome := scratch_tab.matrix[1][2 * n + 1];
    return outcome;
  fi;
end );

#############################################################################
##
##  GetStabilizerGenerators( tab )
##
InstallGlobalFunction( GetStabilizerGenerators, function( tab )
  local n, gens, i, r, phase, x, z;
  n := tab!.nqubits;
  gens := [ ];
  for i in [1 .. n] do
    r := tab!.matrix[n + i];
    phase := r[2 * n + 1] * 2; # 0 -> phase 0 (+), 1 -> phase 2 (-)
    x := r{[1 .. n]};
    z := r{[n + 1 .. 2 * n]};
    Add( gens, PauliOperator( n, phase, x, z ) );
  od;
  return gens;
end );

#############################################################################
##
##  GetDestabilizerGenerators( tab )
##
InstallGlobalFunction( GetDestabilizerGenerators, function( tab )
  local n, degens, i, r, phase, x, z;
  n := tab!.nqubits;
  degens := [ ];
  for i in [1 .. n] do
    r := tab!.matrix[i];
    phase := r[2 * n + 1] * 2;
    x := r{[1 .. n]};
    z := r{[n + 1 .. 2 * n]};
    Add( degens, PauliOperator( n, phase, x, z ) );
  od;
  return degens;
end );

#############################################################################
##
##  IsStabilizerTableauCanonical( tab )
##
InstallGlobalFunction( IsStabilizerTableauCanonical, function( tab )
  local n, i, j, stabs;
  n := tab!.nqubits;
  stabs := GetStabilizerGenerators( tab );
  for i in [1 .. n] do
    for j in [i + 1 .. n] do
      if not CommutesWith( stabs[i], stabs[j] ) then
        return false;
      fi;
    od;
  od;
  return true;
end );

#############################################################################
##
##  TableauToMatrix( tab )
##
InstallGlobalFunction( TableauToMatrix, function( tab )
  return List( tab!.matrix, r -> ShallowCopy( r ) );
end );

#############################################################################
##
##  PrintTableau( tab )
##
InstallGlobalFunction( PrintTableau, function( tab )
  local n, i, r, s;
  n := tab!.nqubits;
  Print( "Stabilizer Tableau (", n, " qubits):\n" );
  Print( "Destabilizers:\n" );
  for i in [1 .. n] do
    r := tab!.matrix[i];
    s := StringFromPauli( PauliOperator( n, r[2 * n + 1] * 2, r{[1 .. n]}, r{[n + 1 .. 2 * n]} ) );
    Print( "  R", i, ": ", s, "\n" );
  od;
  Print( "Stabilizers:\n" );
  for i in [1 .. n] do
    r := tab!.matrix[n + i];
    s := StringFromPauli( PauliOperator( n, r[2 * n + 1] * 2, r{[1 .. n]}, r{[n + 1 .. 2 * n]} ) );
    Print( "  g", i, ": ", s, "\n" );
  od;
end );

InstallMethod( ViewString, "for StabilizerTableau", [ IsStabilizerTableau ],
  function( tab )
    return Concatenation( "<StabilizerTableau on ", String( tab!.nqubits ), " qubits>" );
  end );

InstallMethod( PrintObj, "for StabilizerTableau", [ IsStabilizerTableau ],
  function( tab )
    PrintTableau( tab );
  end );
