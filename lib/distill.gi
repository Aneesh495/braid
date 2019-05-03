#############################################################################
##
##  lib/distill.gi                 braid Package
##
##  Implementations for non-Clifford magic state distillation factories:
##  15-to-1 T-state factory and Bravyi-Kitaev 8-to-2 CCZ distillation.
##
#############################################################################

#############################################################################
##
##  MagicStateDistillation15to1( eps_in )
##
##  Computes theoretical output error rate eps_out = 35 * eps_in^3 and
##  acceptance probability for the 15-to-1 T-state distillation protocol.
##
InstallGlobalFunction( MagicStateDistillation15to1, function( eps_in )
  local e, eps_out, p_acc, red_factor;
  e := Float( eps_in );
  eps_out := 35.0 * (e^3);
  p_acc := 1.0 - 105.0 * (e^2);
  if p_acc < 0.0 then
    p_acc := 0.0;
  fi;

  if eps_out > 0.0 then
    red_factor := e / eps_out;
  else
    red_factor := 0.0;
  fi;

  return rec(
    input_error := e,
    output_error := eps_out,
    acceptance_probability := p_acc,
    error_reduction_factor := red_factor
  );
end );

#############################################################################
##
##  MagicStateFactoryLevels( target_eps, raw_eps )
##
##  Calculates the required cascade levels of 15-to-1 distillation to suppress
##  error from raw_eps down below target_eps.
##
InstallGlobalFunction( MagicStateFactoryLevels, function( target_eps, raw_eps )
  local cur_eps, levels, res, total_raw_states;
  cur_eps := Float( raw_eps );
  levels := 0;
  total_raw_states := 1;

  while cur_eps > Float( target_eps ) and levels < 10 do
    res := MagicStateDistillation15to1( cur_eps );
    cur_eps := res.output_error;
    levels := levels + 1;
    total_raw_states := total_raw_states * 15;
  od;

  return rec(
    required_levels := levels,
    final_output_error := cur_eps,
    raw_states_per_magic_state := total_raw_states
  );
end );

#############################################################################
##
##  SimulateDistillationRound( eps_in, num_trials )
##
##  Monte Carlo simulation of 15-to-1 distillation:
##  Samples 15 physical qubits with error probability eps_in.
##  Reed-Muller [[15, 1, 3]] accepts if number of errors <= 1.
##  If errors == 0, output is perfect; if errors == 1, error is corrected;
##  if errors >= 2, undetected error may slip through or shot is rejected.
##
InstallGlobalFunction( SimulateDistillationRound, function( eps_in, num_trials )
  local accepted, undetected_errors, trial, errors_in_block, q, r, p_out;
  accepted := 0;
  undetected_errors := 0;

  for trial in [1 .. num_trials] do
    errors_in_block := 0;
    for q in [1 .. 15] do
      r := Random( [1 .. 1000000] ) / 1000000.0;
      if r <= Float( eps_in ) then
        errors_in_block := errors_in_block + 1;
      fi;
    od;

    if errors_in_block = 0 then
      accepted := accepted + 1;
    elif errors_in_block = 1 then
      # Corrected by distance-3 code
      accepted := accepted + 1;
    elif errors_in_block = 3 then
      # Weight-3 logical error slips through undetected
      accepted := accepted + 1;
      undetected_errors := undetected_errors + 1;
    fi;
    # Weight 2, 4, etc. trigger non-zero syndromes and are rejected
  od;

  if accepted > 0 then
    p_out := Float( undetected_errors ) / Float( accepted );
  else
    p_out := 0.0;
  fi;

  return rec(
    trials := num_trials,
    accepted := accepted,
    acceptance_rate := Float( accepted ) / Float( num_trials ),
    measured_output_error := p_out
  );
end );

#############################################################################
##
##  BravyiKitaevCCZFactory( eps_in )
##
InstallGlobalFunction( BravyiKitaevCCZFactory, function( eps_in )
  local e, eps_out;
  e := Float( eps_in );
  eps_out := 28.0 * (e^2);
  return rec(
    input_error := e,
    output_ccz_error := eps_out,
    raw_qubits_consumed := 8,
    purified_ccz_yield := 2
  );
end );
