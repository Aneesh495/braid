#############################################################################
##
##  lib/threshold.gi               braid Package
##
##  Implementations for Monte Carlo fault-tolerant threshold simulation,
##  logical error rate curves (p_L vs p), and crossing point analysis.
##
#############################################################################

#############################################################################
##
##  SimulateLogicalErrorRate( code, decoder, p_physical, num_shots )
##
##  Runs Monte Carlo error injection and syndrome decoding shots to evaluate
##  the empirical logical error probability p_L.
##
InstallGlobalFunction( SimulateLogicalErrorRate, function( code, decoder, p_physical, num_shots )
  local failures, shot, noise_shot, err, syn, recov, check;

  failures := 0;
  for shot in [1 .. num_shots] do
    noise_shot := InjectPhenomenologicalNoise( code, p_physical );
    err := noise_shot.error;
    syn := noise_shot.syndrome;

    if ForAny( syn, s -> s <> 0 ) then
      if IsRecord( decoder ) and IsBound( decoder.table ) then
        recov := DecodeWithLUT( decoder, syn );
      elif IsRecord( decoder ) and IsBound( decoder.layout ) then
        recov := DecodeWithMWPM( decoder, syn );
      else
        recov := DecodeWithBPOSD( decoder, syn );
      fi;

      check := VerifyCorrectionSuccess( code, err, recov );
      if not check.success then
        failures := failures + 1;
      fi;
    fi;
  od;

  return Float( failures ) / Float( num_shots );
end );

#############################################################################
##
##  ComputeThresholdCurve( code, decoder, p_values, shots_per_point )
##
InstallGlobalFunction( ComputeThresholdCurve, function( code, decoder, p_values, shots_per_point )
  local results, p, p_L;
  results := [ ];
  for p in p_values do
    p_L := SimulateLogicalErrorRate( code, decoder, p, shots_per_point );
    Add( results, rec(
      p_physical := p,
      p_logical := p_L
    ) );
  od;
  return results;
end );

#############################################################################
##
##  SurfaceCodeThresholdScan( distances, p_values, shots_per_point )
##
##  Executes a multi-distance threshold scan across surface codes to detect
##  the fault-tolerance threshold crossing point.
##
InstallGlobalFunction( SurfaceCodeThresholdScan, function( distances, p_values, shots_per_point )
  local scan_results, d, surf, dec, curve;
  scan_results := [ ];

  for d in distances do
    surf := RotatedSurfaceCode( d );
    dec := MWPMSurfaceDecoder( surf );
    curve := ComputeThresholdCurve( surf, dec, p_values, shots_per_point );
    Add( scan_results, rec(
      distance := d,
      curve := curve
    ) );
  od;

  return scan_results;
end );

#############################################################################
##
##  DetectThresholdCrossing( scan_results )
##
##  Finds the crossing point where higher distance yields lower logical error rate.
##
InstallGlobalFunction( DetectThresholdCrossing, function( scan_results )
  local p_thresh, c1, c2, i, p, l1, l2;
  if Length( scan_results ) < 2 then
    return fail;
  fi;

  c1 := scan_results[1].curve;
  c2 := scan_results[2].curve;
  p_thresh := fail;

  for i in [1 .. Length( c1 )] do
    p := c1[i].p_physical;
    l1 := c1[i].p_logical;
    l2 := c2[i].p_logical;

    # Crossing occurs when relative order of l1 (lower distance) and l2 (higher distance) flips
    if l2 < l1 and p_thresh = fail then
      p_thresh := p;
    fi;
  od;

  return p_thresh;
end );

#############################################################################
##
##  PrintThresholdReport( scan_results )
##
InstallGlobalFunction( PrintThresholdReport, function( scan_results )
  local item, pt;
  Print( "Fault-Tolerant Threshold Scan Report:\n" );
  for item in scan_results do
    Print( "Distance d = ", item.distance, ":\n" );
    for pt in item.curve do
      Print( "  p_phys = ", String( pt.p_physical ), " -> p_log = ", String( pt.p_logical ), "\n" );
    od;
  od;
end );
