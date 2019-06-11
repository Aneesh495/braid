#############################################################################
##
##  lib/graphstate.gi              braid Package
##
##  Implementations for the graph state formalism, cluster states for MBQC,
##  and local complementation (LC) orbits.
##
#############################################################################

#############################################################################
##
##  GraphStateStabilizers( adjacency_matrix )
##
##  For a graph with adjacency matrix A, stabilizer generator K_i is:
##    K_i = X_i * Prod_{j in nbhd(i)} Z_j
##
InstallGlobalFunction( GraphStateStabilizers, function( adjacency_matrix )
  local n, gens, i, j, zeros, x_vec, z_vec;
  n := Length( adjacency_matrix );
  gens := [ ];
  zeros := ListWithIdenticalEntries( n, 0 );

  for i in [1 .. n] do
    x_vec := ShallowCopy( zeros );
    z_vec := ShallowCopy( zeros );

    x_vec[i] := 1;
    for j in [1 .. n] do
      if adjacency_matrix[i][j] = 1 then
        z_vec[j] := 1;
      fi;
    od;

    Add( gens, PauliOperator( n, 0, x_vec, z_vec ) );
  od;

  return gens;
end );

#############################################################################
##
##  GraphState( adjacency_matrix )
##
InstallGlobalFunction( GraphState, function( adjacency_matrix )
  local gens, n, code;
  n := Length( adjacency_matrix );
  gens := GraphStateStabilizers( adjacency_matrix );
  code := StabilizerCode( n, gens );
  code!.adj_matrix := List( adjacency_matrix, r -> ShallowCopy( r ) );
  return code;
end );

#############################################################################
##
##  GraphStateAdjacencyMatrix( graph_code )
##
InstallGlobalFunction( GraphStateAdjacencyMatrix, function( graph_code )
  if IsBound( graph_code!.adj_matrix ) then
    return graph_code!.adj_matrix;
  fi;
  return fail;
end );

#############################################################################
##
##  LocalComplementation( adjacency_matrix, vertex )
##
##  Applies local complementation to vertex v: inverts the adjacency of all
##  pairs of distinct vertices in the neighborhood of v.
##
InstallGlobalFunction( LocalComplementation, function( adjacency_matrix, vertex )
  local n, A, nbhd, j, k, u, w;
  n := Length( adjacency_matrix );
  A := List( adjacency_matrix, r -> ShallowCopy( r ) );

  # Extract neighborhood of vertex
  nbhd := [ ];
  for j in [1 .. n] do
    if j <> vertex and A[vertex][j] = 1 then
      Add( nbhd, j );
    fi;
  od;

  # Invert edges between all pairs in neighborhood
  for j in [1 .. Length( nbhd )] do
    u := nbhd[j];
    for k in [j + 1 .. Length( nbhd )] do
      w := nbhd[k];
      A[u][w] := 1 - A[u][w];
      A[w][u] := 1 - A[w][u];
    od;
  od;

  return A;
end );

#############################################################################
##
##  ClusterState1D( n )
##
##  Generates the 1D path cluster state of n qubits:
##  vertices connected along a line 1 - 2 - ... - n.
##
InstallGlobalFunction( ClusterState1D, function( n )
  local A, i;
  A := List( [1 .. n], i -> ListWithIdenticalEntries( n, 0 ) );
  for i in [1 .. n - 1] do
    A[i][i + 1] := 1;
    A[i + 1][i] := 1;
  od;
  return GraphState( A );
end );

#############################################################################
##
##  ClusterState2D( rows, cols )
##
##  Generates the 2D grid cluster state: a universal resource state for MBQC.
##
InstallGlobalFunction( ClusterState2D, function( rows, cols )
  local n, A, idx, r, c, u, v;
  n := rows * cols;
  A := List( [1 .. n], u -> ListWithIdenticalEntries( n, 0 ) );

  idx := function( r_coord, c_coord )
    return (r_coord - 1) * cols + c_coord;
  end;

  for r in [1 .. rows] do
    for c in [1 .. cols] do
      u := idx( r, c );
      # Horizontal neighbor
      if c < cols then
        v := idx( r, c + 1 );
        A[u][v] := 1;
        A[v][u] := 1;
      fi;
      # Vertical neighbor
      if r < rows then
        v := idx( r + 1, c );
        A[u][v] := 1;
        A[v][u] := 1;
      fi;
    od;
  od;

  return GraphState( A );
end );
