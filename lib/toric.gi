#############################################################################
##
##  lib/toric.gi                  braid Package
##
##  Implementations for Kitaev's Toric Code on periodic 2D square lattices.
##  Encodes k = 2 logical qubits into n = 2*L^2 physical edge qubits with
##  code distance d = L.
##
#############################################################################

#############################################################################
##
##  ToricCode( L )
##
##  Constructs the [[2*L^2, 2, L]] Toric Code on an L x L periodic torus.
##
InstallGlobalFunction( ToricCode, function( L )
  local n, edge_idx, hx, hz, x, y, x_prev, y_prev, x_next, y_next,
        star_edges, plaq_edges, row, code, log_ops;

  if L < 2 then
    Error( "ToricCode: linear size L must be at least 2" );
  fi;

  n := 2 * L * L;

  # edge_idx(x, y, orientation): 0 = horizontal edge, 1 = vertical edge
  # x, y in 1..L
  edge_idx := function( px, py, orient )
    return ( (px - 1) * L + (py - 1) ) * 2 + orient + 1;
  end;

  hx := [ ];
  hz := [ ];

  for x in [1 .. L] do
    for y in [1 .. L] do
      x_prev := ( (x - 2 + L) mod L ) + 1;
      y_prev := ( (y - 2 + L) mod L ) + 1;
      x_next := ( x mod L ) + 1;
      y_next := ( y mod L ) + 1;

      # Star (vertex) operator at (x, y): 4 incident edges
      star_edges := [
        edge_idx( x, y, 0 ),      # right
        edge_idx( x, y, 1 ),      # up
        edge_idx( x_prev, y, 0 ), # left
        edge_idx( x, y_prev, 1 )  # down
      ];
      row := ListWithIdenticalEntries( n, 0 );
      row{star_edges} := [ 1, 1, 1, 1 ];
      Add( hx, row );

      # Plaquette (face) operator at (x, y): 4 boundary edges
      plaq_edges := [
        edge_idx( x, y, 0 ),      # bottom
        edge_idx( x, y_next, 0 ), # top
        edge_idx( x, y, 1 ),      # left
        edge_idx( x_next, y, 1 )  # right
      ];
      row := ListWithIdenticalEntries( n, 0 );
      row{plaq_edges} := [ 1, 1, 1, 1 ];
      Add( hz, row );
    od;
  od;

  # Remove one redundant star and one redundant plaquette to make generators independent
  Remove( hx, Length( hx ) );
  Remove( hz, Length( hz ) );

  code := CSSCode( hx, hz );
  code!.linear_size := L;
  code!.is_toric := true;

  # Construct the 4 homological logical operators
  log_ops := ToricCodeLogicalOperators( code );
  code!.logical_operators := log_ops;

  return code;
end );

#############################################################################
##
##  ToricCodeLinearSize( code )
##
InstallGlobalFunction( ToricCodeLinearSize, function( code )
  if IsBound( code!.linear_size ) then
    return code!.linear_size;
  fi;
  return 2;
end );

#############################################################################
##
##  ToricCodeStarStabilizers( code )
##
InstallGlobalFunction( ToricCodeStarStabilizers, function( code )
  return CSSXStabilizers( code );
end );

#############################################################################
##
##  ToricCodePlaquetteStabilizers( code )
##
InstallGlobalFunction( ToricCodePlaquetteStabilizers, function( code )
  return CSSZStabilizers( code );
end );

#############################################################################
##
##  ToricCodeLogicalOperators( code )
##
##  Returns [ Z1, X1, Z2, X2 ] logical operators.
##
InstallGlobalFunction( ToricCodeLogicalOperators, function( code )
  local L, n, edge_idx, zeros, z1_vec, x1_vec, z2_vec, x2_vec, x, y,
        z1, x1, z2, x2;

  L := ToricCodeLinearSize( code );
  n := 2 * L * L;
  zeros := ListWithIdenticalEntries( n, 0 );

  edge_idx := function( px, py, orient )
    return ( (px - 1) * L + (py - 1) ) * 2 + orient + 1;
  end;

  # Z1: horizontal loop on e_H(x, 1) for x = 1..L
  z1_vec := ShallowCopy( zeros );
  for x in [1 .. L] do
    z1_vec[ edge_idx( x, 1, 0 ) ] := 1;
  od;
  z1 := PauliOperator( n, 0, zeros, z1_vec );

  # X1: dual vertical cut on e_H(1, y) for y = 1..L
  x1_vec := ShallowCopy( zeros );
  for y in [1 .. L] do
    x1_vec[ edge_idx( 1, y, 0 ) ] := 1;
  od;
  x1 := PauliOperator( n, 0, x1_vec, zeros );

  # Z2: vertical loop on e_V(1, y) for y = 1..L
  z2_vec := ShallowCopy( zeros );
  for y in [1 .. L] do
    z2_vec[ edge_idx( 1, y, 1 ) ] := 1;
  od;
  z2 := PauliOperator( n, 0, zeros, z2_vec );

  # X2: dual horizontal cut on e_V(x, 1) for x = 1..L
  x2_vec := ShallowCopy( zeros );
  for x in [1 .. L] do
    x2_vec[ edge_idx( x, 1, 1 ) ] := 1;
  od;
  x2 := PauliOperator( n, 0, x2_vec, zeros );

  return rec(
    z1 := z1,
    x1 := x1,
    z2 := z2,
    x2 := x2
  );
end );
