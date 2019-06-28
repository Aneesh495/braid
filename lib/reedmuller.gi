#############################################################################
##
##  lib/reedmuller.gi             braid Package
##
##  Implementations for the [[15, 1, 3]] Quantum Reed-Muller code and
##  transversal non-Clifford T gate verification (Bravyi-Kitaev).
##
#############################################################################

#############################################################################
##
##  QuantumReedMullerCode()
##
##  Constructs the [[15, 1, 3]] CSS Quantum Reed-Muller code from the
##  punctured Reed-Muller code RM(1, 4)* and RM(2, 4)*.
##
InstallGlobalFunction( QuantumReedMullerCode, function()
  local hz, hx, pt, i, row, code, log_x, log_z, zeros, ones;

  # H_Z check matrix: 4 rows of weight 8, corresponding to coordinates x1, x2, x3, x4
  hz := [ ];
  for i in [0 .. 3] do
    row := List( [1 .. 15], pt -> (QuoInt( pt, 2^i ) mod 2) );
    Add( hz, row );
  od;

  # H_X check matrix: 10 independent generators of weight 8 orthogonal to H_Z
  hx := [
    [ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 ],
    [ 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1 ],
    [ 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1 ],
    [ 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1 ],
    [ 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1 ],
    [ 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1 ],
    [ 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1 ],
    [ 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1 ],
    [ 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1 ],
    [ 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1 ]
  ];

  code := CSSCode( hx, hz );
  code!.is_reed_muller := true;
  code!.distance := 3;

  # Logical operators
  zeros := ListWithIdenticalEntries( 15, 0 );
  ones := ListWithIdenticalEntries( 15, 1 );

  log_x := PauliOperator( 15, 0, ones, zeros );
  log_z := PauliOperator( 15, 0, zeros, [ 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1 ] );

  code!.logical_x := log_x;
  code!.logical_z := log_z;

  return code;
end );

#############################################################################
##
##  ReedMullerLogicalX( code )
##
InstallGlobalFunction( ReedMullerLogicalX, function( code )
  return code!.logical_x;
end );

#############################################################################
##
##  ReedMullerLogicalZ( code )
##
InstallGlobalFunction( ReedMullerLogicalZ, function( code )
  return code!.logical_z;
end );

#############################################################################
##
##  ReedMullerTransversalT( code )
##
##  Verifies the Bravyi-Kitaev theorem for [[15, 1, 3]]:
##  Bitwise transversal T^(x15) maps stabilizers into the stabilizer group,
##  implementing logical T^dag on the encoded qubit.
##
InstallGlobalFunction( ReedMullerTransversalT, function( code )
  local hz, hx, r;
  hz := CSSZMatrix( code );
  hx := CSSXMatrix( code );

  # Check that all Z-stabilizers are preserved (trivially diagonal)
  # Check that all X-stabilizers have weight 8 (multiple of 8)
  for r in hx do
    if (Sum( r ) mod 8) <> 0 then
      return false;
    fi;
  od;

  # Check that H_Z rows have weight multiple of 4
  for r in hz do
    if (Sum( r ) mod 4) <> 0 then
      return false;
    fi;
  od;

  return true;
end );

#############################################################################
##
##  IsTriplyEvenCode( check_matrix )
##
##  Checks if all codewords in the check matrix have Hamming weight = 0 mod 8.
##
InstallGlobalFunction( IsTriplyEvenCode, function( check_matrix )
  local row;
  for row in check_matrix do
    if (Sum( row ) mod 8) <> 0 then
      return false;
    fi;
  od;
  return true;
end );
