#############################################################################
##
##  lib/surface.gi                 braid Package
##
##  Implementations for 2D topological rotated surface codes, planar lattices,
##  star and plaquette stabilizers, and boundary conditions.
##
#############################################################################

#############################################################################
##
##  SurfaceCodeQubitGrid( d )
##
##  Returns a d x d matrix with 1-based qubit indices 1 .. d^2.
##
InstallGlobalFunction( SurfaceCodeQubitGrid, function( d )
  local grid, r, c;
  grid := [ ];
  for r in [1 .. d] do
    Add( grid, List( [1 .. d], c -> (r - 1) * d + c ) );
  od;
  return grid;
end );

#############################################################################
##
##  RotatedSurfaceCode( distance )
##
##  Generates the [[d^2, 1, d]] rotated planar surface code.
##
InstallGlobalFunction( RotatedSurfaceCode, function( distance )
  local d, n, grid, x_gens, z_gens, r, c, q_idx, q1, q2, q3, q4, zeros, x_vec, z_vec, code;

  if not IsInt( distance ) or distance < 3 or (distance mod 2) = 0 then
    Error( "RotatedSurfaceCode: distance must be an odd integer >= 3" );
  fi;

  d := distance;
  n := d * d;
  grid := SurfaceCodeQubitGrid( d );
  q_idx := function( row, col )
    return grid[row][col];
  end;

  zeros := ListWithIdenticalEntries( n, 0 );
  x_gens := [ ];
  z_gens := [ ];

  # Internal weight-4 faces: (r, c) for r in [1 .. d-1], c in [1 .. d-1]
  for r in [1 .. d - 1] do
    for c in [1 .. d - 1] do
      q1 := q_idx( r, c );
      q2 := q_idx( r, c + 1 );
      q3 := q_idx( r + 1, c );
      q4 := q_idx( r + 1, c + 1 );

      if ((r + c) mod 2) = 0 then
        # X-type star stabilizer
        x_vec := ShallowCopy( zeros );
        x_vec[q1] := 1; x_vec[q2] := 1; x_vec[q3] := 1; x_vec[q4] := 1;
        Add( x_gens, PauliOperator( n, 0, x_vec, zeros ) );
      else
        # Z-type plaquette stabilizer
        z_vec := ShallowCopy( zeros );
        z_vec[q1] := 1; z_vec[q2] := 1; z_vec[q3] := 1; z_vec[q4] := 1;
        Add( z_gens, PauliOperator( n, 0, zeros, z_vec ) );
      fi;
    od;
  od;

  # Top rough boundary: weight-2 Z checks between (1, c) and (1, c+1) for odd c
  for c in [1, 3 .. d - 2] do
    q1 := q_idx( 1, c );
    q2 := q_idx( 1, c + 1 );
    z_vec := ShallowCopy( zeros );
    z_vec[q1] := 1; z_vec[q2] := 1;
    Add( z_gens, PauliOperator( n, 0, zeros, z_vec ) );
  od;

  # Bottom rough boundary: weight-2 Z checks between (d, c) and (d, c+1) for even c
  for c in [2, 4 .. d - 1] do
    q1 := q_idx( d, c );
    q2 := q_idx( d, c + 1 );
    z_vec := ShallowCopy( zeros );
    z_vec[q1] := 1; z_vec[q2] := 1;
    Add( z_gens, PauliOperator( n, 0, zeros, z_vec ) );
  od;

  # Left smooth boundary: weight-2 X checks between (r, 1) and (r+1, 1) for even r
  for r in [2, 4 .. d - 1] do
    q1 := q_idx( r, 1 );
    q2 := q_idx( r + 1, 1 );
    x_vec := ShallowCopy( zeros );
    x_vec[q1] := 1; x_vec[q2] := 1;
    Add( x_gens, PauliOperator( n, 0, x_vec, zeros ) );
  od;

  # Right smooth boundary: weight-2 X checks between (r, d) and (r+1, d) for odd r
  for r in [1, 3 .. d - 2] do
    q1 := q_idx( r, d );
    q2 := q_idx( r + 1, d );
    x_vec := ShallowCopy( zeros );
    x_vec[q1] := 1; x_vec[q2] := 1;
    Add( x_gens, PauliOperator( n, 0, x_vec, zeros ) );
  od;

  code := StabilizerCode( n, Concatenation( x_gens, z_gens ) );
  code!.surface_d := d;
  code!.x_stabs := x_gens;
  code!.z_stabs := z_gens;

  return code;
end );

#############################################################################
##
##  SurfaceCodeDistance( surf )
##
InstallGlobalFunction( SurfaceCodeDistance, function( surf )
  if IsBound( surf!.surface_d ) then
    return surf!.surface_d;
  fi;
  return ComputeCodeDistance( surf );
end );

#############################################################################
##
##  SurfaceCodeXStabilizers( surf )
##
InstallGlobalFunction( SurfaceCodeXStabilizers, function( surf )
  if IsBound( surf!.x_stabs ) then
    return surf!.x_stabs;
  fi;
  return CSSXStabilizers( surf );
end );

#############################################################################
##
##  SurfaceCodeZStabilizers( surf )
##
InstallGlobalFunction( SurfaceCodeZStabilizers, function( surf )
  if IsBound( surf!.z_stabs ) then
    return surf!.z_stabs;
  fi;
  return CSSZStabilizers( surf );
end );

#############################################################################
##
##  SurfaceCodeLogicalX( surf )
##
##  Horizontal chain of X operators across row 1.
##
InstallGlobalFunction( SurfaceCodeLogicalX, function( surf )
  local d, n, zeros, x_vec, c;
  d := SurfaceCodeDistance( surf );
  n := d * d;
  zeros := ListWithIdenticalEntries( n, 0 );
  x_vec := ShallowCopy( zeros );
  for c in [1 .. d] do
    x_vec[c] := 1;
  od;
  return PauliOperator( n, 0, x_vec, zeros );
end );

#############################################################################
##
##  SurfaceCodeLogicalZ( surf )
##
##  Vertical chain of Z operators down column 1.
##
InstallGlobalFunction( SurfaceCodeLogicalZ, function( surf )
  local d, n, zeros, z_vec, r;
  d := SurfaceCodeDistance( surf );
  n := d * d;
  zeros := ListWithIdenticalEntries( n, 0 );
  z_vec := ShallowCopy( zeros );
  for r in [1 .. d] do
    z_vec[(r - 1) * d + 1] := 1;
  od;
  return PauliOperator( n, 0, zeros, z_vec );
end );

#############################################################################
##
##  SurfaceCodeSyndromes( surf, error_pauli )
##
##  Extracts the separate X-syndromes and Z-syndromes.
##
InstallGlobalFunction( SurfaceCodeSyndromes, function( surf, error_pauli )
  local x_stabs, z_stabs, x_syn, z_syn;
  x_stabs := SurfaceCodeXStabilizers( surf );
  z_stabs := SurfaceCodeZStabilizers( surf );

  x_syn := List( x_stabs, g -> SymplecticInnerProduct( g, error_pauli ) );
  z_syn := List( z_stabs, g -> SymplecticInnerProduct( g, error_pauli ) );

  return rec(
    x_syndromes := x_syn,
    z_syndromes := z_syn
  );
end );

#############################################################################
##
##  SurfaceCodeLayout( surf )
##
##  Returns layout metadata for visualizer rendering: qubit coordinates,
##  stabilizer centers, and boundary definitions.
##
InstallGlobalFunction( SurfaceCodeLayout, function( surf )
  local d, n, grid, qubits, r, c;
  d := SurfaceCodeDistance( surf );
  n := d * d;
  grid := SurfaceCodeQubitGrid( d );
  qubits := [ ];

  for r in [1 .. d] do
    for c in [1 .. d] do
      Add( qubits, rec( id := grid[r][c], row := r, col := c ) );
    od;
  od;

  return rec(
    distance := d,
    num_qubits := n,
    qubits := qubits,
    num_x_stabs := Length( SurfaceCodeXStabilizers( surf ) ),
    num_z_stabs := Length( SurfaceCodeZStabilizers( surf ) )
  );
end );
