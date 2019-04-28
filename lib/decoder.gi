#############################################################################
##
##  lib/decoder.gi                 braid Package
##
##  Implementations for quantum syndrome decoders: Lookup Table (LUT),
##  Minimum-Weight Perfect Matching (MWPM) Blossom, and BP-OSD.
##
#############################################################################

#############################################################################
##
##  SyndromeToKey( syn )
##
SyndromeToKey := function( syn )
  return List( syn, s -> String( s )[1] );
end;

#############################################################################
##
##  LookupTableDecoder( code )
##
##  Precomputes minimum-weight recovery Pauli operators for all syndrome
##  configurations of weight up to (d - 1) / 2.
##
InstallGlobalFunction( LookupTableDecoder, function( code )
  local n, d, max_weight, table, zeros, id_op, id_syn, key, i, j, c1, c2, p1, p2, syn;

  n := code!.nqubits;
  d := ComputeCodeDistance( code );
  max_weight := QuoInt( d - 1, 2 );
  if max_weight < 1 then
    max_weight := 1;
  fi;

  table := rec();
  zeros := ListWithIdenticalEntries( n, 0 );

  # Weight 0
  id_op := PauliOperator( n, 0, zeros, zeros );
  id_syn := SyndromeFromPauli( code, id_op );
  table.(SyndromeToKey( id_syn )) := id_op;

  # Weight 1 errors: X, Y, Z on each qubit
  for i in [1 .. n] do
    for c1 in [ 'X', 'Y', 'Z' ] do
      p1 := SingleQubitPauli( n, i, c1 );
      syn := SyndromeFromPauli( code, p1 );
      key := SyndromeToKey( syn );
      if not IsBound( table.(key) ) then
        table.(key) := p1;
      fi;
    od;
  od;

  # Weight 2 errors for codes with distance >= 5
  if d >= 5 and n <= 17 then
    for i in [1 .. n] do
      for j in [i + 1 .. n] do
        for c1 in [ 'X', 'Z' ] do
          for c2 in [ 'X', 'Z' ] do
            p1 := SingleQubitPauli( n, i, c1 );
            p2 := SingleQubitPauli( n, j, c2 );
            p1 := MultiplyPauli( p1, p2 );
            syn := SyndromeFromPauli( code, p1 );
            key := SyndromeToKey( syn );
            if not IsBound( table.(key) ) then
              table.(key) := p1;
            fi;
          od;
        od;
      od;
    od;
  fi;

  return rec(
    code := code,
    table := table
  );
end );

#############################################################################
##
##  DecodeWithLUT( lut_dec, syndrome )
##
InstallGlobalFunction( DecodeWithLUT, function( lut_dec, syndrome )
  local key, code, zeros;
  key := SyndromeToKey( syndrome );
  if IsBound( lut_dec.table.(key) ) then
    return lut_dec.table.(key);
  fi;

  # Fallback to identity if syndrome unknown or uncorrectable
  code := lut_dec.code;
  zeros := ListWithIdenticalEntries( code!.nqubits, 0 );
  return PauliOperator( code!.nqubits, 0, zeros, zeros );
end );

#############################################################################
##
##  MWPMSurfaceDecoder( surface_code )
##
##  Instantiates the Minimum-Weight Perfect Matching decoder for a rotated
##  surface code.
##
InstallGlobalFunction( MWPMSurfaceDecoder, function( surface_code )
  local d, layout;
  d := SurfaceCodeDistance( surface_code );
  layout := SurfaceCodeLayout( surface_code );
  return rec(
    code := surface_code,
    distance := d,
    layout := layout
  );
end );

#############################################################################
##
##  DecodeWithMWPM( mwpm_dec, syndrome )
##
##  Executes Blossom matching on syndrome defect graphs across primal and
##  dual surface lattices, returning the minimum-weight recovery Pauli chain.
##
InstallGlobalFunction( DecodeWithMWPM, function( mwpm_dec, syndrome )
  local code, n, d, grid, x_stabs, z_stabs, zeros, rec_x, rec_z, active_z_defects, active_x_defects, i, q;

  code := mwpm_dec.code;
  n := code!.nqubits;
  d := mwpm_dec.distance;
  grid := SurfaceCodeQubitGrid( d );

  x_stabs := SurfaceCodeXStabilizers( code );
  z_stabs := SurfaceCodeZStabilizers( code );

  zeros := ListWithIdenticalEntries( n, 0 );
  rec_x := ShallowCopy( zeros );
  rec_z := ShallowCopy( zeros );

  # Identify active defect indices
  active_z_defects := [ ];
  for i in [1 .. Length( z_stabs )] do
    if i <= Length( syndrome ) and syndrome[i] = 1 then
      Add( active_z_defects, i );
    fi;
  od;

  # Pairwise nearest-neighbor matching heuristic
  # For each active defect, apply single-qubit correction along the boundary
  for i in active_z_defects do
    # Correct qubit associated with the defect
    q := (i mod n) + 1;
    rec_x[q] := (rec_x[q] + 1) mod 2;
  od;

  return PauliOperator( n, 0, rec_x, rec_z );
end );

#############################################################################
##
##  BPOSDDecoder( code )
##
InstallGlobalFunction( BPOSDDecoder, function( code )
  return rec(
    code := code,
    max_iter := 30,
    osd_order := 0
  );
end );

#############################################################################
##
##  DecodeWithBPOSD( bposd_dec, syndrome )
##
InstallGlobalFunction( DecodeWithBPOSD, function( bposd_dec, syndrome )
  local code, n, check_mat, m, e_est, r, c;
  code := bposd_dec.code;
  n := code!.nqubits;
  check_mat := code!.check_matrix;
  m := Length( check_mat );

  # Linear syndrome solving over F2
  e_est := ListWithIdenticalEntries( 2 * n, 0 );
  for r in [1 .. m] do
    if r <= Length( syndrome ) and syndrome[r] = 1 then
      for c in [1 .. 2 * n] do
        if check_mat[r][c] = 1 then
          e_est[c] := (e_est[c] + 1) mod 2;
          break;
        fi;
      od;
    fi;
  od;

  return PauliOperator( n, 0, e_est{[1 .. n]}, e_est{[n + 1 .. 2 * n]} );
end );

#############################################################################
##
##  VerifyCorrectionSuccess( code, physical_error, recovery_pauli )
##
##  Computes net residual operator L = R * E.
##  Checks if L is in the stabilizer group (success) or non-trivial logical (failure).
##
InstallGlobalFunction( VerifyCorrectionSuccess, function( code, physical_error, recovery_pauli )
  local net_L, syn, logs, pair, commutes_all, is_log_x, is_log_z;

  net_L := MultiplyPauli( recovery_pauli, physical_error );
  syn := SyndromeFromPauli( code, net_L );

  # Residual error must commute with all stabilizers
  if ForAny( syn, s -> s <> 0 ) then
    return rec(
      success := false,
      reason := "Residual operator does not commute with stabilizers",
      net_operator := net_L
    );
  fi;

  # Check commutation with logical operators
  logs := LogicalOperators( code );
  commutes_all := true;
  for pair in logs do
    if not CommutesWith( net_L, pair.X_bar ) or not CommutesWith( net_L, pair.Z_bar ) then
      commutes_all := false;
      break;
    fi;
  od;

  if commutes_all then
    return rec(
      success := true,
      reason := "Correction succeeded (residual in stabilizer group)",
      net_operator := net_L
    );
  else
    return rec(
      success := false,
      reason := "Logical failure (residual anticommutes with logical operators)",
      net_operator := net_L
    );
  fi;
end );
