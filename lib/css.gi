#############################################################################
##
##  lib/css.gi                     braid Package
##
##  Implementations for Calderbank-Shor-Steane (CSS) quantum codes,
##  classical dual code embeddings, Steane [[7,1,3]], and Shor [[9,1,3]].
##
#############################################################################

#############################################################################
##
##  CSSCode( H_X, H_Z )
##
##  Constructs a CSS code from binary parity check matrices H_X and H_Z
##  satisfying H_X * H_Z^T = 0 mod 2.
##
InstallGlobalFunction( CSSCode, function( H_X, H_Z )
  local n, rx, rz, i, j, k, sum, x_gens, z_gens, zeros, x_row, z_row, all_gens, code;

  rx := Length( H_X );
  rz := Length( H_Z );
  if rx = 0 or rz = 0 then
    Error( "CSSCode: H_X and H_Z must have at least one row" );
  fi;

  n := Length( H_X[1] );
  if Length( H_Z[1] ) <> n then
    Error( "CSSCode: H_X and H_Z column counts do not match" );
  fi;

  # Verify commutativity condition: H_X * H_Z^T = 0 mod 2
  for i in [1 .. rx] do
    for j in [1 .. rz] do
      sum := 0;
      for k in [1 .. n] do
        sum := sum + H_X[i][k] * H_Z[j][k];
      od;
      if (sum mod 2) <> 0 then
        Error( "CSSCode: H_X row ", i, " and H_Z row ", j, " do not commute mod 2" );
      fi;
    od;
  od;

  zeros := ListWithIdenticalEntries( n, 0 );
  x_gens := [ ];
  for i in [1 .. rx] do
    x_row := List( H_X[i], v -> (v mod 2) );
    Add( x_gens, PauliOperator( n, 0, x_row, zeros ) );
  od;

  z_gens := [ ];
  for j in [1 .. rz] do
    z_row := List( H_Z[j], v -> (v mod 2) );
    Add( z_gens, PauliOperator( n, 0, zeros, z_row ) );
  od;

  all_gens := Concatenation( x_gens, z_gens );
  code := StabilizerCode( n, all_gens );
  return code;
end );

#############################################################################
##
##  HammingCodeCheckMatrix( r )
##
##  Constructs the parity check matrix for the [2^r - 1, 2^r - 1 - r, 3]
##  Hamming code. For r = 3, generates the 3 x 7 matrix.
##
InstallGlobalFunction( HammingCodeCheckMatrix, function( r )
  local n, H, col, val, row;
  n := 2^r - 1;
  H := List( [1 .. r], row -> ListWithIdenticalEntries( n, 0 ) );
  for col in [1 .. n] do
    val := col;
    for row in [1 .. r] do
      H[row][col] := val mod 2;
      val := QuoInt( val, 2 );
    od;
  od;
  return H;
end );

#############################################################################
##
##  SteaneCode()
##
##  Constructs the canonical [[7, 1, 3]] Steane code from the [7, 4, 3]
##  Hamming code. H_X = H_Z = H_Hamming.
##
InstallGlobalFunction( SteaneCode, function()
  local H7, code;
  H7 := [
    [ 1, 0, 1, 0, 1, 0, 1 ],
    [ 0, 1, 1, 0, 0, 1, 1 ],
    [ 0, 0, 0, 1, 1, 1, 1 ]
  ];
  code := CSSCode( H7, H7 );
  return code;
end );

#############################################################################
##
##  ShorCode()
##
##  Constructs the [[9, 1, 3]] Shor code.
##
InstallGlobalFunction( ShorCode, function()
  local HX, HZ;
  HX := [
    [ 1, 1, 1, 1, 1, 1, 0, 0, 0 ],
    [ 0, 0, 0, 1, 1, 1, 1, 1, 1 ]
  ];
  HZ := [
    [ 1, 1, 0, 0, 0, 0, 0, 0, 0 ],
    [ 0, 1, 1, 0, 0, 0, 0, 0, 0 ],
    [ 0, 0, 0, 1, 1, 0, 0, 0, 0 ],
    [ 0, 0, 0, 0, 1, 1, 0, 0, 0 ],
    [ 0, 0, 0, 0, 0, 0, 1, 1, 0 ],
    [ 0, 0, 0, 0, 0, 0, 0, 1, 1 ]
  ];
  return CSSCode( HX, HZ );
end );

#############################################################################
##
##  IsCSSCode( code )
##
InstallGlobalFunction( IsCSSCode, function( code )
  local g;
  for g in code!.generators do
    if (Sum( g!.x ) > 0) and (Sum( g!.z ) > 0) then
      return false;
    fi;
  od;
  return true;
end );

#############################################################################
##
##  CSSXStabilizers( code )
##
InstallGlobalFunction( CSSXStabilizers, function( code )
  return Filtered( code!.generators, g -> Sum( g!.x ) > 0 and Sum( g!.z ) = 0 );
end );

#############################################################################
##
##  CSSZStabilizers( code )
##
InstallGlobalFunction( CSSZStabilizers, function( code )
  return Filtered( code!.generators, g -> Sum( g!.z ) > 0 and Sum( g!.x ) = 0 );
end );
