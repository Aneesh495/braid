#############################################################################
##
##  lib/surgery.gi                 braid Package
##
##  Implementations for surface code lattice surgery: patch merges (ZZ and XX),
##  patch splits, and fault-tolerant logical multi-qubit measurements.
##
#############################################################################

#############################################################################
##
##  LatticeSurgeryMergeZZ( patch_a, patch_b )
##
##  Executes rough-rough lattice surgery merge between two surface code patches:
##  measures joint Z_A (x) Z_B logical parity across the interface.
##
InstallGlobalFunction( LatticeSurgeryMergeZZ, function( patch_a, patch_b )
  local na, nb, n_tot, zeros, gens, ga, gb, x_vec, z_vec, d, joint_z_ops, r, qa, qb,
        log_za, log_zb, joint_log_z, merged_code;

  na := patch_a!.nqubits;
  nb := patch_b!.nqubits;
  n_tot := na + nb;
  zeros := ListWithIdenticalEntries( n_tot, 0 );
  gens := [ ];

  # Embed patch_a stabilizers into first na qubits
  for ga in patch_a!.generators do
    x_vec := ShallowCopy( zeros );
    z_vec := ShallowCopy( zeros );
    x_vec{[1 .. na]} := ga!.x;
    z_vec{[1 .. na]} := ga!.z;
    Add( gens, PauliOperator( n_tot, 0, x_vec, z_vec ) );
  od;

  # Embed patch_b stabilizers into qubits na+1 .. na+nb
  for gb in patch_b!.generators do
    x_vec := ShallowCopy( zeros );
    z_vec := ShallowCopy( zeros );
    x_vec{[na + 1 .. n_tot]} := gb!.x;
    z_vec{[na + 1 .. n_tot]} := gb!.z;
    Add( gens, PauliOperator( n_tot, 0, x_vec, z_vec ) );
  od;

  # Boundary measurement operators along the rough seam
  d := SurfaceCodeDistance( patch_a );
  joint_z_ops := [ ];
  for r in [1 .. d] do
    qa := (r - 1) * d + d; # right boundary of patch_a
    qb := na + (r - 1) * d + 1; # left boundary of patch_b

    z_vec := ShallowCopy( zeros );
    z_vec[qa] := 1;
    z_vec[qb] := 1;
    Add( joint_z_ops, PauliOperator( n_tot, 0, zeros, z_vec ) );
  od;

  # Joint logical Z operator: Z_L^(A) (x) Z_L^(B)
  log_za := SurfaceCodeLogicalZ( patch_a );
  log_zb := SurfaceCodeLogicalZ( patch_b );
  z_vec := ShallowCopy( zeros );
  z_vec{[1 .. na]} := log_za!.z;
  z_vec{[na + 1 .. n_tot]} := log_zb!.z;
  joint_log_z := PauliOperator( n_tot, 0, zeros, z_vec );

  # The merged code has mA + mB + 1 generators encoding 1 logical qubit
  merged_code := StabilizerCode( n_tot, Concatenation( gens, [ joint_log_z ] ) );
  merged_code!.is_merged := true;
  merged_code!.surgery_type := "ZZ";
  merged_code!.joint_measurement := joint_z_ops;
  merged_code!.joint_logical := joint_log_z;

  return merged_code;
end );

#############################################################################
##
##  LatticeSurgeryMergeXX( patch_a, patch_b )
##
##  Executes smooth-smooth lattice surgery merge measuring joint X_A (x) X_B.
##
InstallGlobalFunction( LatticeSurgeryMergeXX, function( patch_a, patch_b )
  local na, nb, n_tot, zeros, gens, ga, gb, x_vec, z_vec, d, joint_x_ops, c, qa, qb,
        log_xa, log_xb, joint_log_x, merged_code;

  na := patch_a!.nqubits;
  nb := patch_b!.nqubits;
  n_tot := na + nb;
  zeros := ListWithIdenticalEntries( n_tot, 0 );
  gens := [ ];

  for ga in patch_a!.generators do
    x_vec := ShallowCopy( zeros );
    z_vec := ShallowCopy( zeros );
    x_vec{[1 .. na]} := ga!.x;
    z_vec{[1 .. na]} := ga!.z;
    Add( gens, PauliOperator( n_tot, 0, x_vec, z_vec ) );
  od;

  for gb in patch_b!.generators do
    x_vec := ShallowCopy( zeros );
    z_vec := ShallowCopy( zeros );
    x_vec{[na + 1 .. n_tot]} := gb!.x;
    z_vec{[na + 1 .. n_tot]} := gb!.z;
    Add( gens, PauliOperator( n_tot, 0, x_vec, z_vec ) );
  od;

  d := SurfaceCodeDistance( patch_a );
  joint_x_ops := [ ];
  for c in [1 .. d] do
    qa := (d - 1) * d + c; # bottom boundary of patch_a
    qb := na + c; # top boundary of patch_b

    x_vec := ShallowCopy( zeros );
    x_vec[qa] := 1;
    x_vec[qb] := 1;
    Add( joint_x_ops, PauliOperator( n_tot, 0, x_vec, zeros ) );
  od;

  # Joint logical X operator: X_L^(A) (x) X_L^(B)
  log_xa := SurfaceCodeLogicalX( patch_a );
  log_xb := SurfaceCodeLogicalX( patch_b );
  x_vec := ShallowCopy( zeros );
  x_vec{[1 .. na]} := log_xa!.x;
  x_vec{[na + 1 .. n_tot]} := log_xb!.x;
  joint_log_x := PauliOperator( n_tot, 0, x_vec, zeros );

  # The merged code has mA + mB + 1 generators encoding 1 logical qubit
  merged_code := StabilizerCode( n_tot, Concatenation( gens, [ joint_log_x ] ) );
  merged_code!.is_merged := true;
  merged_code!.surgery_type := "XX";
  merged_code!.joint_measurement := joint_x_ops;
  merged_code!.joint_logical := joint_log_x;

  return merged_code;
end );

#############################################################################
##
##  LatticeSurgerySplit( merged_code, na, nb )
##
##  Splits a merged patch back into its two constituent patches.
##
InstallGlobalFunction( LatticeSurgerySplit, function( merged_code, na, nb )
  local patch_a_gens, patch_b_gens, g, n_tot;
  n_tot := merged_code!.nqubits;

  patch_a_gens := [ ];
  patch_b_gens := [ ];

  for g in merged_code!.generators do
    if Sum( g!.x{[na + 1 .. n_tot]} ) = 0 and Sum( g!.z{[na + 1 .. n_tot]} ) = 0 then
      Add( patch_a_gens, PauliOperator( na, g!.phase, g!.x{[1 .. na]}, g!.z{[1 .. na]} ) );
    elif Sum( g!.x{[1 .. na]} ) = 0 and Sum( g!.z{[1 .. na]} ) = 0 then
      Add( patch_b_gens, PauliOperator( nb, g!.phase, g!.x{[na + 1 .. n_tot]}, g!.z{[na + 1 .. n_tot]} ) );
    fi;
  od;

  return rec(
    patch_a := StabilizerCode( na, patch_a_gens ),
    patch_b := StabilizerCode( nb, patch_b_gens )
  );
end );

#############################################################################
##
##  LatticeSurgeryJointMeasurement( merged_code )
##
InstallGlobalFunction( LatticeSurgeryJointMeasurement, function( merged_code )
  if IsBound( merged_code!.joint_measurement ) then
    return merged_code!.joint_measurement;
  fi;
  return [ ];
end );
