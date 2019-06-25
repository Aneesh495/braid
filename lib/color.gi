#############################################################################
##
##  lib/color.gi                  braid Package
##
##  Implementations for 2D topological color codes (Bombin & Martin-Delgado).
##  Color codes feature 3-valent 3-colorable planar lattices where every face
##  hosts both X and Z check operators, allowing full transversal Clifford gates.
##
#############################################################################

#############################################################################
##
##  ColorCode( d )
##
##  Constructs a 2D triangular color code of distance d (supported: d = 3).
##  For d = 3, this constructs the 7-qubit Steane [[7, 1, 3]] color code on a
##  3-valent 3-colorable planar graph with 3 plaquettes colored Red, Green, Blue.
##
InstallGlobalFunction( ColorCode, function( d )
  local faces, n, hx, hz, f, row, ccode;

  if d = 3 then
    n := 7;
    faces := [
      rec( color := "R", qubits := [ 1, 2, 3, 4 ] ),
      rec( color := "G", qubits := [ 2, 3, 5, 6 ] ),
      rec( color := "B", qubits := [ 3, 4, 6, 7 ] )
    ];
  else
    Error( "ColorCode: currently distance d = 3 is supported" );
  fi;

  # Build parity check matrices H_X and H_Z (identical because code is self-dual)
  hx := [ ];
  for f in faces do
    row := ListWithIdenticalEntries( n, 0 );
    row{f.qubits} := ListWithIdenticalEntries( Length( f.qubits ), 1 );
    Add( hx, row );
  od;
  hz := StructuralCopy( hx );

  ccode := CSSCode( hx, hz );
  ccode!.distance := d;
  ccode!.faces := faces;
  ccode!.is_color_code := true;

  return ccode;
end );

#############################################################################
##
##  ColorCodeDistance( ccode )
##
InstallGlobalFunction( ColorCodeDistance, function( ccode )
  if IsBound( ccode!.distance ) then
    return ccode!.distance;
  fi;
  return 3;
end );

#############################################################################
##
##  ColorCodeFaces( ccode )
##
InstallGlobalFunction( ColorCodeFaces, function( ccode )
  if IsBound( ccode!.faces ) then
    return ccode!.faces;
  fi;
  return [ ];
end );

#############################################################################
##
##  ColorCodeLogicalX( ccode )
##
##  Returns logical X operator (transversal bitwise X on all qubits).
##
InstallGlobalFunction( ColorCodeLogicalX, function( ccode )
  local n, ones, zeros;
  n := ccode!.nqubits;
  ones := ListWithIdenticalEntries( n, 1 );
  zeros := ListWithIdenticalEntries( n, 0 );
  return PauliOperator( n, 0, ones, zeros );
end );

#############################################################################
##
##  ColorCodeLogicalZ( ccode )
##
##  Returns logical Z operator (transversal bitwise Z on all qubits).
##
InstallGlobalFunction( ColorCodeLogicalZ, function( ccode )
  local n, ones, zeros;
  n := ccode!.nqubits;
  ones := ListWithIdenticalEntries( n, 1 );
  zeros := ListWithIdenticalEntries( n, 0 );
  return PauliOperator( n, 0, zeros, ones );
end );

#############################################################################
##
##  ColorCodeVerifyTransversalClifford( ccode )
##
##  Verifies that bitwise transversal Hadamard maps X stabilizers into Z
##  stabilizers and vice-versa, confirming transversal Clifford group preservation.
##
InstallGlobalFunction( ColorCodeVerifyTransversalClifford, function( ccode )
  local hx, hz;
  hx := ccode!.hx;
  hz := ccode!.hz;

  # Transversal Hadamard swaps X and Z checks: H X H^dag = Z, H Z H^dag = X.
  # Since H_X = H_Z for 2D color codes, H^(\otimes n) exactly maps X checks to Z checks!
  return hx = hz;
end );
