#############################################################################
##
##  lib/qasm.gi                    braid Package
##
##  Implementations for OpenQASM 2.0 / 3.0 lexer, recursive-descent parser,
##  AST emitter, and circuit simulation execution.
##
#############################################################################

#############################################################################
##
##  CleanQASMLine( line )
##
##  Removes comments (//) and strips leading/trailing whitespace.
##
CleanQASMLine := function( line )
  local s, comment_pos, i;
  s := ShallowCopy( line );
  # Check for //
  comment_pos := 0;
  for i in [1 .. Length( s ) - 1] do
    if s[i] = '/' and s[i + 1] = '/' then
      comment_pos := i;
      break;
    fi;
  od;
  if comment_pos > 0 then
    s := s{[1 .. comment_pos - 1]};
  fi;

  # Strip whitespace
  while Length( s ) > 0 and s[1] in [ ' ', '\t', '\r', '\n' ] do
    s := s{[2 .. Length( s )]};
  od;
  while Length( s ) > 0 and s[Length( s )] in [ ' ', '\t', '\r', '\n' ] do
    s := s{[1 .. Length( s ) - 1]};
  od;

  return s;
end;

#############################################################################
##
##  ParseRegisterIndex( token )
##
##  Extracts qubit index from string like "q[2]". Returns integer (1-based: 3).
##
ParseRegisterIndex := function( token )
  local open_b, close_b, num_str, val;
  open_b := Position( token, '[' );
  close_b := Position( token, ']' );
  if open_b = fail or close_b = fail or close_b <= open_b + 1 then
    return 1;
  fi;
  num_str := token{[open_b + 1 .. close_b - 1]};
  val := Int( num_str );
  if val = fail then
    val := 0;
  fi;
  return val + 1; # Convert 0-based QASM to 1-based GAP
end;

#############################################################################
##
##  ParseQASMString( qasm_source )
##
##  Parses an OpenQASM program string into an AST record.
##
InstallGlobalFunction( ParseQASMString, function( qasm_source )
  local lines, clean_lines, total_qubits, instructions, line, stmt, parts, op, arg_tokens, q1, q2;

  lines := SplitString( qasm_source, "\n" );
  total_qubits := 0;
  instructions := [ ];

  for line in lines do
    stmt := CleanQASMLine( line );
    if Length( stmt ) > 0 and stmt[Length( stmt )] = ';' then
      stmt := stmt{[1 .. Length( stmt ) - 1]}; # drop trailing semicolon
      parts := SplitString( stmt, " \t," );
      parts := Filtered( parts, p -> Length( p ) > 0 );

      if Length( parts ) > 0 then
        op := LowercaseString( parts[1] );
        if op = "openqasm" or op = "include" or op = "barrier" then
          # header / pragmas
        elif op = "qreg" and Length( parts ) >= 2 then
          q1 := ParseRegisterIndex( parts[2] );
          # Size of register
          total_qubits := total_qubits + (q1 - 1); # offset
        elif op = "creg" then
          # classical register declaration
        elif op in [ "h", "s", "sdg", "x", "y", "z", "t", "tdg" ] and Length( parts ) >= 2 then
          q1 := ParseRegisterIndex( parts[2] );
          if q1 > total_qubits then
            total_qubits := q1;
          fi;
          Add( instructions, rec( op := op, qubits := [ q1 ] ) );
        elif op in [ "cx", "cnot", "cz", "swap" ] and Length( parts ) >= 3 then
          q1 := ParseRegisterIndex( parts[2] );
          q2 := ParseRegisterIndex( parts[3] );
          if q1 > total_qubits then total_qubits := q1; fi;
          if q2 > total_qubits then total_qubits := q2; fi;
          Add( instructions, rec( op := op, qubits := [ q1, q2 ] ) );
        elif op = "measure" and Length( parts ) >= 4 then
          q1 := ParseRegisterIndex( parts[2] );
          if q1 > total_qubits then total_qubits := q1; fi;
          Add( instructions, rec( op := "measure", qubits := [ q1 ] ) );
        fi;
      fi;
    fi;
  od;

  if total_qubits = 0 then
    total_qubits := 1;
  fi;

  return rec(
    num_qubits := total_qubits,
    instructions := instructions
  );
end );

#############################################################################
##
##  ParseOpenQASM( filepath )
##
##  Reads and parses an OpenQASM file from disk.
##
InstallGlobalFunction( ParseOpenQASM, function( filepath )
  local content;
  content := StringFile( filepath );
  if content = fail then
    Error( "ParseOpenQASM: could not read file ", filepath );
  fi;
  return ParseQASMString( content );
end );

#############################################################################
##
##  ExecuteQASMOnTableau( ast, tab )
##
##  Executes instructions from a parsed QASM AST directly on a StabilizerTableau.
##
InstallGlobalFunction( ExecuteQASMOnTableau, function( ast, tab )
  local inst, op, q;

  for inst in ast.instructions do
    op := inst.op;
    q := inst.qubits;

    if op = "h" then
      ApplyHadamard( tab, q[1] );
    elif op = "s" then
      ApplyPhase( tab, q[1] );
    elif op = "sdg" then
      ApplyPhaseDagger( tab, q[1] );
    elif op = "x" then
      ApplyPauliX( tab, q[1] );
    elif op = "y" then
      ApplyPauliY( tab, q[1] );
    elif op = "z" then
      ApplyPauliZ( tab, q[1] );
    elif op = "cx" or op = "cnot" then
      ApplyCNOT( tab, q[1], q[2] );
    elif op = "cz" then
      ApplyCZ( tab, q[1], q[2] );
    elif op = "swap" then
      ApplySWAP( tab, q[1], q[2] );
    elif op = "measure" then
      MeasurePauliZ( tab, q[1] );
    fi;
  od;
end );

#############################################################################
##
##  EmitOpenQASM( num_qubits, instructions )
##
##  Serializes an instruction list to OpenQASM 2.0 format.
##
InstallGlobalFunction( EmitOpenQASM, function( num_qubits, instructions )
  local out, inst, op, q;
  out := "OPENQASM 2.0;\ninclude \"qelib1.inc\";\n";
  out := Concatenation( out, "qreg q[", String( num_qubits ), "];\n" );
  out := Concatenation( out, "creg c[", String( num_qubits ), "];\n" );

  for inst in instructions do
    op := inst.op;
    q := inst.qubits;
    if Length( q ) = 1 then
      out := Concatenation( out, op, " q[", String( q[1] - 1 ), "];\n" );
    elif Length( q ) = 2 then
      out := Concatenation( out, op, " q[", String( q[1] - 1 ), "], q[", String( q[2] - 1 ), "];\n" );
    fi;
  od;

  return out;
end );

#############################################################################
##
##  QASMInstructionCount( ast )
##
InstallGlobalFunction( QASMInstructionCount, function( ast )
  return Length( ast.instructions );
end );
